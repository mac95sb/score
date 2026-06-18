import Foundation
import Testing

@testable import ScoreHTTP

@Suite("Request")
struct RequestTests {
    @Test("decodes JSON body")
    func decodeJSON() throws {
        struct Payload: Codable { let name: String }
        let json = #"{"name":"Alice"}"#
        let body = RequestBody(data: json.data(using: .utf8)!)
        let request = Request(
            method: .post,
            uri: URI(path: "/users"),
            headers: [:],
            body: body
        )
        let payload = try request.body.decode(Payload.self)
        #expect(payload.name == "Alice")
    }

    @Test("pathParameter extracts string")
    func pathParameterString() throws {
        let request = Request(
            method: .get,
            uri: URI(path: "/users/alice"),
            headers: [:],
            body: .empty,
            pathParameters: ["id": "alice"]
        )
        let id: String = try request.pathParameter("id")
        #expect(id == "alice")
    }

    @Test("pathParameter extracts Int")
    func pathParameterInt() throws {
        let request = Request(
            method: .get,
            uri: URI(path: "/posts/42"),
            headers: [:],
            body: .empty,
            pathParameters: ["id": "42"]
        )
        let id: Int = try request.pathParameter("id")
        #expect(id == 42)
    }

    @Test("pathParameter throws for missing key")
    func pathParameterMissing() throws {
        let request = Request(
            method: .get,
            uri: URI(path: "/posts/1"),
            headers: [:],
            body: .empty,
            pathParameters: [:]
        )
        #expect(throws: (any Error).self) {
            let _: String = try request.pathParameter("missing")
        }
    }

    @Test("pathParameter throws for invalid type")
    func pathParameterInvalidType() throws {
        let request = Request(
            method: .get,
            uri: URI(path: "/posts/abc"),
            headers: [:],
            body: .empty,
            pathParameters: ["id": "not-a-number"]
        )
        #expect(throws: (any Error).self) {
            let _: Int = try request.pathParameter("id")
        }
    }

    @Test("URI parses path and query")
    func uriParsing() {
        let uri = URI(string: "/search?q=swift&lang=en")
        #expect(uri.path == "/search")
        #expect(uri.query["q"] == "swift")
        #expect(uri.query["lang"] == "en")
    }

    @Test("URI with no query returns empty dict")
    func uriNoQuery() {
        let uri = URI(path: "/about")
        #expect(uri.query.isEmpty)
    }

    @Test("cookies parsed from header")
    func cookiesFromHeader() throws {
        var fields = HTTPFields()
        fields[.cookie] = "session=abc123; theme=dark"
        let request = Request(method: .get, uri: URI(path: "/"), headers: fields)
        #expect(request.cookies["session"] == "abc123")
        #expect(request.cookies["theme"] == "dark")
    }
}
