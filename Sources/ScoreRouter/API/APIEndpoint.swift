import Foundation

/// A typed descriptor for an API endpoint.
///
/// Define endpoint descriptors as static constants so the HTTP method and path
/// live in exactly one place. Reference the same descriptor in both route
/// registration and `@Fetch` declarations — mismatches between the body type
/// and response type are caught by the compiler, not at runtime:
///
/// ```swift
/// // Sources/API/Endpoints.swift
/// enum Posts {
///     static let list   = APIEndpoint<Void,       [Post]>(    .GET,    "/posts")
///     static let read   = APIEndpoint<Void,        Post>(     .GET,    "/posts/:id")
///     static let create = APIEndpoint<CreatePost,  Post>(     .POST,   "/posts")
///     static let update = APIEndpoint<UpdatePost,  Post>(     .PATCH,  "/posts/:id")
///     static let delete = APIEndpoint<Void,        Void>(     .DELETE, "/posts/:id")
/// }
/// ```
///
/// Register using the descriptor:
///
/// ```swift
/// RouteGroup(api: "/") {
///     GET(Posts.list,   handle: list)
///     GET(Posts.read,   handle: read)
///     POST(Posts.create, handle: create)
///     PATCH(Posts.update, handle: update)
///     DELETE(Posts.delete, handle: destroy)
/// }
/// ```
///
/// Reference the same descriptor in reactive views:
///
/// ```swift
/// struct BlogIndex: Page {
///     @Fetch(Posts.list) var posts: [Post]
/// }
/// ```
public struct APIEndpoint<Body: Sendable, ResponseValue: Sendable>: Sendable {
    public let method: Route.Method
    public let path: String

    public init(_ method: Route.Method, _ path: String) {
        self.method = method
        self.path = path
    }
}
