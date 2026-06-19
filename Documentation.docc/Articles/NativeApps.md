# Native Apps

Wrap your Score application in a native desktop or mobile shell, and share typed API contracts with a Swift client.

## Overview

Score's build output is standard HTML, CSS, and JavaScript, which means it runs
inside any platform WebView without modification. `score package` generates a
native host application for macOS, iOS, Windows, Linux, or Android that loads
your built site locally — no server required.

## Packaging for Native Platforms

Build your site first, then choose a native target:

```sh
score build

score package swiftui    # Swift package — macOS and iOS (WKWebView)
score package windows    # Windows app using WebView2
score package linux      # Linux app using WebKitGTK
score package android    # Android app using WebView
```

Each target produces a self-contained app bundle. The SwiftUI target includes
your `Record` types and an auto-generated API client so the native app can
call your Score backend with full type safety.

## Sharing API Types with a Native Client

When a native iOS or macOS app consumes your Score backend, Score's typed
`APIEndpoint` descriptors act as a shared contract between the server and the
client. Move your endpoint constants into a standalone Swift package that both
the Score app and the native app import:

```swift
// Shared/Sources/API/Endpoints.swift
import ScoreRouter

public enum Posts {
    public static let list   = APIEndpoint<Void, [Post]>(.GET, "/posts")
    public static let create = APIEndpoint<CreatePost, Post>(.POST, "/posts")
}
```

The Score server imports `API` to register routes:

```swift
RouteGroup(api: "/") {
    GET(Posts.list,   handle: list)
    POST(Posts.create, handle: create)
}
```

The native app imports the same `API` target and uses the endpoint's type
parameters to drive URLSession calls in a type-safe way:

```swift
import API

@Observable class PostsViewModel {
    var posts: [Post] = []

    func load() async throws {
        var req = URLRequest(url: baseURL.appending(path: Posts.list.path))
        req.httpMethod = Posts.list.method.rawValue
        let (data, _) = try await URLSession.shared.data(for: req)
        posts = try JSONDecoder().decode([Post].self, from: data)
    }
}
```

If `Posts.list` changes its response type, every call site that decodes the old
type becomes a compiler error before anything ships.

## Using SwiftUI Views Alongside Score

The `score package swiftui` target exports a Swift package that makes it easy
to build hybrid apps — native SwiftUI screens that call your Score backend and
display Score pages inside `WKWebView` wrappers. This is covered in depth in
<doc:BuildingYourFirstApp>.
