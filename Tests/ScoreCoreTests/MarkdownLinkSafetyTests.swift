import Testing
@testable import ScoreCore

@Suite("Markdown link safety")
struct MarkdownLinkSafetyTests {

    @Test("safe URLs become anchors")
    func safeURLs() {
        for url in [
            "https://example.com", "http://example.com/a?b=1", "/docs/intro",
            "#section", "./sibling", "../parent", "page.html", "docs/page",
            "mailto:hi@example.com", "tel:+123",
        ] {
            #expect(RichText.isSafeLinkURL(url), "expected safe: \(url)")
        }
        let html = RichText.inlineMarkdown("see [docs](/docs/intro)")
        #expect(html.contains("<a href=\"/docs/intro\">docs</a>"))
    }

    @Test("script-capable URL schemes render as plain text")
    func unsafeURLs() {
        for url in [
            "javascript:alert(1)", "JavaScript:alert(1)", " javascript:alert(1)",
            "data:text/html,<script>1</script>", "vbscript:x", "file:///etc/passwd",
        ] {
            #expect(!RichText.isSafeLinkURL(url), "expected unsafe: \(url)")
        }
        let html = RichText.inlineMarkdown("click [here](javascript:alert(1))")
        #expect(!html.contains("<a"))
        #expect(!html.contains("javascript:"))
        #expect(html.contains("here"))
    }

    @Test("raw HTML in markdown stays escaped")
    func htmlEscaped() {
        let html = RichText.inlineMarkdown("<script>alert(1)</script> and [x](https://e.com)")
        #expect(!html.contains("<script>"))
        #expect(html.contains("&lt;script&gt;"))
        #expect(html.contains("<a href=\"https://e.com\">x</a>"))
    }
}
