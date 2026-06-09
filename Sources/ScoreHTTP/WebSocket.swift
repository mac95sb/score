import Foundation
import NIO
import NIOWebSocket

/// A WebSocket connection managed by a Score server.
///
/// Instances are vended by the WebSocket upgrade machinery in `NIOServer`.
/// Send text or binary frames, or close the connection gracefully.
public actor WebSocket {
    private let channel: Channel

    init(channel: Channel) { self.channel = channel }

    /// Send a UTF-8 text frame.
    public func send(_ text: String) async throws {
        var buffer = channel.allocator.buffer(capacity: text.utf8.count)
        buffer.writeString(text)
        let frame = WebSocketFrame(fin: true, opcode: .text, data: buffer)
        try await channel.writeAndFlush(frame).get()
    }

    /// Send a binary frame.
    public func send(_ data: [UInt8]) async throws {
        var buffer = channel.allocator.buffer(bytes: data)
        let frame = WebSocketFrame(fin: true, opcode: .binary, data: buffer)
        try await channel.writeAndFlush(frame).get()
    }

    /// Close the WebSocket connection with the given close code.
    public func close(code: CloseCode = .normalClosure) async throws {
        try await channel.close().get()
    }

    /// WebSocket close codes (RFC 6455 §7.4).
    public enum CloseCode: UInt16, Sendable {
        case normalClosure = 1000
        case goingAway = 1001
        case protocolError = 1002
        case unsupportedData = 1003
    }
}
