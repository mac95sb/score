import Testing
@testable import ScoreCore

@Suite("Element Rendering")
struct ElementRenderTests {

    // MARK: - Text

    @Test("Text renders as <p>")
    func textElement() throws {
        var ctx = RenderContext()
        let html = Text { "Hello, Score." }._renderInto(&ctx)
        #expect(html == "<p>Hello, Score.</p>")
    }

    @Test("Text escapes HTML entities")
    func textEscaping() throws {
        var ctx = RenderContext()
        let html = Text { "<script>alert('xss')</script>" }._renderInto(&ctx)
        #expect(!html.contains("<script>"))
        #expect(html.contains("&lt;script&gt;"))
    }

    // MARK: - Heading

    @Test("Heading renders with correct level")
    func headingLevel() throws {
        for level in 1...6 {
            var ctx = RenderContext()
            let html = Heading(level) { "Title" }._renderInto(&ctx)
            #expect(html == "<h\(level)>Title</h\(level)>")
        }
    }

    // MARK: - Stack / HStack / VStack

    @Test("Stack renders as <div>")
    func stackElement() throws {
        var ctx = RenderContext()
        let html = Stack { Text { "Inside" } }._renderInto(&ctx)
        #expect(html.hasPrefix("<div>"))
        #expect(html.hasSuffix("</div>"))
        #expect(html.contains("<p>Inside</p>"))
    }

    @Test("HStack renders with flex class")
    func hstackElement() throws {
        var ctx = RenderContext()
        let html = HStack { Text { "Left" }; Text { "Right" } }._renderInto(&ctx)
        #expect(html.contains("hstack") || html.contains("flex"))
    }

    // MARK: - Link

    @Test("Link renders href attribute")
    func linkElement() throws {
        var ctx = RenderContext()
        let html = Link(href: "/about") { "About" }._renderInto(&ctx)
        #expect(html.contains("href=\"/about\""))
        #expect(html.contains("About"))
    }

    @Test("Link escapes href attribute")
    func linkHrefEscaping() throws {
        var ctx = RenderContext()
        let html = Link(href: "/search?q=hello&lang=en") { "Search" }._renderInto(&ctx)
        #expect(html.contains("&amp;") || html.contains("hello"))
    }

    // MARK: - Image

    @Test("Image renders with src and alt")
    func imageElement() throws {
        var ctx = RenderContext()
        let html = Image(src: "/logo.png", alt: "Logo")._renderInto(&ctx)
        #expect(html.contains("src=\"/logo.png\""))
        #expect(html.contains("alt=\"Logo\""))
    }

    // MARK: - Button

    @Test("Button renders with type attribute")
    func buttonElement() throws {
        var ctx = RenderContext()
        let html = Button(.primary, type: .submit) { "Submit" }._renderInto(&ctx)
        #expect(html.contains("type=\"submit\""))
        #expect(html.contains("Submit"))
    }

    // MARK: - List

    @Test("List renders as <ul> by default")
    func unorderedList() throws {
        var ctx = RenderContext()
        let html = List {
            ListItem { "One" }
            ListItem { "Two" }
        }._renderInto(&ctx)
        #expect(html.hasPrefix("<ul"))
        #expect(html.contains("<li>"))
    }

    @Test("List renders as <ol> when ordered")
    func orderedList() throws {
        var ctx = RenderContext()
        let html = List(ordered: true) {
            ListItem { "First" }
        }._renderInto(&ctx)
        #expect(html.hasPrefix("<ol"))
    }

    // MARK: - Section / Article / Header / Footer

    @Test("Section renders as <section>")
    func sectionElement() throws {
        var ctx = RenderContext()
        let html = Section { Text { "content" } }._renderInto(&ctx)
        #expect(html.hasPrefix("<section>"))
    }

    @Test("Article renders as <article>")
    func articleElement() throws {
        var ctx = RenderContext()
        let html = Article { Text { "body" } }._renderInto(&ctx)
        #expect(html.hasPrefix("<article>"))
    }

    // MARK: - Code / CodeBlock

    @Test("Code renders as <code>")
    func codeElement() throws {
        var ctx = RenderContext()
        let html = Code { "let x = 1" }._renderInto(&ctx)
        #expect(html.contains("<code>"))
        #expect(html.contains("let x = 1"))
    }

    // MARK: - Table

    @Test("Table renders with thead and tbody")
    func tableElement() throws {
        var ctx = RenderContext()
        let html = Table {
            TableHeader { TableRow { TableCell { "Name" } } }
            TableBody { TableRow { TableCell { "Alice" } } }
        }._renderInto(&ctx)
        #expect(html.contains("<table>"))
        #expect(html.contains("<thead>"))
        #expect(html.contains("<tbody>"))
    }

    // MARK: - Form

    @Test("Form renders with method and action")
    func formElement() throws {
        var ctx = RenderContext()
        let html = Form(action: "/submit", method: .post) {
            Input(type: .text, name: "email")
        }._renderInto(&ctx)
        #expect(html.contains("method=\"post\""))
        #expect(html.contains("action=\"/submit\""))
    }
}
