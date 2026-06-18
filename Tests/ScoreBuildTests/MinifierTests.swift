import Testing

@testable import ScoreBuild

@Suite("HTMLMinifier")
struct HTMLMinifierTests {
    let minifier = HTMLMinifier()

    @Test("removes HTML comments")
    func removesComments() {
        let html = "<div><!-- a comment --><p>Hello</p></div>"
        let result = minifier.minify(html)
        #expect(!result.contains("<!--"))
        #expect(result.contains("<p>Hello</p>"))
    }

    @Test("preserves IE conditional comments")
    func preservesConditionals() {
        let html = "<!--[if IE]><link rel=\"stylesheet\" href=\"ie.css\"><![endif]--><p>normal</p>"
        let result = minifier.minify(html)
        #expect(result.contains("<!--[if IE]>"))
    }

    @Test("trims leading and trailing whitespace")
    func trims() {
        let html = "  <p>Hi</p>  "
        let result = minifier.minify(html)
        #expect(result == "<p>Hi</p>")
    }
}

@Suite("CSSMinifier")
struct CSSMinifierTests {
    let minifier = CSSMinifier()

    @Test("strips block comments")
    func stripsComments() {
        let css = "/* Header styles */ .header { color: red; }"
        let result = minifier.minify(css)
        #expect(!result.contains("/*"))
        #expect(result.contains("color:red"))
    }

    @Test("removes trailing semicolons before closing brace")
    func trailingSemicolons() {
        let css = ".btn { color: blue; padding: 4px; }"
        let result = minifier.minify(css)
        #expect(!result.contains(";}"))
    }

    @Test("collapses whitespace")
    func collapsesWhitespace() {
        let css = ".a   {   color :   red   }"
        let result = minifier.minify(css)
        #expect(!result.contains("   "))
    }

    @Test("handles empty input")
    func emptyInput() {
        let result = minifier.minify("")
        #expect(result.isEmpty)
    }

    @Test("preserves string literals")
    func preservesStrings() {
        let css = #"content: "hello world";"#
        let result = minifier.minify(css)
        #expect(result.contains("\"hello world\""))
    }
}
