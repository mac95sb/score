import Testing
@testable import ScoreCore

@Suite("StyleScope")
struct StyleScopeTests {
    @Test("converts single word to lowercase")
    func singleWord() {
        #expect(StyleScope.cssClass(from: "Button") == "button")
    }

    @Test("converts PascalCase to kebab-case")
    func pascalToKebab() {
        #expect(StyleScope.cssClass(from: "ArticleCard") == "article-card")
        #expect(StyleScope.cssClass(from: "BlogPostPage") == "blog-post-page")
        #expect(StyleScope.cssClass(from: "NavLink") == "nav-link")
    }

    @Test("handles consecutive capitals")
    func consecutiveCapitals() {
        // HTMLParser → html-parser
        let result = StyleScope.cssClass(from: "HTMLParser")
        #expect(result.contains("-"))
    }

    @Test("handles acronym followed by word")
    func acronymBeforeWord() {
        let result = StyleScope.cssClass(from: "APIPrefix")
        #expect(result.contains("api"))
    }

    @Test("empty string returns empty")
    func emptyInput() {
        #expect(StyleScope.cssClass(from: "") == "")
    }
}
