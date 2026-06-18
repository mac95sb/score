import Foundation

/// A type that contributes routes to the application's router.
///
/// The `routes` requirement is a ``RouteBuilder``, so conformers list route
/// expressions directly — `Page`, `GET`, `POST`, nested ``RouteGroup``s, or
/// other `RouteCollection` values:
///
/// ```swift
/// struct PostsController: RouteCollection {
///     var routes: [Route] {
///         RouteGroup("/blog") {
///             Page("/")      { req in BlogIndexPage(posts: try await loadPosts()) }
///             Page("/:slug") { req in try await loadPost(req) }
///         }
///         RouteGroup(api: "/posts") {
///             GET("/") { req in try Response.json(try await loadPosts()) }
///         }
///     }
/// }
/// ```
public protocol RouteCollection: Sendable {
    /// The routes contributed by this collection.
    @RouteBuilder var routes: [Route] { get }
}

// MARK: - Array conformance

/// `[Route]` is itself a `RouteCollection`, which lets ``RouteBuilder`` output
/// satisfy `some RouteCollection` requirements (such as `Application.routes`).
extension Array: RouteCollection where Element == Route {
    // The explicit `return` suppresses the result-builder transform that would
    // otherwise recurse through `buildExpression(_: any RouteCollection)`.
    public var routes: [Route] { self }
}
