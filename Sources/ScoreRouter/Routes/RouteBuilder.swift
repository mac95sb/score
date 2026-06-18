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
        [
            Route(
                method: .GET,
                pathPattern: "/__score/static/\(String(describing: P.self))",
                renderMode: .static,
                staticPageType: pageType,
                handler: { _ in Response(status: .notFound) }
            )
        ]
    }

    public static func buildOptional(_ component: [Route]?) -> [Route] { component ?? [] }

    public static func buildEither(first: [Route]) -> [Route] { first }

    public static func buildEither(second: [Route]) -> [Route] { second }

    public static func buildArray(_ components: [[Route]]) -> [Route] {
        components.flatMap { $0 }
    }
}

// MARK: - Route constructor functions

/// A GET route that renders a ``Page`` as a complete HTML document.
///
/// The render mode defaults to `.static` (build-time), suitable for pages that
/// do not depend on per-request data. Pass `.serverRendered` for dynamic pages.
///
/// The page factory is stored on the route so the Score runtime can render it
/// through `PageRenderer` (full document shell + theme CSS + component CSS).
public func Page<P: ScoreCore.Page>(
    _ path: String,
    mode: RenderMode = .static,
    handler: @escaping @Sendable (Request) async throws -> P
) -> Route {
    Route(
        method: .GET,
        pathPattern: path,
        renderMode: mode,
        pageFactory: { req in try await handler(req) }
    ) { req in
        // Bare fallback used when the route handler is called directly without
        // the runtime's PageRenderer wrapping (e.g. in tests).
        let page = try await handler(req)
        return Response(status: .ok, body: .html(HTMLRenderer().render(page)))
    }
}

/// A GET route that renders a parameter-free ``Page`` as a complete HTML document.
public func Page<P: ScoreCore.Page>(
    _ path: String,
    mode: RenderMode = .static,
    handler: @escaping @Sendable () -> P
) -> Route {
    Route(
        method: .GET,
        pathPattern: path,
        renderMode: mode,
        pageFactory: { _ in handler() }
    ) { _ in
        let page = handler()
        return Response(status: .ok, body: .html(HTMLRenderer().render(page)))
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

// MARK: - Typed endpoint overloads

/// A GET route bound to a typed ``APIEndpoint`` descriptor.
///
/// The method and path are taken from the descriptor — no string duplication:
///
/// ```swift
/// GET(Posts.list, handle: list)
/// ```
public func GET<B: Sendable, R: Sendable>(
    _ endpoint: APIEndpoint<B, R>,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .GET, pathPattern: endpoint.path, renderMode: .serverRendered, handler: handler)
}

/// A POST route bound to a typed ``APIEndpoint`` descriptor.
public func POST<B: Sendable, R: Sendable>(
    _ endpoint: APIEndpoint<B, R>,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .POST, pathPattern: endpoint.path, renderMode: .serverRendered, handler: handler)
}

/// A PUT route bound to a typed ``APIEndpoint`` descriptor.
public func PUT<B: Sendable, R: Sendable>(
    _ endpoint: APIEndpoint<B, R>,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .PUT, pathPattern: endpoint.path, renderMode: .serverRendered, handler: handler)
}

/// A PATCH route bound to a typed ``APIEndpoint`` descriptor.
public func PATCH<B: Sendable, R: Sendable>(
    _ endpoint: APIEndpoint<B, R>,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .PATCH, pathPattern: endpoint.path, renderMode: .serverRendered, handler: handler)
}

/// A DELETE route bound to a typed ``APIEndpoint`` descriptor.
public func DELETE<B: Sendable, R: Sendable>(
    _ endpoint: APIEndpoint<B, R>,
    handle handler: @escaping @Sendable (Request) async throws -> Response
) -> Route {
    Route(method: .DELETE, pathPattern: endpoint.path, renderMode: .serverRendered, handler: handler)
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
