import NIO
import NIOWebSocket

/// NIO channel handler installed after a successful HTTP → WebSocket upgrade.
///
/// Handles ping/pong automatically, relays text and binary frames to the
/// `WebSocket` actor's `messages` stream, and invokes the user-supplied
/// handler as a `Task` when the handler is first added to the pipeline.
final class WebSocketFrameHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame

    private let webSocket: WebSocket
    private let request: Request
    private let userHandler: (@Sendable (WebSocket, Request) async throws -> Void)?

    init(
        webSocket: WebSocket,
        request: Request,
        handler: (@Sendable (WebSocket, Request) async throws -> Void)?
    ) {
        self.webSocket = webSocket
        self.request = request
        self.userHandler = handler
    }

    func handlerAdded(context: ChannelHandlerContext) {
        guard let userHandler else { return }
        let ws = webSocket
        let req = request
        Task { try? await userHandler(ws, req) }
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = unwrapInboundIn(data)

        switch frame.opcode {
        case .ping:
            let pong = WebSocketFrame(fin: true, opcode: .pong, data: frame.data)
            context.writeAndFlush(wrapOutboundOut(pong), promise: nil)

        case .connectionClose:
            // Echo the close frame back, then close the channel.
            let close = WebSocketFrame(fin: true, opcode: .connectionClose, data: frame.data)
            context.writeAndFlush(wrapOutboundOut(close)).whenComplete { _ in
                context.close(promise: nil)
            }
            let ws = webSocket
            Task { await ws.finish() }

        case .text:
            var buf = frame.unmaskedData
            let text = buf.readString(length: buf.readableBytes) ?? ""
            let ws = webSocket
            Task { await ws.yield(.text(text)) }

        case .binary:
            let bytes = Array(frame.unmaskedData.readableBytesView)
            let ws = webSocket
            Task { await ws.yield(.binary(bytes)) }

        default:
            break
        }
    }

    func channelInactive(context: ChannelHandlerContext) {
        let ws = webSocket
        Task { await ws.finish() }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        let ws = webSocket
        Task { await ws.finish() }
        context.close(promise: nil)
    }
}
