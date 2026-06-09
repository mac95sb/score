import Foundation

/// A type that contributes routes to the application's router.
///
/// ```swift
/// struct PostsController: RouteCollection {
///     var routes: [Route] {
///         [
///             Route(method: .GET,  pathPattern: "/posts",     handler: list),
///             Route(method: .GET,  pathPattern: "/posts/:id", handler: show),
///             Route(method: .POST, pathPattern: "/posts",     handler: create),
///         ]
///     }
/// }
/// ```
public protocol RouteCollection: Sendable {
    var routes: [Route] { get }
}
