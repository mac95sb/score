import Foundation
import ScoreCore
import ScoreHTTP

/// A group of routes sharing a URL prefix and optional middleware.
///
/// ```swift
/// // Plain prefix group
/// RouteGroup("/blog") {
///     Page("/")       { BlogIndexPage() }
///     Page("/:slug")  { req in BlogPostPage(slug: try req.pathParameter("slug")) }
/// }
///
/// // API-prefixed group (resolves to /api/v1/posts by default)
/// RouteGroup(api: "/posts") {
///     GET("/")  { req in try Response.json(posts) }
///     POST("/") { req in try Response.created(newPost) }
/// }
/// ```
public struct RouteGroup: RouteCollection {
    let prefix: String
    private var children: [Route]

    // MARK: - Init with plain prefix

    public init(_ prefix: String, @RouteBuilder content: () -> [Route]) {
        self.prefix = prefix
        self.children = content().map { route in
            Route(
                method: route.method,
                pathPattern: prefix + route.pathPattern,
                renderMode: route.renderMode,
                middleware: route.middleware,
                staticPageType: route.staticPageType,
                webSocketHandler: route.webSocketHandler,
                handler: route.handler
            )
        }
    }

    // MARK: - Init with API prefix

    /// Create a group whose path is automatically prefixed by `apiPrefix`.
    ///
    /// - Parameters:
    ///   - path: Path segment appended after the API prefix (e.g. `"/posts"`).
    ///   - apiPrefix: API version prefix; defaults to `.v1` (`/api/v1`).
    public init(
        api path: String,
        apiPrefix: APIPrefix = .v1,
        @RouteBuilder content: () -> [Route]
    ) {
        let fullPrefix = apiPrefix.combined(with: path)
        self.init(fullPrefix, content: content)
    }

    // MARK: - RouteCollection

    // The explicit `return` suppresses the result-builder transform applied to
    // witnesses of the `@RouteBuilder` protocol requirement.
    // swift-format-ignore
    public var routes: [Route] { return children }

    // MARK: - Middleware attachment

    /// Return a copy of this group with additional middleware prepended to every route.
    public func middleware(_ middleware: any Middleware...) -> RouteGroup {
        var copy = self
        copy.children = children.map { route in
            Route(
                method: route.method,
                pathPattern: route.pathPattern,
                renderMode: route.renderMode,
                middleware: Array(middleware) + route.middleware,
                staticPageType: route.staticPageType,
                webSocketHandler: route.webSocketHandler,
                handler: route.handler
            )
        }
        return copy
    }
}
