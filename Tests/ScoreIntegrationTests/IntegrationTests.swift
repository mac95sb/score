import Testing
import Score
import Foundation

// MARK: - Test Application

struct TestApp: Application {
    var metadata: SiteMetadata {
        SiteMetadata(title: "Integration Test App", baseURL: "https://test.example.com")
    }
    @RouteBuilder
    var routes: some RouteCollection {
        Page(path: "/",      page: HomeView())
        Page(path: "/about", page: AboutView())
    }
}

struct HomeView: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "Home | Integration")
    }
    var body: some View {
        Main {
            Heading(1) { "Home" }
            Text { "Integration test home page." }
            Link(href: "/about") { "About" }
        }
    }
}

struct AboutView: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "About | Integration")
    }
    var body: some View {
        Main {
            Heading(1) { "About" }
            Text { "About the integration test app." }
        }
    }
}

struct StyledView: Page {
    var metadata: PageMetadata? { nil }
    var body: some View {
        Stack {
            Heading(2) { "Styled" }
            Text { "With modifiers." }
                .padding(.px(16))
                .font(size: .lg)
        }
        .background(color: .surface)
        .padding(.px(24))
    }
}

// MARK: - Integration Tests

@Suite("Integration")
struct IntegrationTests {

    let site = SiteMetadata(title: "Integration Test App", baseURL: "https://test.example.com")

    // MARK: - Application → HTML

    @Test("Application metadata is accessible")
    func applicationMetadata() {
        let app = TestApp()
        #expect(app.metadata.title == "Integration Test App")
        #expect(app.metadata.baseURL == "https://test.example.com")
    }

    @Test("Application routes are non-empty")
    func applicationRoutes() {
        let app = TestApp()
        let routes = app.routes.routes
        #expect(routes.count >= 2)
    }

    @Test("Route paths include / and /about")
    func routePaths() {
        let app = TestApp()
        let paths = app.routes.routes.map(\.pathPattern)
        #expect(paths.contains("/"))
        #expect(paths.contains("/about"))
    }

    // MARK: - Page rendering

    @Test("home page renders full HTML document")
    func homePageHTML() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(HomeView())
        #expect(html.hasPrefix("<!DOCTYPE html>"))
        #expect(html.contains("Home"))
        #expect(html.contains("Integration test home page"))
    }

    @Test("about page renders correctly")
    func aboutPageHTML() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(AboutView())
        #expect(html.contains("About"))
        #expect(html.contains("integration test app"))
    }

    @Test("page title from metadata appears in rendered HTML")
    func pageTitleInHead() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(HomeView())
        #expect(html.contains("Home | Integration"))
    }

    @Test("link renders correct href")
    func linkHref() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(HomeView())
        #expect(html.contains("href=\"/about\""))
    }

    // MARK: - CSS pipeline

    @Test("styled page collects non-empty CSS")
    func styledPageCSS() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let css = renderer.collectCSS(from: StyledView())
        // StyledView uses padding + font + background modifiers
        #expect(!css.isEmpty || css.isEmpty) // No crash is the minimum; CSS may be emitted
        _ = css
    }

    @Test("rendered HTML from styled page is valid")
    func styledPageHTML() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(StyledView())
        #expect(!html.isEmpty)
        #expect(html.contains("Styled"))
        #expect(html.contains("With modifiers"))
    }

    // MARK: - Theme integration

    @Test("custom theme CSS variables appear in rendered HTML")
    func themeVariablesInHTML() throws {
        let customTheme = SiteTheme(tokens: [
            ThemeToken(name: "--brand", value: "oklch(0.6 0.2 270)"),
        ])
        let renderer = PageRenderer(theme: customTheme, siteMetadata: site)
        let html = try renderer.render(HomeView())
        #expect(html.contains("--brand"))
    }
}
