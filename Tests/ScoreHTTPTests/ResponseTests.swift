import Foundation
import Testing

@testable import ScoreHTTP

@Suite("Response")
struct ResponseTests {
    @Test("ok response has status .ok")
    func okStatus() throws {
        let r = Response.ok()
        #expect(r.status == .ok)
        #expect(r.status.rawValue == 200)
    }

    @Test("json response body has json contentType")
    func jsonContentType() throws {
        struct Body: Codable { let id: Int }
        let r = try Response.json(Body(id: 1))
        #expect(r.body.contentType.contains("application/json"))
    }

    @Test("redirect response has location header")
    func redirectLocation() throws {
        let r = Response.redirect(to: "/login")
        #expect(r.headers["Location"] == "/login")
        #expect(r.status == .found)
    }

    @Test("permanent redirect has status .movedPermanently")
    func permanentRedirect() throws {
        let r = Response.redirect(to: "/new", permanent: true)
        #expect(r.status == .movedPermanently)
        #expect(r.status.rawValue == 301)
    }

    @Test("redirect with CRLF in location is rejected (no response splitting)")
    func redirectRejectsCRLF() throws {
        let r = Response.redirect(to: "/ok\r\nSet-Cookie: admin=true")
        #expect(r.status == .badRequest)
        #expect(r.headers["Location"] == nil)
    }

    @Test("notFound response has status .notFound")
    func notFoundStatus() throws {
        let r = Response.notFound()
        #expect(r.status == .notFound)
        #expect(r.status.rawValue == 404)
    }

    @Test("html body has html contentType")
    func htmlContentType() throws {
        let r = Response.html(EmptyView())
        #expect(r.body.contentType.contains("text/html"))
    }

    @Test("noContent response has status .noContent and empty body")
    func noContentResponse() throws {
        let r = Response.noContent()
        #expect(r.status == .noContent)
        #expect(r.status.rawValue == 204)
    }

    @Test("Response with .created status")
    func createdResponse() throws {
        struct Item: Codable { let id: Int }
        let r = try Response.created(Item(id: 42))
        #expect(r.status == .created)
        #expect(r.status.rawValue == 201)
    }

    @Test("badRequest response has status .badRequest")
    func badRequestResponse() throws {
        let r = Response.badRequest("Invalid input")
        #expect(r.status == .badRequest)
        #expect(r.status.rawValue == 400)
    }

    @Test("response body bytes match text content")
    func responseBodyBytes() {
        let r = Response.ok(.text("hello"))
        #expect(r.body.bytes == Data("hello".utf8))
    }

    @Test("unauthorized response has status 401")
    func unauthorizedStatus() {
        let r = Response(status: .unauthorized)
        #expect(r.status.rawValue == 401)
    }
}
