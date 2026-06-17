/// A WebSocket route entry passed to `NIOServer` for HTTP → WS upgrade wiring.
public struct WebSocketRoute: Sendable {
    public let path: String
    public let handler: @Sendable (WebSocket, Request) async throws -> Void

    public init(
        path: String,
        handler: @escaping @Sendable (WebSocket, Request) async throws -> Void
    ) {
        self.path = path
        self.handler = handler
    }
}
