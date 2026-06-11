import Foundation
import NIO
import NIOHTTP1
import NIOHTTP2
import NIOSSL
import NIOExtras
import NIOWebSocket
import Logging
import ServiceLifecycle
import HTTPTypes
import ScoreCore

/// The Score HTTP server backed by SwiftNIO.
///
/// Handles HTTP/1.1, optional TLS, graceful shutdown via ServiceLifecycle,
/// Server-Sent Events (`/__score/dev`) for dev-mode hot-reload, and
/// WebSocket upgrades for `WS()` routes.
///
/// ```swift
/// let server = NIOServer(port: 8080) { request in
///     try await router.handle(request)
/// }
/// try await ServiceGroup(services: [server], logger: logger).run()
/// ```
public actor NIOServer: Service {
    let host: String
    let port: Int
    let tlsConfig: TLSConfiguration?
    let staticDirectory: String?
    let logger: Logger
    let sseBroadcaster: SSEBroadcaster?
    let webSocketRoutes: [WebSocketRoute]
    let handler: @Sendable (Request) async throws -> Response

    public init(
        host: String = "0.0.0.0",
        port: Int = 8080,
        tlsConfig: TLSConfiguration? = nil,
        staticDirectory: String? = nil,
        logger: Logger = Logger(label: "score.server"),
        sseBroadcaster: SSEBroadcaster? = nil,
        webSocketRoutes: [WebSocketRoute] = [],
        handler: @escaping @Sendable (Request) async throws -> Response
    ) {
        self.host = host
        self.port = port
        self.tlsConfig = tlsConfig
        self.staticDirectory = staticDirectory
        self.logger = logger
        self.sseBroadcaster = sseBroadcaster
        self.webSocketRoutes = webSocketRoutes
        self.handler = handler
    }

    // MARK: - ServiceLifecycle

    public func run() async throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        defer { try? group.syncShutdownGracefully() }

        let serverHandler = handler
        let staticDir = staticDirectory
        let log = logger
        let broadcasterCopy = sseBroadcaster
        let wsRoutesCopy = webSocketRoutes

        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                let httpHandler = ScoreHTTPHandler(
                    handler: serverHandler,
                    staticDirectory: staticDir,
                    logger: log,
                    sseBroadcaster: broadcasterCopy
                )

                if !wsRoutesCopy.isEmpty {
                    let upgrader = NIOWebSocketServerUpgrader(
                        shouldUpgrade: { (ch, head) in
                            let match = wsRoutesCopy.contains { $0.path == head.uri }
                            return ch.eventLoop.makeSucceededFuture(match ? HTTPHeaders() : nil)
                        },
                        upgradePipelineHandler: { (ch, head) in
                            let ws = WebSocket(channel: ch)
                            let req = Request(method: .get, uri: URI(string: head.uri))
                            let wsHandler = wsRoutesCopy.first { $0.path == head.uri }?.handler
                            return ch.pipeline.addHandler(
                                WebSocketFrameHandler(webSocket: ws, request: req, handler: wsHandler)
                            )
                        }
                    )
                    return channel.pipeline.configureHTTPServerPipeline(
                        withServerUpgrade: (upgraders: [upgrader], completionHandler: { _ in }),
                        withErrorHandling: true
                    ).flatMap {
                        channel.pipeline.addHandler(httpHandler)
                    }
                } else {
                    return channel.pipeline
                        .configureHTTPServerPipeline(withErrorHandling: true)
                        .flatMap { channel.pipeline.addHandler(httpHandler) }
                }
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        let channel = try await bootstrap.bind(host: host, port: port).get()
        log.info("Score server listening on \(host):\(port)")

        try await withTaskCancellationHandler {
            try await channel.closeFuture.get()
        } onCancel: {
            channel.close(promise: nil)
        }
    }
}

// MARK: - HTTP Channel Handler

/// Assembles HTTP/1.1 request parts, dispatches to the application handler,
/// and writes responses back. Handles SSE for `/__score/dev` when a
/// broadcaster is configured.
final class ScoreHTTPHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private let handler: @Sendable (Request) async throws -> Response
    private let staticDirectory: String?
    private let logger: Logger
    private let sseBroadcaster: SSEBroadcaster?

    private var requestHead: HTTPRequestHead?
    private var bodyBuffer: ByteBuffer?

    init(
        handler: @escaping @Sendable (Request) async throws -> Response,
        staticDirectory: String?,
        logger: Logger,
        sseBroadcaster: SSEBroadcaster?
    ) {
        self.handler = handler
        self.staticDirectory = staticDirectory
        self.logger = logger
        self.sseBroadcaster = sseBroadcaster
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let part = unwrapInboundIn(data)

        switch part {
        case .head(let head):
            requestHead = head
            bodyBuffer = context.channel.allocator.buffer(capacity: 256)

        case .body(var buf):
            bodyBuffer?.writeBuffer(&buf)

        case .end:
            guard let head = requestHead else { return }
            let bodyBytes = bodyBuffer.map { Array($0.readableBytesView) } ?? []
            let request = buildRequest(from: head, bodyBytes: bodyBytes)
            requestHead = nil
            bodyBuffer = nil

            // SSE dev-reload endpoint — keep connection alive.
            if head.uri == "/__score/dev", let broadcaster = sseBroadcaster {
                startSSEStream(context: context, broadcaster: broadcaster)
                return
            }

            let h = handler
            let log = logger
            let staticDir = staticDirectory
            let eventLoop = context.eventLoop
            let httpHandler = self

            Task {
                if let staticDir, head.method == .GET {
                    let urlPath = request.uri.path
                    let rel = urlPath == "/" ? "index.html" : String(urlPath.drop(while: { $0 == "/" }))
                    let fileURL = URL(fileURLWithPath: staticDir).appendingPathComponent(rel)
                    if let staticResponse = httpHandler.serveStaticFile(at: fileURL) {
                        eventLoop.execute { httpHandler.writeResponse(staticResponse, to: context) }
                        return
                    }
                }
                do {
                    let response = try await h(request)
                    eventLoop.execute { httpHandler.writeResponse(response, to: context) }
                } catch let httpError as HTTPError {
                    let errResponse = Response(
                        status: httpError.status,
                        body: httpError.message.map { .text($0) } ?? .empty
                    )
                    eventLoop.execute { httpHandler.writeResponse(errResponse, to: context) }
                } catch {
                    log.error("Handler error: \(error)")
                    let errResponse = Response(status: .internalServerError, body: .text("Internal Server Error"))
                    eventLoop.execute { httpHandler.writeResponse(errResponse, to: context) }
                }
            }
        }
    }

    // MARK: - SSE

    private func startSSEStream(context: ChannelHandlerContext, broadcaster: SSEBroadcaster) {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "text/event-stream")
        headers.add(name: "Cache-Control", value: "no-cache")
        headers.add(name: "Connection", value: "keep-alive")
        headers.add(name: "X-Accel-Buffering", value: "no")
        headers.add(name: "Access-Control-Allow-Origin", value: "*")

        let head = HTTPResponseHead(version: .http1_1, status: .ok, headers: headers)
        context.write(wrapOutboundOut(.head(head)), promise: nil)

        var buf = context.channel.allocator.buffer(capacity: 32)
        buf.writeString("data: connected\n\n")
        context.writeAndFlush(wrapOutboundOut(.body(.byteBuffer(buf))), promise: nil)

        broadcaster.addChannel(context.channel)
    }

    // MARK: - Helpers

    private func buildRequest(from head: HTTPRequestHead, bodyBytes: [UInt8]) -> Request {
        let method = HTTPRequest.Method(rawValue: head.method.rawValue) ?? .get
        var fields = HTTPFields()
        for (name, value) in head.headers {
            if let fieldName = HTTPField.Name(name) {
                fields[fieldName] = value
            }
        }
        return Request(
            method: method,
            uri: URI(string: head.uri),
            headers: fields,
            body: RequestBody(bytes: bodyBytes)
        )
    }

    private func writeResponse(_ response: Response, to context: ChannelHandlerContext) {
        let bodyData = response.body.bytes

        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: response.body.contentType)
        headers.add(name: "Content-Length", value: "\(bodyData.count)")
        headers.add(name: "Server", value: "Score")
        for (name, value) in response.headers {
            headers.add(name: name, value: value)
        }

        let head = HTTPResponseHead(
            version: .http1_1,
            status: HTTPResponseStatus(statusCode: response.status.rawValue),
            headers: headers
        )

        context.write(wrapOutboundOut(.head(head)), promise: nil)

        if !bodyData.isEmpty {
            var buffer = context.channel.allocator.buffer(capacity: bodyData.count)
            buffer.writeBytes(bodyData)
            context.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        }

        context.writeAndFlush(wrapOutboundOut(.end(nil)), promise: nil)
    }

    private func serveStaticFile(at url: URL) -> Response? {
        guard FileManager.default.isReadableFile(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return Response(status: .ok, body: .data(data, contentType: mimeType(for: url.pathExtension)))
    }

    private func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html", "htm": return "text/html; charset=utf-8"
        case "css":         return "text/css; charset=utf-8"
        case "js", "mjs":   return "application/javascript; charset=utf-8"
        case "json":        return "application/json"
        case "png":         return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif":         return "image/gif"
        case "svg":         return "image/svg+xml"
        case "ico":         return "image/x-icon"
        case "woff":        return "font/woff"
        case "woff2":       return "font/woff2"
        case "ttf":         return "font/ttf"
        case "webp":        return "image/webp"
        case "mp4":         return "video/mp4"
        case "webm":        return "video/webm"
        case "pdf":         return "application/pdf"
        case "txt":         return "text/plain; charset=utf-8"
        case "xml":         return "application/xml"
        default:            return "application/octet-stream"
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        logger.error("Channel error: \(error)")
        context.close(promise: nil)
    }
}
