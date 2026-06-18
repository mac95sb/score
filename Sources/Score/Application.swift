import Foundation
import Logging
import ScoreBuild
import ScoreCore
import ScoreData
import ScoreHTTP
import ScoreRouter
import ScoreSSG
import ServiceLifecycle

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

    /// The `robots.txt` configuration written to the build output. Default: ``RobotsTxt/default``.
    var robotsTxt: RobotsTxt { get }

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
    public var robotsTxt: RobotsTxt { .default }

    public var globalView: HtmlDocument {
        HtmlDocument { EmptyView() }
    }
}

extension Application where AppRoutes == [Route] {
    public var routes: [Route] { [] }
}

extension Application where AppDatabase == NoDatabase {
    public var database: NoDatabase { NoDatabase() }
}

// MARK: - Entry point

extension Application {
    /// The binary entry point synthesised for `@main` conformers.
    ///
    /// Dispatches on the flags the `score` CLI passes to the compiled app:
    /// - `--list-routes [--format=json]` — print the route table and exit.
    /// - `--build-only [--output <dir>] [--no-minify] [--no-fingerprint]` —
    ///   render all static routes to disk and exit.
    /// - default — start the HTTP server (`--host`, `--port`, `--dev`).
    public static func main() async {
        let app = Self()
        do {
            try await ScoreRuntime.run(app)
        } catch {
            FileHandle.standardError.write(Data("score: \(error)\n".utf8))
            exit(1)
        }
    }
}

// MARK: - ScoreRuntime

/// Drives a compiled Score application: serving, static builds, and route listing.
enum ScoreRuntime {
    static func run<A: Application>(_ app: A) async throws {
        let arguments = Array(CommandLine.arguments.dropFirst())

        if arguments.contains("--list-routes") {
            listRoutes(app: app, json: arguments.contains("--format=json"))
        } else if arguments.contains("--build-only") {
            try await build(app: app, arguments: arguments)
        } else {
            try await serve(app: app, arguments: arguments)
        }
    }

    // MARK: - Serve

    private static func serve<A: Application>(app: A, arguments: [String]) async throws {
        try await bootstrapDatabase(app)

        let host = value(of: "--host", in: arguments) ?? "127.0.0.1"
        let port = value(of: "--port", in: arguments).flatMap(Int.init) ?? 8080
        let isDev =
            arguments.contains("--dev")
            || ProcessInfo.processInfo.environment["SCORE_DEV_RELOAD"] == "1"
        let logger = Logger(label: "score.app")

        let devJS: String
        if isDev {
            devJS = RuntimeBundleAssembler().assemble(flags: FeatureFlags(devReload: true))
        } else {
            devJS = ""
        }

        let renderer = PageRenderer(
            theme: app.theme,
            siteMetadata: app.metadata,
            defaultInlineScripts: devJS.isEmpty ? [] : [devJS]
        )

        let routes = try await expandStaticPageRoutes(app: app, renderer: renderer)
        let router = Router()
        await router.register(routes)

        let wsRoutes: [WebSocketRoute] = app.routes.routes.compactMap { route in
            guard let wsHandler = route.webSocketHandler else { return nil }
            return WebSocketRoute(path: route.pathPattern, handler: wsHandler)
        }

        let sseBroadcaster: SSEBroadcaster? = isDev ? SSEBroadcaster() : nil

        let staticDirectory = FileManager.default.fileExists(atPath: "Public") ? "Public" : nil
        let server = NIOServer(
            host: host,
            port: port,
            staticDirectory: staticDirectory,
            logger: logger,
            sseBroadcaster: sseBroadcaster,
            webSocketRoutes: wsRoutes
        ) { request in
            try await router.handle(request)
        }

        let group = ServiceGroup(
            services: [server],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: logger
        )
        try await group.run()
    }

    // MARK: - Static build

    private static func build<A: Application>(app: A, arguments: [String]) async throws {
        try await bootstrapDatabase(app)

        let output = value(of: "--output", in: arguments) ?? ".score/build"
        let minify = !arguments.contains("--no-minify")
        let fingerprint = !arguments.contains("--no-fingerprint")

        let configuration = BuildConfiguration(
            outputDirectory: URL(fileURLWithPath: output),
            publicDirectory: URL(fileURLWithPath: "Public"),
            cacheDirectory: URL(fileURLWithPath: ".score/cache"),
            minify: minify,
            fingerprint: fingerprint
        )
        let renderer = PageRenderer(theme: app.theme, siteMetadata: app.metadata)
        let routes = app.routes.routes
        let generator = StaticSiteGenerator(configuration: configuration)

        var pages = try await generator.resolveStaticPages(from: routes, renderer: renderer)
        for route in routes {
            guard let pageType = route.staticPageType else { continue }
            for instance in try await pageType.instances() {
                pages.append(RenderedPage(path: instance.path, html: try renderer.render(instance)))
            }
        }

        if minify {
            let minifier = HTMLMinifier()
            pages = pages.map { RenderedPage(path: $0.path, html: minifier.minify($0.html)) }
        }

        let requiresServer = routes.contains {
            $0.renderMode == .serverRendered && $0.staticPageType == nil
        }
        try await generator.build(pages: pages, requiresServer: requiresServer)

        let robotsURL = URL(fileURLWithPath: output).appending(path: "robots.txt")
        try app.robotsTxt.generate().write(to: robotsURL, atomically: true, encoding: .utf8)

        print("score: built \(pages.count) page(s) → \(output)")
    }

    // MARK: - Route listing

    private static func listRoutes<A: Application>(app: A, json: Bool) {
        let routes = app.routes.routes
        if json {
            let entries: [[String: String]] = routes.map {
                [
                    "method": $0.method?.rawValue ?? "ANY",
                    "path": $0.pathPattern,
                    "mode": String(describing: $0.renderMode),
                ]
            }
            if let data = try? JSONSerialization.data(withJSONObject: entries, options: [.prettyPrinted, .sortedKeys]),
                let text = String(data: data, encoding: .utf8)
            {
                print(text)
            }
        } else {
            for route in routes {
                let method = (route.method?.rawValue ?? "ANY").padding(toLength: 7, withPad: " ", startingAt: 0)
                print("\(method) \(route.pathPattern)  [\(String(describing: route.renderMode))]")
            }
        }
    }

    // MARK: - Helpers

    private static func bootstrapDatabase<A: Application>(_ app: A) async throws {
        guard !(app.database is NoDatabase) else { return }
        let context = try await app.database.makeContext()
        Database.bootstrap(context)
    }

    private static func expandStaticPageRoutes<A: Application>(
        app: A,
        renderer: PageRenderer
    ) async throws -> [Route] {
        var expanded: [Route] = []

        for route in app.routes.routes {
            if let pageType = route.staticPageType {
                for instance in try await pageType.instances() {
                    let html = try renderer.render(instance)
                    expanded.append(
                        Route(
                            method: .GET,
                            pathPattern: instance.path,
                            renderMode: .static
                        ) { _ in
                            Response(status: .ok, body: .html(html))
                        })
                }
                continue
            }

            if let factory = route.pageFactory {
                let r = renderer
                expanded.append(
                    Route(
                        method: route.method,
                        pathPattern: route.pathPattern,
                        renderMode: route.renderMode,
                        middleware: route.middleware
                    ) { req in
                        let page = try await factory(req)
                        func renderPage<P: Page>(_ p: P) throws -> String {
                            try r.render(p)
                        }
                        let html = try renderPage(page)
                        return Response(status: .ok, body: .html(html))
                    })
                continue
            }

            expanded.append(route)
        }
        return expanded
    }

    private static func value(of flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
            arguments.index(after: index) < arguments.endIndex
        else { return nil }
        return arguments[arguments.index(after: index)]
    }
}
