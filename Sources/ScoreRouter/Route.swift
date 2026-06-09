import Foundation
import ScoreHTTP

/// A single registered route entry.
public struct Route: Sendable {
    /// HTTP method for this route. `nil` means any method (used for WebSocket routes).
    public enum Method: String, Sendable, CaseIterable {
        case GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
    }

    public let method: Method?
    public let pathPattern: String
    public let renderMode: RenderMode
    public let middleware: [any Middleware]

    /// The route handler: receives a `Request` and returns a `Response`.
    public let handler: @Sendable (Request) async throws -> Response

    public init(
        method: Method?,
        pathPattern: String,
        renderMode: RenderMode = .serverRendered,
        middleware: [any Middleware] = [],
        handler: @escaping @Sendable (Request) async throws -> Response
    ) {
        self.method = method
        self.pathPattern = pathPattern
        self.renderMode = renderMode
        self.middleware = middleware
        self.handler = handler
    }
}
