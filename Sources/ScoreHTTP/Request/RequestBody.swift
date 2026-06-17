import NIOCore
import Foundation

/// The body of an incoming HTTP request.
public struct RequestBody: Sendable {
    private let bytes: [UInt8]

    public init(bytes: [UInt8]) { self.bytes = bytes }
    public init(data: Data) { self.bytes = Array(data) }
    public static let empty = RequestBody(bytes: [])

    /// The raw bytes.
    public var data: Data { Data(bytes) }

    /// Decoded as UTF-8 string.
    public var string: String? { String(bytes: bytes, encoding: .utf8) }

    /// Total byte count.
    public var count: Int { bytes.count }

    /// Decode the body as JSON into the given type.
    public func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = .init()) throws -> T {
        try decoder.decode(type, from: data)
    }

    /// Collect from a NIO ByteBuffer.
    public init(buffer: ByteBuffer) {
        var buf = buffer
        self.bytes = buf.readBytes(length: buf.readableBytes) ?? []
    }
}
