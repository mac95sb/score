import Foundation
import Logging
import ServiceLifecycle
import ScoreCore
import ScoreHTTP
import ScoreRouter
import ScoreData
import ScoreSSG
import ScoreBuild

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
        let isDev = arguments.contains("--dev")
            || ProcessInfo.processInfo.environment["SCORE_DEV_RELOAD"] == "1"
        let logger = Logger(label: "score.app")

        // In dev mode, inject the hot-reload EventSource snippet into every page.
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

        // Extract WebSocket routes so NIOServer can wire up the NIO upgrade machinery.
        let wsRoutes: [WebSocketRoute] = app.routes.routes.compactMap { route in
            guard let wsHandler = route.webSocketHandler else { return nil }
            return WebSocketRoute(path: route.pathPattern, handler: wsHandler)
        }

        // SSE broadcaster — nil in production; dev mode keeps browser connections alive.
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

        // Parameter-free .static routes are rendered through their handlers;
        // StaticPage placeholders are expanded through instances().
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
               let text = String(data: data, encoding: .utf8) {
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

    /// Create and install the global database context unless the app uses ``NoDatabase``.
    private static func bootstrapDatabase<A: Application>(_ app: A) async throws {
        guard !(app.database is NoDatabase) else { return }
        let context = try await app.database.makeContext()
        Database.bootstrap(context)
    }

    /// Replace ``StaticPage`` placeholder routes with one pre-rendered GET route
    /// per page instance.
    private static func expandStaticPageRoutes<A: Application>(
        app: A,
        renderer: PageRenderer? = nil
    ) async throws -> [Route] {
        let renderer = renderer ?? PageRenderer(theme: app.theme, siteMetadata: app.metadata)
        var expanded: [Route] = []

        for route in app.routes.routes {
            guard let pageType = route.staticPageType else {
                expanded.append(route)
                continue
            }
            for instance in try await pageType.instances() {
                let html = try renderer.render(instance)
                expanded.append(Route(
                    method: .GET,
                    pathPattern: instance.path,
                    renderMode: .static
                ) { _ in
                    Response(status: .ok, body: .html(html))
                })
            }
        }
        return expanded
    }

    /// The value following `flag` in `arguments`, if any.
    private static func value(of flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.index(after: index) < arguments.endIndex
        else { return nil }
        return arguments[arguments.index(after: index)]
    }
}
