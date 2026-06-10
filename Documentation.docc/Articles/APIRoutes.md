# API Routes

Declare page routes and API endpoints with type-safe route collections.

## Overview

Routes live in `Sources/Controllers/`. Each controller is a struct conforming
to ``RouteCollection`` and owns all routes — both page-rendering and API — for
a given feature. Score infers intent from the return type: a handler returning
a ``View`` renders HTML; one returning ``Response`` serves data.

## Route Collections

```swift
// Sources/Controllers/PostsController.swift
struct PostsController: RouteCollection {
    var routes: some RouteCollection {

        RouteGroup("/blog") {
            Page("/") { BlogIndexPage() }
            Page("/:slug") { req in
                guard let post = try await db.query(Post.self)
                    .filter(\.slug == req.pathParameters["slug"]!)
                    .first()
                else { throw HTTPError.notFound }
                return BlogPostPage(post: post)
            }
        }

        RouteGroup(api: "/posts") {
            GET("/",      handle: list)
            POST("/",     handle: create)
            PATCH("/:id", handle: update)
            DELETE("/:id",handle: destroy)
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
    var routes: some RouteCollection {
        RouteGroup(api: "/posts") {
            GET("/",      handle: list)
            GET("/:id",   handle: read)
            POST("/",     handle: create)
            PATCH("/:id", handle: update)
            DELETE("/:id",handle: destroy)
        }
    }

    func list(_ req: Request) async throws -> Response {
        let posts = try await db.query(Post.self)
            .filter(\.published == true)
            .all()
        return Response.json(posts)
    }

    func create(_ req: Request) async throws -> Response {
        let body = try await req.decode(CreatePostRequest.self)
        let post = try await db.insert(Post(from: body, authorId: req.context.user!.id))
        return Response.json(post, status: .created)
    }

    func update(_ req: Request) async throws -> Response {
        let id: UUID = try req.pathParameter("id")
        var post = try await db.find(Post.self, id: id)!
        try body.apply(to: &post)
        try await db.update(post)
        return Response.json(post)
    }

    func destroy(_ req: Request) async throws -> Response {
        let id: UUID = try req.pathParameter("id")
        try await db.delete(Post.self, id: id)
        return Response.noContent()
    }
}
```

## API Versioning

Declare the prefix once on ``Application``; all `RouteGroup(api:)` groups
resolve it automatically:

```swift
@main
struct MySite: Application {
    var apiPrefix: APIPrefix { .v1 }   // all api: groups resolve to /api/v1/*
}
```

Upgrading from `.v1` to `.v2` is a one-line change. Every controller updates
with no further edits.

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
Response.json(post)                              // 200 application/json
Response.json(post, status: .created)            // 201 application/json
Response.html(SomePage())                        // 200 text/html
Response.redirect(to: "/login")                  // 302 Found
Response.redirect(to: "/new-path", permanent: true) // 301 Moved Permanently
Response.notFound()                              // 404
Response.badRequest("Missing required field.")   // 400
Response.noContent()                             // 204
```

## Middleware

Apply middleware to a route group:

```swift
RouteGroup("/admin") {
    GET("/")      { req in AdminPage(user: req.context.user!) }
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
        let count = (try? await cache.increment(
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

## Related Concepts

- <doc:DataLayer> — querying the database inside handlers
- <doc:ReactiveState> — `@Action` for server-side mutations from views
