# API Routes

Declare page routes and API endpoints with type-safe route collections.

## Overview

Routes live in `Sources/Controllers/`. Each controller is a struct conforming
to ``RouteCollection`` and owns all routes — both page-rendering and API — for
a given feature. Score infers intent from the return type: a handler returning
a ``View`` renders HTML; one returning ``Response`` serves data.

Collocate page routes and their API endpoints in the same controller file.
`PostsController.swift` owns `/blog` page routes and `/api/v1/posts` data
routes together — they concern the same domain object, so keeping them together
makes the surface area easy to reason about.

## Route Collections

```swift
// Sources/Controllers/PostsController.swift
struct PostsController: RouteCollection {
    var routes: [Route] {

        RouteGroup("/blog") {
            Page("/") { BlogIndexPage() }
            Page("/:slug") { req in
                guard
                    let post = try await db.query(Post.self)
                        .filter(\.slug == req.pathParameters["slug"]!)
                        .first()
                else { throw HTTPError.notFound }
                return BlogPostPage(post: post)
            }
        }

        RouteGroup(api: "/posts") {
            GET("/", handle: list)
            POST("/", handle: create)
            PATCH("/:id", handle: update)
            DELETE("/:id", handle: destroy)
        }
    }
}
```

## Page Routes vs API Routes

`Page()` communicates page intent and omits the redundant HTTP method. Use
explicit HTTP verb functions for data endpoints:

```swift
RouteGroup("/blog") {
    Page("/")         { BlogIndexPage() }       // GET → HTML
    Page("/:slug")    { req in ... }            // GET → HTML
}

RouteGroup(api: "/posts") {
    GET("/")          { req in ... }            // GET → JSON
    POST("/")         { req in ... }            // POST → JSON
    PATCH("/:id")     { req in ... }            // PATCH → JSON
    DELETE("/:id")    { req in ... }            // DELETE → 204
}
```

`req in` is only required when the handler needs path parameters.
Parameter-free pages use the label-free closure form.

## Extracted Handlers

Extract handler logic to methods on the controller when inline closures grow:

```swift
struct PostsController: RouteCollection {
    var routes: [Route] {
        RouteGroup(api: "/posts") {
            GET("/", handle: list)
            GET("/:id", handle: read)
            POST("/", handle: create)
            PATCH("/:id", handle: update)
            DELETE("/:id", handle: destroy)
        }
    }

    func list(_ req: Request) async throws -> Response {
        let posts = try await db.query(Post.self)
            .filter(\.published == true)
            .all()
        return try Response.json(posts)
    }

    func create(_ req: Request) async throws -> Response {
        let body = try await req.decode(CreatePostRequest.self)
        let post = try await db.insert(Post(from: body, authorId: req.context.user!.id))
        return try Response.json(post, status: .created)
    }

    func update(_ req: Request) async throws -> Response {
        let id: UUID = try req.pathParameter("id")
        let body = try await req.decode(UpdatePostRequest.self)
        var post = try await db.find(Post.self, id: id)!
        try body.apply(to: &post)
        try await db.update(post)
        return try Response.json(post)
    }

    func destroy(_ req: Request) async throws -> Response {
        let id: UUID = try req.pathParameter("id")
        try await db.delete(Post.self, id: id)
        return Response.noContent()
    }
}
```

## Typed API Endpoints

Define endpoints as static constants so the path string lives in exactly one place,
and callers reference the descriptor instead of a literal string:

```swift
// Sources/API/Endpoints.swift
import Score

enum Posts {
    static let list = APIEndpoint<Void, [Post]>(.GET, "/posts")
    static let create = APIEndpoint<CreatePost, Post>(.POST, "/posts")
    static let update = APIEndpoint<UpdatePost, Post>(.PATCH, "/posts/:id")
    static let delete = APIEndpoint<Void, Void>(.DELETE, "/posts/:id")
}
```

Register using the typed descriptor — the method and path come from the descriptor:

```swift
RouteGroup(api: "/") {
    GET(Posts.list, handle: list)
    POST(Posts.create, handle: create)
}
```

Reference the same descriptor in reactive views for client-side fetching:

```swift
struct BlogIndex: Page {
    @Fetch(Posts.list) var posts: [Post]

    var body: some View {
        ForEach(posts) { post in ArticleCard(post: post) }
    }
}
```

The type parameters on `APIEndpoint<Body, Response>` enforce that the request
body and expected response match between the route declaration and any `@Fetch`
usage — mismatches are compiler errors.

## API Versioning

### Single Active Version

Declare the prefix once on ``Application``; all `RouteGroup(api:)` groups
resolve it automatically:

```swift
@main
struct MySite: Application {
    var apiPrefix: APIPrefix { .v1 }  // all api: groups resolve to /api/v1/*
}
```

### Multiple Simultaneous Versions

Run v1 and v2 side by side during a migration window:

```swift
@main
struct MySite: Application {
    // Default prefix used by RouteGroup(api:) helpers
    var apiPrefix: APIPrefix { .v2 }

    var routes: some RouteCollection {
        // v2 controllers (use the default api: prefix)
        PostsV2Controller()

        // v1 — explicitly namespaced, kept for clients still on the old version
        RouteGroup("/api/v1") {
            PostsV1Controller()
        }
    }
}
```

### Committable API Manifest

Score generates a machine-readable manifest of every registered route at
build time, written to `.score/api-manifest.json`. Commit this file to give
you a diff-visible record of every breaking change across versions:

```sh
# .gitignore should NOT ignore this file
.score/api-manifest.json   ← commit this
```

The manifest records method, path, version tag, and parameter names:

```json
{
  "version": "2",
  "generated": "2025-06-11T08:00:00Z",
  "routes": [
    { "method": "GET",    "path": "/api/v2/posts",     "version": "v2" },
    { "method": "POST",   "path": "/api/v2/posts",     "version": "v2" },
    { "method": "GET",    "path": "/api/v1/posts",     "version": "v1" },
    { "method": "DELETE", "path": "/api/v1/posts/:id", "version": "v1" }
  ]
}
```

Generate or update it manually:

```sh
score manifest          # writes .score/api-manifest.json
score manifest --diff   # shows what changed since last generation
```

## Request

```swift
// Decode a typed request body
let body = try await req.decode(CreatePostRequest.self)

// Read a typed path parameter
let id: UUID = try req.pathParameter("id")

// Read raw path parameter
let slug = req.pathParameters["slug"]!

// Read headers
let contentType = req.headers[.contentType]
```

## Response

```swift
try Response.json(post)  // 200 application/json
try Response.json(post, status: .created)  // 201 application/json
Response.html(SomePage())  // 200 text/html
Response.redirect(to: "/login")  // 302 Found
Response.redirect(to: "/new-path", permanent: true)  // 301 Moved Permanently
Response.notFound()  // 404
Response.badRequest("Missing required field.")  // 400
Response.noContent()  // 204
```

Throw ``HTTPError`` to return any HTTP status code, including `500`:

```swift
GET("/posts/:id") { req in
    guard let id = UUID(uuidString: req.pathParameters["id"] ?? "")
    else { throw HTTPError(status: .badRequest, message: "Invalid UUID.") }

    guard let post = try await db.find(Post.self, id: id)
    else { throw HTTPError.notFound }

    // Any thrown error that is not HTTPError becomes a 500
    // Internal Server Error with no body exposed to the client.
    return try Response.json(post)
}
```

Uncaught `Error` values that are not ``HTTPError`` are intercepted by Score's
error middleware and returned as `500 Internal Server Error`. The error detail
is logged server-side and never sent to the client.

## Middleware

Apply middleware to a route group:

```swift
RouteGroup("/admin") {
    GET("/") { req in AdminPage(user: req.context.user!) }
    GET("/posts") { req in AdminPostsPage() }
}
.middleware(AuthMiddleware())
```

Define custom middleware by conforming to ``Middleware``:

```swift
struct RateLimitMiddleware: Middleware {
    let requestsPerMinute: Int

    func handle(
        _ request: Request,
        next: @Sendable (Request) async throws -> Response
    ) async throws -> Response {
        let count =
            (try? await cache.increment(
                "ratelimit:\(request.remoteAddress)",
                expiry: .seconds(60)
            )) ?? 0
        guard count <= requestsPerMinute
        else { return Response(status: .tooManyRequests) }
        return try await next(request)
    }
}
```

## WebSocket Routes

```swift
WS("/live/notifications") { socket, req in
    guard let user = req.context.user else {
        try await socket.close(code: .normalClosure)
        return
    }
    for await notification in NotificationFeed.stream(for: user.id) {
        try await socket.send(notification.jsonString())
    }
}
```

## Composing Controllers

Register controllers on ``Application``:

```swift
@main
struct MySite: Application {
    var routes: some RouteCollection {
        PostsController()
        UsersController()
        AuthController()
    }
}
```

## See Also

- <doc:DataLayer>
- <doc:ReactiveState>
- <doc:GettingStarted>