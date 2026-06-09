import ArgumentParser
import Foundation
import Logging
import Noora

/// `score dev` — start the development server with hot-reload.
///
/// Compiles the app in debug mode, starts the NIO server on `localhost`,
/// watches source files for changes, and pushes reload events to the browser
/// via a Server-Sent Events endpoint (`/__score/dev`).
struct DevCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dev",
        abstract: "Start the development server with hot-reload."
    )

    @Option(name: .shortAndLong, help: "Port to listen on.")
    var port: Int = 8080

    @Option(name: .shortAndLong, help: "Host to bind to.")
    var host: String = "localhost"

    @Flag(name: .long, help: "Disable hot-reload.")
    var noHotReload: Bool = false

    @Flag(name: .long, help: "Verbose compiler and server output.")
    var verbose: Bool = false

    mutating func run() async throws {
        let noora = Noora()
        noora.info(.alert(
            "score dev",
            takeaways: ["http://\(host):\(port)", "Press Ctrl-C to stop"]
        ))

        let built = try await buildPackage(configuration: "debug", verbose: verbose)
        guard built else { throw CLIError.buildFailed }

        let binaryURL = try locateExecutable()

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.runServer(binaryURL: binaryURL)
            }

            if !self.noHotReload {
                group.addTask {
                    await self.watchForChanges(binaryURL: binaryURL)
                }
            }

            try await group.next()
            group.cancelAll()
        }
    }

    // MARK: - Server

    private func runServer(binaryURL: URL) async throws {
        let process = Process()
        process.executableURL = binaryURL
        process.arguments = ["--host", host, "--port", "\(port)", "--dev"]
        process.environment = ProcessInfo.processInfo.environment
            .merging(["SCORE_DEV_RELOAD": "1"]) { _, new in new }
        try process.run()
        process.waitUntilExit()
        Noora().warning(.alert("Server exited with status \(process.terminationStatus)"))
    }

    // MARK: - File watcher

    private func watchForChanges(binaryURL: URL) async {
        let directories = [
            URL(fileURLWithPath: "Sources"),
            URL(fileURLWithPath: "Content"),
            URL(fileURLWithPath: "Public"),
        ].filter { FileManager.default.fileExists(atPath: $0.path) }

        var lastModDates: [URL: Date] = [:]

        while !Task.isCancelled {
            let changed = pollChanges(in: directories, lastDates: &lastModDates)
            if !changed.isEmpty {
                let noora = Noora()
                for url in changed {
                    noora.passthrough("↻  \(url.lastPathComponent)")
                }
                if let _ = try? await buildPackage(configuration: "debug", verbose: verbose) {
                    noora.success(.alert("Rebuilt — reload your browser"))
                }
            }
            try? await Task.sleep(for: .milliseconds(500))
        }
    }

    private func pollChanges(
        in directories: [URL],
        lastDates: inout [URL: Date]
    ) -> [URL] {
        var changed: [URL] = []
        let fm = FileManager.default

        for dir in directories {
            guard let enumerator = fm.enumerator(
                at: dir,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            ) else { continue }

            while let fileURL = enumerator.nextObject() as? URL {
                guard let attrs = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
                      let modDate = attrs.contentModificationDate else { continue }

                if let last = lastModDates[fileURL], modDate > last {
                    lastModDates[fileURL] = modDate
                    changed.append(fileURL)
                } else if lastModDates[fileURL] == nil {
                    lastModDates[fileURL] = modDate
                }
            }
        }
        return changed
    }
}

// MARK: - BuildCommand

/// `score build` — generate a static site from all `StaticPage` routes.
///
/// Compiles the app in release mode, renders every ``StaticPage`` route to
/// HTML, collects and fingerprints CSS, copies the `Public/` directory, and
/// writes an `asset-manifest.json`.
struct BuildCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the site to .score/build/."
    )

    @Flag(name: .long, help: "Skip minification (faster but larger output).")
    var noMinify: Bool = false

    @Flag(name: .long, help: "Skip asset fingerprinting.")
    var noFingerprint: Bool = false

    @Flag(name: .long, help: "Verbose compiler output.")
    var verbose: Bool = false

    @Option(name: .long, help: "Output directory (default: .score/build).")
    var output: String = ".score/build"

    mutating func run() async throws {
        let noora = Noora()
        let start = Date()

        let built = try await buildPackage(configuration: "release", verbose: verbose)
        guard built else { throw CLIError.buildFailed }

        let binaryURL = try locateExecutable()
        var args = ["--build-only", "--output", output]
        if noMinify { args.append("--no-minify") }
        if noFingerprint { args.append("--no-fingerprint") }

        let process = Process()
        process.executableURL = binaryURL
        process.arguments = args
        try process.run()
        process.waitUntilExit()

        let elapsed = String(format: "%.2f", Date().timeIntervalSince(start))
        if process.terminationStatus == 0 {
            noora.success(.alert("Built in \(elapsed)s", takeaways: ["\(output)"]))
        } else {
            throw CLIError.buildFailed
        }
    }
}
