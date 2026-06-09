import Testing
@testable import ScoreRouter
@testable import ScoreHTTP
import Foundation

@Suite("Router")
struct RouterTests {
    @Test("matches exact path and returns 200")
    func exactPathMatch() async throws {
        let router = Router()
        await router.register(Route(method: .GET, pathPattern: "/about") { _ in
            Response.ok(.text("About"))
        })

        let request = Request(method: .get, uri: URI(path: "/about"))
        let response = try await router.handle(request)
        #expect(response.status == .ok)
    }

    @Test("matches path with parameter")
    func parameterMatch() async throws {
        let router = Router()
        await router.register(Route(method: .GET, pathPattern: "/posts/:slug") { req in
            let slug: String = try req.pathParameter("slug")
            return Response.ok(.text(slug))
        })

        let request = Request(method: .get, uri: URI(path: "/posts/hello-world"))
        let response = try await router.handle(request)
        #expect(response.status == .ok)
    }

    @Test("returns 404 for unmatched path")
    func noMatch() async throws {
        let router = Router()
        await router.register(Route(method: .GET, pathPattern: "/home") { _ in
            Response.ok()
        })

        let request = Request(method: .get, uri: URI(path: "/unknown"))
        let response = try await router.handle(request)
        #expect(response.status == .notFound)
    }

    @Test("returns 404 for wrong HTTP method")
    func methodMismatch() async throws {
        let router = Router()
        await router.register(Route(method: .POST, pathPattern: "/users") { _ in
            Response(status: .created)
        })

        let request = Request(method: .get, uri: URI(path: "/users"))
        let response = try await router.handle(request)
        #expect(response.status == .notFound)
    }

    @Test("wildcard matches any sub-path")
    func wildcardMatch() async throws {
        let router = Router()
        await router.register(Route(method: .GET, pathPattern: "/files/*") { _ in
            Response.ok(.text("file"))
        })

        let request = Request(method: .get, uri: URI(path: "/files/images/photo.jpg"))
        let response = try await router.handle(request)
        #expect(response.status == .ok)
    }

    @Test("multiple routes registered — correct one matches")
    func multipleRoutes() async throws {
        let router = Router()
        await router.register(Route(method: .GET, pathPattern: "/a") { _ in Response.ok(.text("a")) })
        await router.register(Route(method: .GET, pathPattern: "/b") { _ in Response.ok(.text("b")) })
        await router.register(Route(method: .GET, pathPattern: "/c") { _ in Response.ok(.text("c")) })

        let response = try await router.handle(Request(method: .get, uri: URI(path: "/b")))
        #expect(response.status == .ok)
    }

    @Test("allRoutes returns all registered routes")
    func allRoutes() async {
        let router = Router()
        await router.register(Route(method: .GET, pathPattern: "/x") { _ in Response.ok() })
        await router.register(Route(method: .POST, pathPattern: "/y") { _ in Response(status: .created) })
        let all = await router.allRoutes()
        #expect(all.count == 2)
    }
}
