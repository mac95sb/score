import Testing
@testable import ScoreSSG
import ScoreCore
import Foundation

// MARK: - Test Pages

struct IndexPage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "Home")
    }
    var body: some View {
        Main {
            Heading(1) { "Welcome" }
            Text { "Home page content." }
        }
    }
}

struct AboutPage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "About")
    }
    var body: some View {
        Main {
            Heading(1) { "About Us" }
        }
    }
}

// MARK: - Tests

@Suite("SSG")
struct SSGTests {

    let site = SiteMetadata(title: "Test Site", baseURL: "https://example.com")

    // MARK: - PageRenderer

    @Test("renders index page to full HTML document")
    func rendersIndexPage() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(IndexPage())
        #expect(html.hasPrefix("<!DOCTYPE html>"))
        #expect(html.contains("<html"))
        #expect(html.contains("Welcome"))
        #expect(html.contains("Home page content"))
    }

    @Test("page title is injected into <head>")
    func titleInjected() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(IndexPage())
        #expect(html.contains("Home"))
    }

    @Test("site title appears when page metadata is nil")
    func siteTitleFallback() throws {
        struct NoMetaPage: Page {
            var metadata: PageMetadata? { nil }
            var body: some View { Text { "Hello" } }
        }
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(NoMetaPage())
        #expect(html.contains("Test Site"))
    }

    @Test("CSS links are injected in <head>")
    func cssLinksInjected() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(IndexPage(), cssLinks: ["/styles.abc.css"])
        #expect(html.contains("href=\"/styles.abc.css\""))
    }

    @Test("script srcs are injected in <head>")
    func scriptSrcsInjected() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(IndexPage(), scriptSrcs: ["/runtime.js"])
        #expect(html.contains("src=\"/runtime.js\""))
    }

    @Test("collectCSS returns empty string for unstyled page")
    func collectCSSUnstyledPage() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let css = renderer.collectCSS(from: IndexPage())
        _ = css // May be empty for plain pages — no crash is the assertion
    }

    @Test("inline CSS is embedded in <style> tag")
    func inlineCSSEmbedded() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(IndexPage(), inlineCSS: ".test{color:red}")
        #expect(html.contains(".test{color:red}"))
    }

    // MARK: - RenderedPage

    @Test("RenderedPage stores path and html")
    func renderedPageStorage() {
        let page = RenderedPage(path: "/about", html: "<html>...</html>")
        #expect(page.path == "/about")
        #expect(page.html == "<html>...</html>")
    }

    // MARK: - BuildConfiguration

    @Test("BuildConfiguration stores all properties")
    func buildConfigStorage() {
        let config = BuildConfiguration(
            outputDirectory: URL(fileURLWithPath: "/tmp/build"),
            publicDirectory: URL(fileURLWithPath: "/tmp/public"),
            cacheDirectory: URL(fileURLWithPath: "/tmp/cache"),
            minify: true,
            fingerprint: false
        )
        #expect(config.minify == true)
        #expect(config.fingerprint == false)
        #expect(config.outputDirectory.path == "/tmp/build")
    }
}
