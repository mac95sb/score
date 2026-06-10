import Score

@main
struct __NAME__: Application {
    var metadata: SiteMetadata {
        SiteMetadata(
            siteName: "__NAME__",
            baseURL: "https://example.com"
        )
    }

    var routes: some RouteCollection {
        Page("/") { WelcomePage() }
    }
}

struct WelcomePage: Page {
    var metadata: PageMetadata {
        PageMetadata(title: "Welcome", description: "A Score site.")
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "Hello from __NAME__" }
                    .font(size: .fourXL)
                    .font(weight: .bold)
                Text { "Edit Sources/Application.swift to get started." }
                    .font(size: .lg)
                    .font(color: .muted)
                    .margin(top: 4)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
