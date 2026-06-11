import Foundation
import NIO
import NIOWebSocket

/// A WebSocket connection managed by a Score server.
///
/// Vended by the WS upgrade machinery in `NIOServer`. Send text or binary
/// frames via `send(_:)`, iterate incoming messages via `messages`, and close
/// gracefully with `close(code:)`.
///
/// ```swift
/// WS("/chat") { ws, req in
///     for await message in ws.messages {
///         if case .text(let t) = message { try await ws.send(t) }
///     }
/// }
/// ```
public actor WebSocket {
    private let channel: Channel
    private let messageContinuation: AsyncStream<Message>.Continuation

    /// Async sequence of frames received from the client.
    public let messages: AsyncStream<Message>

    init(channel: Channel) {
        self.channel = channel
        var cont: AsyncStream<Message>.Continuation!
        self.messages = AsyncStream { cont = $0 }
        self.messageContinuation = cont
    }

    // MARK: - Called by WebSocketFrameHandler

    func yield(_ message: Message) {
        messageContinuation.yield(message)
    }

    func finish() {
        messageContinuation.finish()
    }

    // MARK: - Public send API

    /// Send a UTF-8 text frame.
    public func send(_ text: String) async throws {
        var buffer = channel.allocator.buffer(capacity: text.utf8.count)
        buffer.writeString(text)
        let frame = WebSocketFrame(fin: true, opcode: .text, data: buffer)
        try await channel.writeAndFlush(frame).get()
    }

    /// Send a binary frame.
    public func send(_ data: [UInt8]) async throws {
        let buffer = channel.allocator.buffer(bytes: data)
        let frame = WebSocketFrame(fin: true, opcode: .binary, data: buffer)
        try await channel.writeAndFlush(frame).get()
    }

    /// Close the WebSocket connection with the given close code.
    public func close(code: CloseCode = .normalClosure) async throws {
        try await channel.close().get()
    }

    // MARK: - Nested types

    /// A message received from the browser.
    public enum Message: Sendable {
        case text(String)
        case binary([UInt8])
    }

    /// WebSocket close codes (RFC 6455 §7.4).
    public enum CloseCode: UInt16, Sendable {
        case normalClosure = 1000
        case goingAway = 1001
        case protocolError = 1002
        case unsupportedData = 1003
    }
}
