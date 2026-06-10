import Score

@main
struct __NAME__: Application {
    var metadata: SiteMetadata {
        SiteMetadata(
            siteName: "__NAME__",
            titleSeparator: " — ",
            description: "A static site built with Score.",
            baseURL: "https://example.com"
        )
    }

    var theme: SiteTheme { .default }

    var routes: some RouteCollection {
        Page("/") { HomePage() }
        Page("/about") { AboutPage() }
        BlogPostPage.self
    }
}
