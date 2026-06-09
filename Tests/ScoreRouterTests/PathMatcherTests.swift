import Testing
@testable import ScoreRouter

@Suite("PathMatcher")
struct PathMatcherTests {
    @Test("exact match succeeds")
    func exactMatch() {
        let matcher = PathMatcher(pattern: "/about")
        let result = matcher.match(path: "/about")
        #expect(result != nil)
        #expect(result!.isEmpty)
    }

    @Test("exact match fails for different path")
    func exactNoMatch() {
        let matcher = PathMatcher(pattern: "/about")
        #expect(matcher.match(path: "/contact") == nil)
    }

    @Test("parameter extraction")
    func parameterExtraction() {
        let matcher = PathMatcher(pattern: "/users/:id")
        let params = matcher.match(path: "/users/42")
        #expect(params?["id"] == "42")
    }

    @Test("multiple parameters")
    func multipleParameters() {
        let matcher = PathMatcher(pattern: "/blog/:year/:slug")
        let params = matcher.match(path: "/blog/2024/hello-world")
        #expect(params?["year"] == "2024")
        #expect(params?["slug"] == "hello-world")
    }

    @Test("segment count mismatch fails for too few")
    func segmentTooFew() {
        let matcher = PathMatcher(pattern: "/a/b")
        #expect(matcher.match(path: "/a") == nil)
    }

    @Test("segment count mismatch fails for too many (without wildcard)")
    func segmentTooMany() {
        let matcher = PathMatcher(pattern: "/a/b")
        #expect(matcher.match(path: "/a/b/c") == nil)
    }

    @Test("wildcard matches remaining segments")
    func wildcardSegments() {
        let matcher = PathMatcher(pattern: "/static/*")
        #expect(matcher.match(path: "/static/js/app.js") != nil)
    }

    @Test("root path matches root pattern")
    func rootPath() {
        let matcher = PathMatcher(pattern: "/")
        #expect(matcher.match(path: "/") != nil)
    }

    @Test("parameter with hyphenated value")
    func hyphenatedValue() {
        let matcher = PathMatcher(pattern: "/posts/:slug")
        let params = matcher.match(path: "/posts/hello-world-2024")
        #expect(params?["slug"] == "hello-world-2024")
    }

    @Test("API prefix path matches")
    func apiPrefix() {
        let matcher = PathMatcher(pattern: "/api/v1/users/:id")
        let params = matcher.match(path: "/api/v1/users/abc")
        #expect(params?["id"] == "abc")
    }
}
