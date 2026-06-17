import Score

@main
struct MyApp: Application {
    var metadata: SiteMetadata {
        SiteMetadata(
            siteName: "My App",
            titleSeparator: " — ",
            description: "A full-stack app built with Score.",
            baseURL: "https://example.com"
        )
    }

    var database: some DatabaseConfig {
        SQLiteDatabase(path: ".score/db.sqlite")
    }

    var routes: some RouteCollection {
        PostsController()
    }
}
