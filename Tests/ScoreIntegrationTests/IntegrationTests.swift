import Testing
import Score
import Foundation

// MARK: - Test Application

struct TestApp: Application {
    var metadata: SiteMetadata {
        SiteMetadata(siteName: "Integration Test App", baseURL: "https://test.example.com")
    }

    var routes: some RouteCollection {
        Page("/") { HomeView() }
        Page("/about") { AboutView() }
    }
}

struct HomeView: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "Home")
    }
    var body: some View {
        Main {
            Heading(1) { "Home" }
            Text { "Integration test home page." }
            Link(to: "/about") { "About" }
        }
    }
}

struct AboutView: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "About")
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

    let site = SiteMetadata(siteName: "Integration Test App", baseURL: "https://test.example.com")

    // MARK: - Application configuration

    @Test("Application metadata is accessible")
    func applicationMetadata() {
        let app = TestApp()
        #expect(app.metadata.siteName == "Integration Test App")
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

    @Test("Application defaults are applied")
    func applicationDefaults() {
        let app = TestApp()
        #expect(app.includeBaseReset)
        #expect(app.apiPrefix.prefix == "/api/v1")
        #expect(app.database is NoDatabase)
    }

    // MARK: - Route handling

    @Test("Router serves the home route end-to-end")
    func routerServesHome() async throws {
        let app = TestApp()
        let router = Router()
        await router.register(app.routes.routes)

        let response = try await router.handle(Request(method: .get, uri: URI(path: "/")))
        #expect(response.status == .ok)
        guard case .html(let html) = response.body else {
            Issue.record("Expected HTML body")
            return
        }
        #expect(html.contains("Integration test home page"))
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
        #expect(html.contains("About the integration test app"))
    }

    @Test("page title from metadata appears in rendered HTML")
    func pageTitleInHead() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(HomeView())
        #expect(html.contains("Home"))
        #expect(html.contains("Integration Test App"))
    }

    @Test("link renders correct href")
    func linkHref() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let html = try renderer.render(HomeView())
        #expect(html.contains("href=\"/about\""))
    }

    // MARK: - CSS pipeline

    @Test("styled page collects CSS without crashing")
    func styledPageCSS() throws {
        let renderer = PageRenderer(siteMetadata: site)
        let css = renderer.collectCSS(from: StyledView())
        #expect(css.contains("padding") || css.isEmpty == false)
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

    @Test("theme CSS variables appear in rendered HTML")
    func themeVariablesInHTML() throws {
        var customTheme = SiteTheme.default
        customTheme.colors.primary = .violet(700)
        let renderer = PageRenderer(theme: customTheme, siteMetadata: site)
        let html = try renderer.render(HomeView())
        #expect(html.contains("--color-primary"))
    }
}
