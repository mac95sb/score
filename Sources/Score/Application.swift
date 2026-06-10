import Foundation
import ScoreCore
import ScoreRouter
import ScoreData

/// The entry point for a Score application.
///
/// Conform your `@main` struct to `Application` and configure application-wide
/// settings via computed properties. Score uses `metadata`, `theme`, `routes`,
/// and `database` to wire up the full site — HTML rendering, CSS generation,
/// routing, persistence, and static-site export.
///
/// ```swift
/// @main
/// struct MySite: Application {
///     var metadata: SiteMetadata {
///         SiteMetadata(siteName: "My Site", baseURL: "https://mysite.com")
///     }
///
///     var routes: some RouteCollection {
///         Page("/") { HomePage() }
///         PostsController()
///     }
///
///     var database: some DatabaseConfig {
///         SQLiteDatabase(path: ".score/db.sqlite")
///     }
/// }
/// ```
///
/// The conforming type gains a `static func main()` so the compiled binary
/// understands the flags the `score` CLI passes it: `--host`/`--port`/`--dev`
/// for serving, `--build-only --output <dir>` for static builds, and
/// `--list-routes` for route inspection.
public protocol Application: Sendable {
    /// Applications must be constructible without arguments so the runtime
    /// can instantiate them from `static func main()`. Structs whose
    /// properties are all computed satisfy this implicitly.
    init()

    /// Site-wide metadata used for `<title>`, `<meta>`, Open Graph, and social cards.
    var metadata: SiteMetadata { get }

    /// The visual design system — colours, fonts, spacing, shadows, and radii.
    var theme: SiteTheme { get }

    /// Whether to inject Score's base CSS reset. Default: `true`.
    var includeBaseReset: Bool { get }

    /// Controls persistence of non-Record `@State` variables. Default: `.ephemeral`.
    var stateMode: StateMode { get }

    /// The global HTML document shell. Override to add custom `<head>` elements.
    var globalView: HtmlDocument { get }

    /// The URL prefix applied to all API route groups. Default: `.v1`.
    var apiPrefix: APIPrefix { get }

    /// The application's routes.
    associatedtype AppRoutes: RouteCollection = [Route]
    @RouteBuilder var routes: AppRoutes { get }

    /// The application's database configuration. Default: ``NoDatabase``.
    associatedtype AppDatabase: DatabaseConfig = NoDatabase
    var database: AppDatabase { get }
}

// MARK: - Default implementations

extension Application {
    public var theme: SiteTheme { .default }
    public var includeBaseReset: Bool { true }
    public var stateMode: StateMode { .ephemeral }
    public var apiPrefix: APIPrefix { .v1 }

    public var globalView: HtmlDocument {
        HtmlDocument { EmptyView() }
    }
}

extension Application where AppRoutes == [Route] {
    /// Applications without routes serve nothing (static-asset-only sites).
    public var routes: [Route] { return [] }
}

extension Application where AppDatabase == NoDatabase {
    public var database: NoDatabase { NoDatabase() }
}
