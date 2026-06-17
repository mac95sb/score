import Foundation
import ScoreCore
import ScoreHTTP

/// The central route registry and request dispatcher.
///
/// Register routes via `RouteCollection` conformances or directly with
/// `register(_:)`. Dispatch incoming requests with `handle(_:)`.
///
/// ```swift
/// let router = Router(globalMiddleware: [LoggingMiddleware(), SecurityHeadersMiddleware()])
/// await router.register(PostsController())
/// await router.register(AuthController())
///
/// let server = NIOServer(port: 8080) { req in
///     try await router.handle(req)
/// }
/// ```
public actor Router {
    private struct RegisteredRoute {
        let route: Route
        let matcher: PathMatcher
    }

    private var registered: [RegisteredRoute] = []
    private let globalMiddleware: [any Middleware]

    public init(globalMiddleware: [any Middleware] = []) {
        self.globalMiddleware = globalMiddleware
    }

    // MARK: - Registration

    /// Append all routes from a `RouteCollection`.
    public func register(_ collection: any RouteCollection) {
        for route in collection.routes {
            registered.append(RegisteredRoute(route: route, matcher: PathMatcher(pattern: route.pathPattern)))
        }
    }

    /// Append a single route directly.
    public func register(_ route: Route) {
        registered.append(RegisteredRoute(route: route, matcher: PathMatcher(pattern: route.pathPattern)))
    }

    // MARK: - Dispatch

    /// Match `request` to a registered route and execute its middleware + handler.
    ///
    /// Throws `HTTPError(.notFound)` when no route matches.
    public func handle(_ request: Request) async throws -> Response {
        guard let match = findMatch(for: request) else {
            return Response.notFound(
                "No route found for \(request.method) \(request.uri.path)"
            )
        }

        var req = request
        req.pathParameters = match.parameters

        let allMiddleware = globalMiddleware + match.route.middleware
        let chain = MiddlewareChain(allMiddleware)
        let handler = match.route.handler

        return try await chain.execute(req) { r in
            try await handler(r)
        }
    }

    // MARK: - Introspection

    /// All registered routes — used by the `score routes` CLI command.
    public func allRoutes() -> [Route] { registered.map(\.route) }

    // MARK: - Private

    private func findMatch(for request: Request) -> RouteMatch? {
        for entry in registered {
            if let routeMethod = entry.route.method {
                guard request.method.rawValue == routeMethod.rawValue else { continue }
            }
            if let parameters = entry.matcher.match(path: request.uri.path) {
                return RouteMatch(route: entry.route, parameters: parameters)
            }
        }
        return nil
    }
}
