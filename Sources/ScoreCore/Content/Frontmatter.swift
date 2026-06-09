import Foundation

/// YAML frontmatter parsed from a markdown content file.
///
/// Frontmatter is a block of YAML between `---` delimiters at the top of a
/// markdown file. Score parses the standard fields listed below and exposes
/// any additional fields via the `custom(_:)` subscript.
public struct Frontmatter: Sendable {
    /// The content title.
    public let title: String
    /// A short summary or lead paragraph.
    public let excerpt: String?
    /// Publication date parsed from ISO 8601 format.
    public let date: Date?
    /// Topic tags associated with the content.
    public let tags: [String]
    /// Whether the content is publicly visible.
    public let published: Bool
    /// Relative path or URL for the cover image.
    public let cover: String?

    private let customFields: [String: String]

    public init(
        title: String,
        excerpt: String? = nil,
        date: Date? = nil,
        tags: [String] = [],
        published: Bool = false,
        cover: String? = nil,
        custom: [String: String] = [:]
    ) {
        self.title = title
        self.excerpt = excerpt
        self.date = date
        self.tags = tags
        self.published = published
        self.cover = cover
        self.customFields = custom
    }

    /// Access a custom (non-standard) frontmatter field by key.
    public func custom(_ key: String) -> String? { customFields[key] }

    // MARK: - Parsing

    /// Parse a Frontmatter value from a YAML-format string.
    ///
    /// Supports simple `key: value` pairs. Quoted string values have their
    /// surrounding `"` or `'` characters stripped. The `tags` field may be
    /// expressed as a YAML inline sequence: `[tag1, tag2]`.
    public static func parse(from yaml: String) -> Frontmatter {
        var fields: [String: String] = [:]

        for line in yaml.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
            let parts = trimmed.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { continue }
            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            fields[key] = value
        }

        // Date
        let dateFormatter = ISO8601DateFormatter()
        let date = fields["date"].flatMap { dateFormatter.date(from: $0) }

        // Tags — accept `[tag1, tag2]` or `tag1, tag2`
        let tagsRaw = fields["tags"] ?? ""
        let tags = tagsRaw
            .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces)
                     .trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) }
            .filter { !$0.isEmpty }

        // Custom fields — everything that is not a standard key
        let standardKeys: Set<String> = ["title", "excerpt", "date", "tags", "published", "cover"]
        var custom = fields
        standardKeys.forEach { custom.removeValue(forKey: $0) }

        return Frontmatter(
            title: fields["title"] ?? "",
            excerpt: fields["excerpt"],
            date: date,
            tags: tags,
            published: fields["published"]?.lowercased() == "true",
            cover: fields["cover"],
            custom: custom
        )
    }
}
