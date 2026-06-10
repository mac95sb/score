import Foundation
import ScoreCore
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

    /// When set, this route is a placeholder for a ``StaticPage`` type whose
    /// concrete paths are discovered at build/startup time via
    /// `StaticPage.instances()`.
    public let staticPageType: (any StaticPage.Type)?

    /// The WebSocket handler for routes created with `WS(_:handler:)`.
    /// Invoked after a successful HTTP → WebSocket upgrade.
    public let webSocketHandler: (@Sendable (WebSocket, Request) async throws -> Void)?

    public init(
        method: Method?,
        pathPattern: String,
        renderMode: RenderMode = .serverRendered,
        middleware: [any Middleware] = [],
        staticPageType: (any StaticPage.Type)? = nil,
        webSocketHandler: (@Sendable (WebSocket, Request) async throws -> Void)? = nil,
        handler: @escaping @Sendable (Request) async throws -> Response
    ) {
        self.method = method
        self.pathPattern = pathPattern
        self.renderMode = renderMode
        self.middleware = middleware
        self.staticPageType = staticPageType
        self.webSocketHandler = webSocketHandler
        self.handler = handler
    }
}
