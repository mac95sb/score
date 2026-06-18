import Foundation
import Testing

@testable import ScoreHTTP

@Suite("Cookie")
struct CookieTests {
    @Test("serializes a basic cookie")
    func basicSerialization() {
        let cookie = Cookie(name: "session", value: "abc123", secure: false, httpOnly: false, sameSite: nil)
        let header = cookie.headerValue
        #expect(header.hasPrefix("session=abc123"))
    }

    @Test("serializes cookie with httpOnly flag")
    func httpOnlyCookie() {
        let cookie = Cookie(name: "token", value: "xyz", secure: false, httpOnly: true, sameSite: nil)
        #expect(cookie.headerValue.contains("HttpOnly"))
    }

    @Test("serializes cookie with secure flag")
    func secureCookie() {
        let cookie = Cookie(name: "id", value: "1", secure: true, httpOnly: false, sameSite: nil)
        #expect(cookie.headerValue.contains("Secure"))
    }

    @Test("serializes cookie with max-age")
    func maxAgeCookie() {
        let cookie = Cookie(name: "prefs", value: "dark", maxAge: 3600, secure: false, httpOnly: false, sameSite: nil)
        #expect(cookie.headerValue.contains("Max-Age=3600"))
    }

    @Test("serializes cookie with path")
    func pathCookie() {
        let cookie = Cookie(name: "x", value: "1", path: "/app", secure: false, httpOnly: false, sameSite: nil)
        #expect(cookie.headerValue.contains("Path=/app"))
    }

    @Test("serializes SameSite=Lax")
    func sameSiteLax() {
        let cookie = Cookie(name: "c", value: "v", secure: false, httpOnly: false, sameSite: .lax)
        #expect(cookie.headerValue.contains("SameSite=Lax"))
    }

    @Test("parses cookie header")
    func parseCookieHeader() {
        let cookies = Cookie.parse(from: "session=abc; theme=dark")
        #expect(cookies["session"] == "abc")
        #expect(cookies["theme"] == "dark")
    }

    @Test("parses empty cookie header")
    func parseEmpty() {
        let cookies = Cookie.parse(from: "")
        #expect(cookies.isEmpty)
    }

    @Test("parses cookie with equals sign in value")
    func parseEqualsInValue() {
        let cookies = Cookie.parse(from: "token=abc=def")
        #expect(cookies["token"] == "abc=def")
    }
}
