import Foundation

/// Page-specific metadata that overrides the application-level defaults.
///
/// Provide this from a `Page` conformance to customise `<title>`, Open Graph
/// tags, canonical URLs, and robots directives for a particular page.
public struct PageMetadata: Sendable {
    public let title: String?
    public let description: String?
    public let keywords: [String]?
    public let ogImage: String?
    public let ogType: OGType
    public let canonicalURL: String?
    public let robots: String?

    public init(
        title: String? = nil,
        description: String? = nil,
        keywords: [String]? = nil,
        ogImage: String? = nil,
        ogType: OGType = .website,
        canonicalURL: String? = nil,
        robots: String? = nil
    ) {
        self.title = title
        self.description = description
        self.keywords = keywords
        self.ogImage = ogImage
        self.ogType = ogType
        self.canonicalURL = canonicalURL
        self.robots = robots
    }
}

// MARK: - OGType

/// Open Graph object type for the `og:type` meta property.
public enum OGType: String, Sendable {
    case website
    case article
    case book
    case profile
    case video   = "video.movie"
    case music   = "music.song"
}
