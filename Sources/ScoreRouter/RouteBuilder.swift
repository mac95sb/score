import Foundation
import ScoreCore
import ScoreHTTP

// MARK: - Result Builder

/// Assembles heterogeneous route expressions into a flat `[Route]` array.
@resultBuilder
public struct RouteBuilder {
    // Variadic multi-expression block
    public static func buildBlock(_ components: [Route]...) -> [Route] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ route: Route) -> [Route] { [route] }

    public static func buildExpression(_ group: RouteGroup) -> [Route] { group.routes }

    public static func buildExpression(_ collection: any RouteCollection) -> [Route] {
        collection.routes
    }

    /// Register a ``StaticPage`` type directly (e.g. `BlogPostPage.self`).
    ///
    /// The page's concrete paths are resolved at build/startup time by calling
    /// `StaticPage.instances()`; until then the route is a placeholder carrying
    /// the page type in ``Route/staticPageType``.
    public static func buildExpression<P: StaticPage>(_ pageType: P.Type) -> [Route] {
        [Route(
            method: .GET,
            pathPattern: "/__score/static/\(String(describing: P.self))",
            renderMode: .static,
            staticPageType: pageType,
            handler: { _ in Response(status: .notFound) }
        )]
    }

    public static func buildOptional(_ component: [Route]?) -> [Route] { component ?? [] }

    public static func buildEither(first: [Route]) -> [Route] { first }

    public static func buildEither(second: [Route]) -> [Route] { second }

    public static func buildArray(_ components: [[Route]]) -> [Route] {
        components.flatMap { $0 }
    }
}

// MARK: - Route constructor functions

/// A GET route that renders a `View` as HTML.
///
/// The render mode defaults to `.static` (build-time), suitable for pages that
/// do not depend on per-request data. Pass `.serverRendered` for dynamic pages.
public func Page(
    _ path: String,
    mode: RenderMode = .static,
    handler: @escaping @Sendable (Request) async throws -> some View
) -> Route {
    Route(method: .GET, pathPattern: path, renderMode: mode) { req in
        let view = try await handler(req)
        return Response.html(view)
    }
}

/// A GET route that renders a parameter-free `View` as HTML.
public func Page(
    _ path: String,
    mode: RenderMode = .static,
    handler: @escaping @Sendable () -> some View
) -> Route {
    Route(method: .GET, pathPattern: path, renderMode: mode) { _ in
        let view = handler()
        return Response.html(view)
    }
}

/// A GET endpoint returning a `Response`.
public func GET(
    _ path: String,
    mode: RenderMode = .serverRendered,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .GET, pathPattern: path, renderMode: mode, handler: handler)
}

/// A POST endpoint.
public func POST(
    _ path: String,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .POST, pathPattern: path, renderMode: .serverRendered, handler: handler)
}

/// A PUT endpoint.
public func PUT(
    _ path: String,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .PUT, pathPattern: path, renderMode: .serverRendered, handler: handler)
}

/// A PATCH endpoint.
public func PATCH(
    _ path: String,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .PATCH, pathPattern: path, renderMode: .serverRendered, handler: handler)
}

/// A DELETE endpoint.
public func DELETE(
    _ path: String,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .DELETE, pathPattern: path, renderMode: .serverRendered, handler: handler)
}

/// A WebSocket upgrade route.
///
/// The handler is invoked after a successful HTTP → WebSocket upgrade.
/// Route registration uses `method: nil` so the router skips HTTP-method
/// matching and lets the NIO upgrade machinery take over.
public func WS(
    _ path: String,
    handler: @escaping @Sendable (WebSocket, Request) async throws -> Void
) -> Route {
    Route(
        method: nil,
        pathPattern: path,
        renderMode: .serverRendered,
        webSocketHandler: handler
    ) { req in
        // The stored `webSocketHandler` is invoked by the server after the
        // HTTP → WebSocket upgrade; a plain HTTP request to this path gets 426.
        Response(status: .upgradeRequired)
    }
}
