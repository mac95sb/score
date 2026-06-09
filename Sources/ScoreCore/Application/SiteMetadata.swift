import Foundation

/// Application-wide metadata emitted into `<head>` for SEO, Open Graph, and social cards.
public struct SiteMetadata: Sendable {
    public let siteName: String
    public let titleSeparator: String
    public let description: String
    public let baseURL: String
    public let locale: String
    public let twitterHandle: String?
    public let ogImage: String?

    public init(
        siteName: String,
        titleSeparator: String = " | ",
        description: String = "",
        baseURL: String = "",
        locale: String = "en",
        twitterHandle: String? = nil,
        ogImage: String? = nil
    ) {
        self.siteName = siteName
        self.titleSeparator = titleSeparator
        self.description = description
        self.baseURL = baseURL
        self.locale = locale
        self.twitterHandle = twitterHandle
        self.ogImage = ogImage
    }

    // MARK: - Title generation

    /// Compose the `<title>` element string for a page.
    ///
    /// - Parameter page: Optional page-specific title. When `nil` or empty the
    ///   site name is used verbatim.
    public func title(page: String?) -> String {
        if let page, !page.isEmpty {
            return "\(page)\(titleSeparator)\(siteName)"
        }
        return siteName
    }

    // MARK: - Head HTML generation

    /// Generate the `<meta>`, `<link>`, and `<title>` tags for a page.
    ///
    /// - Parameter pageMetadata: Optional page-level overrides.
    public func headHTML(pageMetadata: PageMetadata? = nil) -> String {
        var html = ""
        let pageTitle = title(page: pageMetadata?.title)
        let pageDescription = pageMetadata?.description ?? description
        let pageOGImagePath = pageMetadata?.ogImage ?? ogImage
        let pageOGImage = pageOGImagePath.map { baseURL + $0 } ?? ""
        let canonicalPath = pageMetadata?.canonicalURL
        let canonical = canonicalPath.map { baseURL + $0 } ?? ""

        // Basic head
        html += "<meta charset=\"UTF-8\">"
        html += "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
        html += "<meta name=\"generator\" content=\"Score\">"
        html += "<title>\(htmlEscape(pageTitle))</title>"

        if !pageDescription.isEmpty {
            html += "<meta name=\"description\" content=\"\(attributeEscape(pageDescription))\">"
        }

        // Robots
        if let robots = pageMetadata?.robots {
            html += "<meta name=\"robots\" content=\"\(attributeEscape(robots))\">"
        }

        // Keywords
        if let keywords = pageMetadata?.keywords, !keywords.isEmpty {
            html += "<meta name=\"keywords\" content=\"\(attributeEscape(keywords.joined(separator: ", ")))\">"
        }

        // Open Graph
        html += "<meta property=\"og:title\" content=\"\(attributeEscape(pageTitle))\">"
        html += "<meta property=\"og:type\" content=\"\(pageMetadata?.ogType.rawValue ?? OGType.website.rawValue)\">"
        if !pageOGImage.isEmpty {
            html += "<meta property=\"og:image\" content=\"\(attributeEscape(pageOGImage))\">"
        }
        if !pageDescription.isEmpty {
            html += "<meta property=\"og:description\" content=\"\(attributeEscape(pageDescription))\">"
        }
        if !baseURL.isEmpty {
            html += "<meta property=\"og:site_name\" content=\"\(attributeEscape(siteName))\">"
        }

        // Twitter card
        if let handle = twitterHandle {
            html += "<meta name=\"twitter:card\" content=\"summary_large_image\">"
            html += "<meta name=\"twitter:site\" content=\"\(attributeEscape(handle))\">"
            html += "<meta name=\"twitter:title\" content=\"\(attributeEscape(pageTitle))\">"
            if !pageDescription.isEmpty {
                html += "<meta name=\"twitter:description\" content=\"\(attributeEscape(pageDescription))\">"
            }
            if !pageOGImage.isEmpty {
                html += "<meta name=\"twitter:image\" content=\"\(attributeEscape(pageOGImage))\">"
            }
        }

        // Canonical URL
        if !canonical.isEmpty {
            html += "<link rel=\"canonical\" href=\"\(attributeEscape(canonical))\">"
        }

        return html
    }
}
