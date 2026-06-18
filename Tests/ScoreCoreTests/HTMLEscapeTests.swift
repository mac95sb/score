import Testing

@testable import ScoreCore

@Suite("HTML Escaping")
struct HTMLEscapeTests {
    @Test("escapes ampersand")
    func ampersand() {
        #expect(htmlEscape("a & b") == "a &amp; b")
    }

    @Test("escapes less-than")
    func lessThan() {
        #expect(htmlEscape("<div>") == "&lt;div&gt;")
    }

    @Test("escapes greater-than")
    func greaterThan() {
        #expect(htmlEscape("3 > 2") == "3 &gt; 2")
    }

    @Test("escapes double quote")
    func doubleQuote() {
        #expect(htmlEscape("say \"hello\"") == "say &quot;hello&quot;")
    }

    @Test("escapes apostrophe")
    func apostrophe() {
        #expect(htmlEscape("it's") == "it&#39;s")
    }

    @Test("leaves safe strings unchanged")
    func safeString() {
        let safe = "Hello, World! 123"
        #expect(htmlEscape(safe) == safe)
    }

    @Test("attribute escape wraps correctly")
    func attributeEscaping() {
        let escaped = attributeEscape("hello & <world>")
        #expect(escaped.contains("&amp;"))
        #expect(escaped.contains("&lt;"))
    }
}
