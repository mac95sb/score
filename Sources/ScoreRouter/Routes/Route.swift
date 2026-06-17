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

    /// When set, this route was declared with `Page()` and stores the original
    /// page factory so the runtime can render it through `PageRenderer` (full
    /// document shell + theme CSS + component CSS) rather than bare `HTMLRenderer`.
    public let pageFactory: (@Sendable (Request) async throws -> any Page)?

    public init(
        method: Method?,
        pathPattern: String,
        renderMode: RenderMode = .serverRendered,
        middleware: [any Middleware] = [],
        staticPageType: (any StaticPage.Type)? = nil,
        webSocketHandler: (@Sendable (WebSocket, Request) async throws -> Void)? = nil,
        pageFactory: (@Sendable (Request) async throws -> any Page)? = nil,
        handler: @escaping @Sendable (Request) async throws -> Response
    ) {
        self.method = method
        self.pathPattern = pathPattern
        self.renderMode = renderMode
        self.middleware = middleware
        self.staticPageType = staticPageType
        self.webSocketHandler = webSocketHandler
        self.pageFactory = pageFactory
        self.handler = handler
    }
}
