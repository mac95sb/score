import Foundation

/// Loads and caches content files from the `Content/` directory tree.
///
/// Files are parsed from markdown with YAML frontmatter. Results are cached
/// in-memory; call `invalidate()` to flush the cache (used in dev/watch mode).
///
/// ```swift
/// let posts = try await ContentStore.posts()
/// let post  = try await ContentStore.post(slug: "hello-world")
/// ```
public actor ContentStore {
    // MARK: - Shared instance

    public static let shared = ContentStore()

    // MARK: - Cache

    /// Per-slug cache across all directories.
    private var cache: [String: ContentPost] = [:]
    /// Fully loaded directory caches, keyed by subdirectory name.
    private var directoryCache: [String: [ContentPost]] = [:]

    private init() {}

    // MARK: - Public API (static convenience)

    /// Load all posts from `Content/posts/`, sorted newest-first.
    public static func posts(config: ContentStoreConfig = .default) async throws -> [ContentPost] {
        try await shared.loadContent(in: "posts", config: config)
    }

    /// Load a single post by slug from `Content/posts/`.
    public static func post(slug: String, config: ContentStoreConfig = .default) async throws -> ContentPost? {
        try await shared.loadPost(slug: slug, in: "posts", config: config)
    }

    /// Load all content files from `Content/<directory>/`, sorted newest-first.
    public static func content(in directory: String, config: ContentStoreConfig = .default) async throws -> [ContentPost] {
        try await shared.loadContent(in: directory, config: config)
    }

    // MARK: - Private loading

    private func loadPost(slug: String, in directory: String, config: ContentStoreConfig) async throws -> ContentPost? {
        if let cached = cache[slug] { return cached }
        let posts = try await loadContent(in: directory, config: config)
        return posts.first { $0.slug == slug }
    }

    private func loadContent(in directory: String, config: ContentStoreConfig) async throws -> [ContentPost] {
        if let cached = directoryCache[directory] { return cached }

        let contentDir = URL(fileURLWithPath: "Content/\(directory)")
        let fm = FileManager.default

        guard fm.fileExists(atPath: contentDir.path) else { return [] }

        let files: [URL]
        do {
            files = try fm.contentsOfDirectory(
                at: contentDir,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
            .filter { $0.pathExtension == "md" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        } catch {
            return []
        }

        var posts: [ContentPost] = []
        for file in files {
            if let post = try await parseFile(at: file) {
                posts.append(post)
            }
        }

        posts.sort {
            ($0.frontmatter.date ?? .distantPast) > ($1.frontmatter.date ?? .distantPast)
        }

        directoryCache[directory] = posts
        return posts
    }

    private func parseFile(at url: URL) async throws -> ContentPost? {
        let slug = url.deletingPathExtension().lastPathComponent

        // Return cached entry if available.
        if let cached = cache[slug] { return cached }

        let rawContent = try String(contentsOf: url, encoding: .utf8)

        let post: ContentPost
        if rawContent.hasPrefix("---") {
            // Strip the opening `---`, then split on the closing `---`
            let afterOpening = String(rawContent.dropFirst(3))
            let parts = afterOpening.components(separatedBy: "\n---")
            guard parts.count >= 2 else { return nil }

            let yamlString = String(parts[0])
            let bodyParts = parts.dropFirst()
            let body =
                bodyParts
                .joined(separator: "\n---")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let frontmatter = Frontmatter.parse(from: yamlString)
            post = ContentPost(slug: slug, content: body, frontmatter: frontmatter, filePath: url.path)
        } else {
            // No frontmatter — treat the whole file as body, derive title from slug.
            let inferredTitle =
                slug
                .replacingOccurrences(of: "-", with: " ")
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
            let frontmatter = Frontmatter(title: inferredTitle)
            post = ContentPost(slug: slug, content: rawContent, frontmatter: frontmatter, filePath: url.path)
        }

        cache[slug] = post
        return post
    }

    // MARK: - Cache invalidation

    /// Flush all cached content (call this on file-system changes in dev/watch mode).
    public func invalidate() {
        cache.removeAll()
        directoryCache.removeAll()
    }

    /// Flush the cache for a specific directory only.
    public func invalidate(directory: String) {
        // Also remove individual slugs belonging to that directory.
        if let posts = directoryCache[directory] {
            for post in posts { cache.removeValue(forKey: post.slug) }
        }
        directoryCache.removeValue(forKey: directory)
    }
}
