import Testing
@testable import ScoreRouter
import ScoreHTTP
import ScoreCore

// MARK: - Stub middleware

struct StubMiddleware: Middleware {
    let tag: String
    func handle(_ request: Request, next: RequestHandler) async throws -> Response {
        try await next(request)
    }
}

// MARK: - Tests

@Suite("RouteGroup")
struct RouteGroupTests {

    // MARK: - Prefix resolution

    @Test("routes receive the group prefix")
    func prefixApplied() {
        let group = RouteGroup("/blog") {
            GET("/") { _ in .ok() }
            GET("/:slug") { _ in .ok() }
        }
        let paths = group.routes.map(\.pathPattern)
        #expect(paths.contains("/blog/"))
        #expect(paths.contains("/blog/:slug"))
    }

    @Test("nested groups combine prefixes")
    func nestedPrefixes() {
        let outer = RouteGroup("/api") {
            GET("/users") { _ in .ok() }
            GET("/posts") { _ in .ok() }
        }
        let paths = outer.routes.map(\.pathPattern)
        #expect(paths.contains("/api/users"))
        #expect(paths.contains("/api/posts"))
    }

    @Test("empty prefix preserves child paths")
    func emptyPrefix() {
        let group = RouteGroup("") {
            GET("/health") { _ in .ok() }
        }
        #expect(group.routes.first?.pathPattern == "/health")
    }

    // MARK: - API prefix

    @Test("api: label resolves to /api/v1/path by default")
    func apiV1Prefix() {
        let group = RouteGroup(api: "/posts") {
            GET("/") { _ in .ok() }
        }
        let path = group.routes.first?.pathPattern ?? ""
        #expect(path.hasPrefix("/api/v1"))
        #expect(path.contains("/posts"))
    }

    @Test("api: label with custom prefix")
    func apiCustomPrefix() {
        let group = RouteGroup(api: "/items", apiPrefix: .v2) {
            GET("/") { _ in .ok() }
        }
        let path = group.routes.first?.pathPattern ?? ""
        #expect(path.contains("v2"))
    }

    // MARK: - Middleware attachment

    @Test("middleware is prepended to all routes in group")
    func middlewarePrepended() {
        let group = RouteGroup("/secure") {
            GET("/dashboard") { _ in .ok() }
            GET("/profile")   { _ in .ok() }
        }.middleware(StubMiddleware(tag: "auth"))

        for route in group.routes {
            #expect(!route.middleware.isEmpty)
        }
    }

    @Test("group routes preserve their methods")
    func methodsPreserved() {
        let group = RouteGroup("/api") {
            GET("/resource")    { _ in .ok() }
            POST("/resource")   { _ in .ok() }
            DELETE("/resource") { _ in .ok() }
        }
        let methods = group.routes.map(\.method)
        #expect(methods.contains(.get))
        #expect(methods.contains(.post))
        #expect(methods.contains(.delete))
    }
}
