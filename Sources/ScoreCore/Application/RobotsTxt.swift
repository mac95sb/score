/// A `robots.txt` configuration for your Score application.
///
/// Score writes `robots.txt` to the build output automatically when a
/// `robotsTxt` value is declared on `Application`. Override per-path rules
/// to control crawler access to specific sections of your site.
///
/// ```swift
/// var robotsTxt: RobotsTxt {
///     RobotsTxt(disallowedPaths: ["/admin", "/api"])
/// }
/// ```
public struct RobotsTxt: Sendable {
    /// The user-agent this block applies to. Defaults to `"*"` (all crawlers).
    public var userAgent: String
    /// Paths crawlers are not allowed to access.
    public var disallowedPaths: [String]
    /// Paths crawlers are explicitly allowed to access (useful for overrides).
    public var allowedPaths: [String]
    /// Optional absolute URL of the XML sitemap.
    public var sitemapURL: String?

    public init(
        userAgent: String = "*",
        disallowedPaths: [String] = [],
        allowedPaths: [String] = [],
        sitemapURL: String? = nil
    ) {
        self.userAgent = userAgent
        self.disallowedPaths = disallowedPaths
        self.allowedPaths = allowedPaths
        self.sitemapURL = sitemapURL
    }

    /// The default configuration: all paths allowed, no sitemap declared.
    public static let `default` = RobotsTxt()

    /// Generates the `robots.txt` file content.
    public func generate() -> String {
        var lines: [String] = ["User-agent: \(userAgent)"]
        for path in allowedPaths {
            lines.append("Allow: \(path)")
        }
        for path in disallowedPaths {
            lines.append("Disallow: \(path)")
        }
        if disallowedPaths.isEmpty && allowedPaths.isEmpty {
            lines.append("Allow: /")
        }
        if let sitemap = sitemapURL {
            lines.append("")
            lines.append("Sitemap: \(sitemap)")
        }
        return lines.joined(separator: "\n") + "\n"
    }
}
