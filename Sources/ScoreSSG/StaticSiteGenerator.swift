import Foundation
import ScoreCore
import ScoreHTTP
import ScoreRouter
import ScoreData

/// Configuration for a static site generation pass.
public struct BuildConfiguration: Sendable {
    /// Where pre-rendered HTML files are written (e.g. `.score/build`).
    public let outputDirectory: URL
    /// Directory of static assets to copy verbatim (e.g. `Public/`).
    public let publicDirectory: URL
    /// Scratch directory for the dependency graph and other caches.
    public let cacheDirectory: URL
    /// Whether to minify the rendered HTML.
    public let minify: Bool
    /// Whether to fingerprint asset filenames (SHA-256 content hash).
    public let fingerprint: Bool

    public init(
        outputDirectory: URL,
        publicDirectory: URL,
        cacheDirectory: URL,
        minify: Bool = true,
        fingerprint: Bool = true
    ) {
        self.outputDirectory = outputDirectory
        self.publicDirectory = publicDirectory
        self.cacheDirectory = cacheDirectory
        self.minify = minify
        self.fingerprint = fingerprint
    }
}

/// A resolved static page ready for writing to disk.
public struct RenderedPage: Sendable {
    /// The URL path (e.g. `/blog/hello-world`).
    public let path: String
    /// The fully-rendered HTML document string.
    public let html: String

    public init(path: String, html: String) {
        self.path = path
        self.html = html
    }
}

/// Orchestrates a full static-site generation build.
///
/// `StaticSiteGenerator` renders an array of ``RenderedPage`` values to disk,
/// copies the `Public/` directory, and writes an ``AssetManifest``.
///
/// Route handlers are responsible for calling their pages via ``PageRenderer``
/// and providing ``RenderedPage`` instances.
///
/// ```swift
/// let renderer = PageRenderer(siteMetadata: site)
/// let pages: [RenderedPage] = try await resolveStaticPages(routes: appRoutes, renderer: renderer)
///
/// let ssg = StaticSiteGenerator(configuration: config)
/// try await ssg.build(pages: pages, requiresServer: false)
/// ```
public actor StaticSiteGenerator {
    public let configuration: BuildConfiguration
    private let dependencyGraph: DependencyGraph
    private let fm = FileManager.default

    public init(configuration: BuildConfiguration) {
        self.configuration = configuration
        self.dependencyGraph = DependencyGraph(cacheDirectory: configuration.cacheDirectory)
    }

    // MARK: - Build

    /// Write all pre-rendered pages to disk and produce the asset manifest.
    ///
    /// - Parameters:
    ///   - pages: All page HTML to write (from ``PageRenderer``).
    ///   - css: Combined CSS string to write as `styles.css`.
    ///   - extraAssets: Additional asset name→fingerprinted-name pairs.
    ///   - requiresServer: `true` if the app also has server-rendered routes.
    public func build(
        pages: [RenderedPage],
        css: String = "",
        extraAssets: [String: String] = [:],
        requiresServer: Bool = false
    ) async throws {
        try fm.createDirectory(at: configuration.outputDirectory, withIntermediateDirectories: true)
        try dependencyGraph.load()

        var assetMap: [String: String] = extraAssets
        var pagePaths: [String] = []

        // Write each page HTML file
        for page in pages {
            try writeHTML(page.html, to: page.path)
            pagePaths.append(page.path)
            await dependencyGraph.addDependency(page: page.path, dependsOn: "build")
        }

        // Write CSS bundle
        if !css.isEmpty {
            let cssURL = configuration.outputDirectory.appendingPathComponent("styles.css")
            try css.write(to: cssURL, atomically: true, encoding: .utf8)
            assetMap["styles.css"] = "styles.css"
        }

        // Copy public directory
        try copyPublicDirectory(into: &assetMap)

        // Write asset manifest
        let manifest = AssetManifest(
            assets: assetMap,
            pages: pagePaths.sorted(),
            requiresServer: requiresServer
        )
        let writer = ManifestWriter()
        try writer.write(manifest, to: configuration.outputDirectory)

        try dependencyGraph.save()
    }

    // MARK: - Incremental build

    /// Rebuild only pages that depend on the given changed source files.
    public func incrementalBuild(
        changedFiles: [String],
        allPages: [RenderedPage],
        css: String = "",
        requiresServer: Bool = false
    ) async throws {
        try dependencyGraph.load()
        let affectedPaths = changedFiles.flatMap { await dependencyGraph.pagesAffectedBy(file: $0) }
        let affectedSet = Set(affectedPaths)
        let pagesToRebuild = allPages.filter { affectedSet.contains($0.path) }
        try await build(pages: pagesToRebuild, css: css, requiresServer: requiresServer)
    }

    // MARK: - Static route resolution

    /// Invoke every `.static`-mode route in `routes` against a dummy request and
    /// collect the resulting HTML.
    ///
    /// Routes with parameterised patterns (containing `:`) are skipped — use
    /// `StaticPage.instances()` directly to supply their rendered pages.
    ///
    /// - Parameters:
    ///   - routes: All registered application routes.
    ///   - renderer: Used to build the full HTML document from any rendered `Response`.
    /// - Returns: A list of ``RenderedPage`` values for each matched static route.
    public func resolveStaticPages(
        from routes: [Route],
        renderer: PageRenderer
    ) async throws -> [RenderedPage] {
        var pages: [RenderedPage] = []

        for route in routes where route.renderMode == .static {
            // Skip routes with path parameters (need StaticPage.instances())
            guard !route.pathPattern.contains(":") && !route.pathPattern.contains("*") else { continue }

            let dummyRequest = Request(
                method: route.method.flatMap { HTTPRequest.Method($0.rawValue) } ?? .get,
                uri: URI(path: route.pathPattern)
            )
            let response = try await route.handler(dummyRequest)

            let html: String
            switch response.body {
            case .html(let h):   html = h
            case .text(let t, _): html = t
            case .data(let d, _): html = String(data: d, encoding: .utf8) ?? ""
            case .json(let d):   html = String(data: d, encoding: .utf8) ?? ""
            case .empty:         html = ""
            }

            if !html.isEmpty {
                pages.append(RenderedPage(path: route.pathPattern, html: html))
            }
        }

        return pages
    }

    // MARK: - Private helpers

    private func writeHTML(_ html: String, to urlPath: String) throws {
        let relativePath: String
        if urlPath == "/" {
            relativePath = "index.html"
        } else {
            let stripped = urlPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            relativePath = stripped + "/index.html"
        }
        let fileURL = configuration.outputDirectory.appendingPathComponent(relativePath)
        try fm.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try html.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func copyPublicDirectory(into assetMap: inout [String: String]) throws {
        guard fm.fileExists(atPath: configuration.publicDirectory.path) else { return }
        let enumerator = fm.enumerator(
            at: configuration.publicDirectory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: .skipsHiddenFiles
        )
        while let fileURL = enumerator?.nextObject() as? URL {
            let relativePath = fileURL.path.dropFirst(configuration.publicDirectory.path.count)
            let destURL = configuration.outputDirectory.appendingPathComponent(String(relativePath))
            try fm.createDirectory(at: destURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            if fm.fileExists(atPath: destURL.path) {
                try fm.removeItem(at: destURL)
            }
            try fm.copyItem(at: fileURL, to: destURL)
            let name = fileURL.lastPathComponent
            assetMap[name] = name
        }
    }
}
