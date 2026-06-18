import Foundation

/// A parsed content file — typically a markdown file with YAML frontmatter.
///
/// Loaded by `ContentStore` from the `Content/` directory tree. Each file
/// produces one `ContentPost` whose `slug` is derived from the file name.
public struct ContentPost: Sendable {
    /// URL slug derived from the file name (without extension).
    public let slug: String
    /// The raw markdown body (frontmatter stripped).
    public let content: String
    /// Parsed YAML frontmatter.
    public let frontmatter: Frontmatter
    /// Absolute filesystem path, used for incremental build invalidation.
    public let filePath: String

    public init(
        slug: String,
        content: String,
        frontmatter: Frontmatter,
        filePath: String = ""
    ) {
        self.slug = slug
        self.content = content
        self.frontmatter = frontmatter
        self.filePath = filePath
    }
}

// MARK: - String.slugified()

extension String {
    /// Convert a human-readable string to a URL-safe slug.
    ///
    /// ```swift
    /// "My Swift Journey".slugified()  // "my-swift-journey"
    /// "Hello, World!"   .slugified()  // "hello-world"
    /// ```
    public func slugified() -> String {
        // Lower-case, replace non-alphanumeric runs with a single hyphen
        let allowedCharacters = CharacterSet.alphanumerics
        let components = self.lowercased()
            .unicodeScalars
            .split { !allowedCharacters.contains($0) }
            .map { String($0) }
        return
            components
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }
}
