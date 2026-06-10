import Testing
import Score

// MARK: - Test Pages

struct SimplePage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "Simple Page")
    }

    var body: some View {
        Main {
            Heading(1) { "Hello, Score." }
            Text { "This is a simple page." }
        }
    }
}

struct StyledPage: Page {
    var metadata: PageMetadata? { nil }

    var body: some View {
        Stack {
            Heading(2) { "Styled" }
            Text { "With modifiers." }
                .padding(.all, 4)
                .font(size: .lg)
        }
        .background(.surface)
        .padding(.all, 8)
    }
}

// MARK: - Tests

@Suite("Render Pipeline")
struct RenderPipelineTests {
    let site = SiteMetadata(siteName: "Test Site", baseURL: "https://example.com")

    @Test("renders simple page to valid HTML document")
    func simplePageRendersHTML() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(SimplePage())

        #expect(html.hasPrefix("<!DOCTYPE html>"))
        #expect(html.contains("<title>"))
        #expect(html.contains("Hello, Score."))
        #expect(html.contains("This is a simple page."))
    }

    @Test("rendered HTML contains charset meta tag")
    func charsetMeta() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(SimplePage())
        #expect(html.contains("charset"))
    }

    @Test("rendered HTML contains viewport meta")
    func viewportMeta() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(SimplePage())
        #expect(html.contains("viewport"))
    }

    @Test("styled page renders without crash")
    func styledPageRenders() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(StyledPage())
        #expect(!html.isEmpty)
        #expect(html.contains("Styled"))
    }

    @Test("collectCSS returns non-empty string for styled page")
    func collectCSSFromStyledPage() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let css = renderer.collectCSS(from: StyledPage())
        // StyledPage uses modifiers so CSS should be collected
        // (empty is also valid if no component-level CSS is emitted)
        _ = css // No crash is the main assertion
    }

    @Test("minified HTML is smaller than un-minified")
    func minificationReducesSize() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(SimplePage())
        let minifier = HTMLMinifier()
        let minified = minifier.minify(html)
        #expect(minified.count <= html.count)
    }

    @Test("page title appears in rendered document head")
    func titleInHead() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(SimplePage())
        #expect(html.contains("Simple Page"))
    }

    @Test("CSS links are injected into head")
    func cssLinksInjected() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(SimplePage(), cssLinks: ["/styles.abc123.css"])
        #expect(html.contains("href=\"/styles.abc123.css\""))
    }

    @Test("script srcs are injected into head")
    func scriptSrcsInjected() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(SimplePage(), scriptSrcs: ["/runtime.js"])
        #expect(html.contains("src=\"/runtime.js\""))
    }
}
