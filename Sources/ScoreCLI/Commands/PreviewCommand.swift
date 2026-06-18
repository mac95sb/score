import ArgumentParser
import Foundation
import Noora

/// `score preview` — serve the static build output locally.
///
/// Builds the app in release mode (if not already built) and runs it with
/// `--preview` so it serves the pre-built static files exactly as a CDN or
/// static host would — no hot-reload, `Cache-Control: max-age=31536000` on
/// fingerprinted assets, and a 404 page for missing routes.
struct PreviewCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "preview",
        abstract: "Serve the static build from .score/build/ locally."
    )

    @Option(name: .shortAndLong, help: "Port to listen on.")
    var port: Int = 4173

    @Option(name: .shortAndLong, help: "Host to bind to.")
    var host: String = "localhost"

    @Option(name: .long, help: "Directory to serve (default: .score/build).")
    var directory: String = ".score/build"

    @Flag(name: .long, help: "Rebuild before previewing.")
    var rebuild: Bool = false

    mutating func run() async throws {
        let buildDir = URL(fileURLWithPath: directory)

        let noora = Noora()

        if rebuild || !FileManager.default.fileExists(atPath: buildDir.path) {
            let built = try await noora.progressStep(message: "Building site…") { _ in
                try await buildPackage(configuration: "release", verbose: false)
            }
            guard built else { throw CLIError.buildFailed }
        }

        guard FileManager.default.fileExists(atPath: buildDir.path) else {
            throw CLIError.buildNotFound(directory)
        }

        noora.info(
            .alert(
                "score preview",
                takeaways: ["http://\(host):\(port)", "Serving from \(directory)", "Press Ctrl-C to stop"]
            ))

        // Use a built-in Foundation-based static file server so we don't need
        // to declare NIO as a direct dependency of ScoreCLI.
        let server = StaticFileServer(
            root: buildDir,
            host: host,
            port: port
        )
        try await server.start()
    }
}

// MARK: - StaticFileServer

/// A minimal static file server built on top of POSIX sockets via Foundation.
///
/// This is intentionally simple — it handles one request at a time via
/// sequential `accept()` calls in a `Task`.  For production previews the
/// `score` binary itself provides a full NIO server; this is only for
/// convenience during `score preview`.
actor StaticFileServer {
    let root: URL
    let host: String
    let port: Int

    init(root: URL, host: String, port: Int) {
        self.root = root
        self.host = host
        self.port = port
    }

    func start() async throws {
        // Create a TCP socket.
        // SOCK_STREAM is Int32 on Darwin but __socket_type (an enum) on Linux.
        #if canImport(Darwin)
        let serverFD = socket(AF_INET, SOCK_STREAM, 0)
        #else
        let serverFD = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
        #endif
        guard serverFD >= 0 else {
            throw StaticServerError.socketCreation
        }
        defer { close(serverFD) }

        // Allow address reuse
        var reuse: Int32 = 1
        setsockopt(serverFD, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))

        // Bind
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = UInt16(port).bigEndian
        addr.sin_addr.s_addr = INADDR_ANY

        let bindResult = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(serverFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard bindResult == 0 else { throw StaticServerError.bindFailed(port) }

        // Listen
        guard listen(serverFD, 64) == 0 else { throw StaticServerError.listenFailed }

        Noora().passthrough("Listening on http://\(host):\(port)")

        // Accept loop
        while !Task.isCancelled {
            let clientFD = accept(serverFD, nil, nil)
            guard clientFD >= 0 else { continue }
            await serveClient(fd: clientFD)
        }
    }

    // MARK: - Request handling

    private func serveClient(fd: Int32) async {
        defer { close(fd) }

        // Read HTTP request line
        var buffer = [UInt8](repeating: 0, count: 8192)
        let bytesRead = recv(fd, &buffer, buffer.count, 0)
        guard bytesRead > 0 else { return }

        let raw = String(bytes: buffer.prefix(bytesRead), encoding: .utf8) ?? ""
        let firstLine = raw.components(separatedBy: "\r\n").first ?? ""
        let parts = firstLine.components(separatedBy: " ")
        guard parts.count >= 2 else { return }

        var urlPath = parts[1].components(separatedBy: "?").first ?? "/"

        // Resolve the file
        if urlPath.hasSuffix("/") { urlPath += "index.html" }
        if !urlPath.contains(".") { urlPath += "/index.html" }

        let fileURL = root.appendingPathComponent(urlPath)

        if let data = try? Data(contentsOf: fileURL) {
            let mime = mimeType(for: fileURL.pathExtension)
            let isFingerprinted = fileURL.lastPathComponent.split(separator: ".").count >= 3
            let cacheControl =
                isFingerprinted
                ? "max-age=31536000, immutable"
                : "no-cache, must-revalidate"

            let header = "HTTP/1.1 200 OK\r\nContent-Type: \(mime)\r\nContent-Length: \(data.count)\r\nCache-Control: \(cacheControl)\r\nConnection: close\r\n\r\n"
            sendResponse(fd: fd, header: header, body: data)
        } else {
            let body = Data("<h1>404 Not Found</h1>".utf8)
            let header = "HTTP/1.1 404 Not Found\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(body.count)\r\nConnection: close\r\n\r\n"
            sendResponse(fd: fd, header: header, body: body)
        }
    }

    private func sendResponse(fd: Int32, header: String, body: Data) {
        let headerData = Data(header.utf8)
        _ = headerData.withUnsafeBytes { send(fd, $0.baseAddress!, $0.count, 0) }
        _ = body.withUnsafeBytes { send(fd, $0.baseAddress!, $0.count, 0) }
    }

    private func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html": return "text/html; charset=utf-8"
        case "css": return "text/css"
        case "js": return "application/javascript"
        case "json": return "application/json"
        case "svg": return "image/svg+xml"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "webp": return "image/webp"
        case "ico": return "image/x-icon"
        case "woff": return "font/woff"
        case "woff2": return "font/woff2"
        case "ttf": return "font/ttf"
        case "txt": return "text/plain; charset=utf-8"
        case "xml": return "application/xml"
        default: return "application/octet-stream"
        }
    }
}

// MARK: - StaticServerError

enum StaticServerError: Error {
    case socketCreation
    case bindFailed(Int)
    case listenFailed
}
