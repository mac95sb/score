import Foundation

/// A full page in a Score application.
///
/// Pages may be static (pre-rendered at build time) or server-rendered.
/// Score infers the render mode from the route declaration. Provide
/// `metadata` to override the application-level defaults for this page.
///
/// ```swift
/// struct BlogPostPage: Page {
///     let post: Post
///
///     var metadata: PageMetadata? {
///         PageMetadata(title: post.title, description: post.excerpt)
///     }
///
///     var body: some View {
///         Main {
///             Article {
///                 Heading(1) { post.title }
///             }
///         }
///     }
/// }
/// ```
public protocol Page: View {
    /// Page-specific metadata that overrides the application default.
    var metadata: PageMetadata? { get }

    /// The content theme applied to ``RichText`` blocks rendered on this page.
    var contentTheme: ContentTheme { get }
}

extension Page {
    /// Returns `nil` by default, falling back to the application-level metadata.
    public var metadata: PageMetadata? { nil }

    /// Uses ``ContentTheme/default`` unless the page overrides it.
    public var contentTheme: ContentTheme { .default }
}

// MARK: - StaticPage

/// A page that provides static paths for pre-rendering at build time.
///
/// Implement `instances()` to tell the SSG which records to pre-render,
/// and `path` to declare the URL for each instance.
///
/// ```swift
/// extension BlogPostPage: StaticPage {
///     static func instances() async throws -> [BlogPostPage] {
///         try await ContentStore.posts()
///             .filter { $0.frontmatter.published }
///             .map { BlogPostPage(post: $0) }
///     }
///     var path: String { "/blog/\(post.frontmatter.title.slugified())" }
/// }
/// ```
public protocol StaticPage: Page {
    /// Discover all instances of this page type for static pre-rendering.
    static func instances() async throws -> [Self]

    /// The URL path for this particular page instance.
    var path: String { get }
}
