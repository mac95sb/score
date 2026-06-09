import Foundation

/// Tracks file-level dependencies between source files and the pages they affect.
///
/// When a source file changes, only pages that depend on it need to be
/// rebuilt, enabling fast incremental SSG builds.  The graph is persisted to
/// `.score/cache/dependency-graph.json` so it survives across invocations.
///
/// ```swift
/// await graph.addDependency(page: "/blog/hello-world", dependsOn: "Content/hello-world.md")
/// let affected = await graph.pagesAffectedBy(file: "Content/hello-world.md")
/// // ["blog/hello-world"]
/// ```
public actor DependencyGraph {
    /// page URL path → set of source file paths it depends on
    private var graph: [String: Set<String>] = [:]
    private let cacheDirectory: URL

    public init(cacheDirectory: URL) {
        self.cacheDirectory = cacheDirectory
    }

    // MARK: - Mutation

    /// Record that the page at `page` depends on the source file at `file`.
    public func addDependency(page: String, dependsOn file: String) {
        graph[page, default: []].insert(file)
    }

    /// Remove all dependency records for a given page (e.g. before re-scanning it).
    public func clearDependencies(for page: String) {
        graph.removeValue(forKey: page)
    }

    /// Clear all dependency records.
    public func clear() {
        graph.removeAll()
    }

    // MARK: - Query

    /// Return every page path that depends on the given source file.
    public func pagesAffectedBy(file: String) -> [String] {
        graph.compactMap { (page, deps) in
            deps.contains(file) ? page : nil
        }.sorted()
    }

    /// Return the source files that a given page depends on.
    public func dependencies(of page: String) -> Set<String> {
        graph[page] ?? []
    }

    /// All tracked page paths.
    public var allPages: [String] {
        Array(graph.keys).sorted()
    }

    // MARK: - Persistence

    /// Persist the dependency graph to `<cacheDirectory>/dependency-graph.json`.
    public func save() throws {
        try FileManager.default.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )
        // Convert Set<String> to [String] for JSON encoding
        let serialisable = graph.mapValues { Array($0).sorted() }
        let data = try JSONEncoder().encode(serialisable)
        let url = cacheDirectory.appendingPathComponent("dependency-graph.json")
        try data.write(to: url, options: .atomic)
    }

    /// Load the dependency graph from disk.
    ///
    /// Silently succeeds when the cache file does not exist yet (first build).
    public func load() throws {
        let url = cacheDirectory.appendingPathComponent("dependency-graph.json")
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([String: [String]].self, from: data)
        graph = decoded.mapValues { Set($0) }
    }
}
