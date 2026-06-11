import Score

@main
struct __NAME__: Application {
    var metadata: SiteMetadata {
        SiteMetadata(
            siteName: "__NAME__",
            titleSeparator: " — ",
            description: "A site built with Score.",
            baseURL: "https://example.com"
        )
    }

    var theme: SiteTheme { .default }

    // localFirst persists Codable @State (e.g. LikedPosts) to IndexedDB across sessions.
    var stateMode: StateMode { .localFirst }

    var routes: some RouteCollection {
        PostsController()
        LikesController()
    }

    var database: some DatabaseConfig {
        SQLiteDatabase(path: ".score/db.sqlite")
    }
}
