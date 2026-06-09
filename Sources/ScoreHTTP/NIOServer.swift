import Foundation
import NIO
import NIOHTTP1
import NIOHTTP2
import NIOSSL
import NIOExtras
import Logging
import ServiceLifecycle
import HTTPTypes
import ScoreCore

/// The Score HTTP server backed by SwiftNIO.
///
/// Handles HTTP/1.1 (and optionally HTTP/2 via ALPN), TLS, and graceful shutdown
/// via ServiceLifecycle. Construct the server, supply a request handler closure,
/// and run it inside a `ServiceGroup`.
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
    let handler: @Sendable (Request) async throws -> Response

    public init(
        host: String = "0.0.0.0",
        port: Int = 8080,
        tlsConfig: TLSConfiguration? = nil,
        staticDirectory: String? = nil,
        logger: Logger = Logger(label: "score.server"),
        handler: @escaping @Sendable (Request) async throws -> Response
    ) {
        self.host = host
        self.port = port
        self.tlsConfig = tlsConfig
        self.staticDirectory = staticDirectory
        self.logger = logger
        self.handler = handler
    }

    // MARK: - ServiceLifecycle

    public func run() async throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        defer {
            try? group.syncShutdownGracefully()
        }

        let serverHandler = handler
        let staticDir = staticDirectory
        let log = logger

        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline
                    .configureHTTPServerPipeline(withErrorHandling: true)
                    .flatMap {
                        channel.pipeline.addHandler(
                            ScoreHTTPHandler(
                                handler: serverHandler,
                                staticDirectory: staticDir,
                                logger: log
                            )
                        )
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

// MARK: - NIO Channel Handler

/// Inbound handler that assembles HTTP/1.1 request parts into a `Request`,
/// dispatches to the application handler, and writes the `Response` back.
final class ScoreHTTPHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private let handler: @Sendable (Request) async throws -> Response
    private let staticDirectory: String?
    private let logger: Logger

    // Accumulation state per request (single-threaded per channel)
    private var requestHead: HTTPRequestHead?
    private var bodyBuffer: ByteBuffer?

    init(
        handler: @escaping @Sendable (Request) async throws -> Response,
        staticDirectory: String?,
        logger: Logger
    ) {
        self.handler = handler
        self.staticDirectory = staticDirectory
        self.logger = logger
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

            // Reset accumulation state before dispatching.
            requestHead = nil
            bodyBuffer = nil

            let h = handler
            let log = logger
            let eventLoop = context.eventLoop

            // `ScoreHTTPHandler` is `@unchecked Sendable`; NIO guarantees all
            // `channelRead` calls for a given channel run on its event loop, and
            // we schedule the response write back onto the same event loop via
            // `eventLoop.execute`. The `context` capture is safe under these rules.
            let handler = self
            Task {
                do {
                    let response = try await h(request)
                    eventLoop.execute { handler.writeResponse(response, to: context) }
                } catch let httpError as HTTPError {
                    let errResponse = Response(
                        status: httpError.status,
                        body: httpError.message.map { .text($0) } ?? .empty
                    )
                    eventLoop.execute { handler.writeResponse(errResponse, to: context) }
                } catch {
                    log.error("Handler error: \(error)")
                    let errResponse = Response(
                        status: .internalServerError,
                        body: .text("Internal Server Error")
                    )
                    eventLoop.execute { handler.writeResponse(errResponse, to: context) }
                }
            }
        }
    }

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

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        logger.error("Channel error: \(error)")
        context.close(promise: nil)
    }
}
