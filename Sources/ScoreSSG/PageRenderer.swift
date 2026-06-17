import Foundation
import ScoreCore
import ScoreHTTP
import ScoreRouter

/// Renders a single `Page` to a complete HTML document string.
///
/// `PageRenderer` combines the view tree, theme CSS variables, collected
/// component CSS, `<link>` tags, and `<script>` tags into a self-contained
/// `<!DOCTYPE html>` document.
///
/// ```swift
/// let renderer = PageRenderer(siteMetadata: site)
/// let html = try renderer.render(BlogIndexPage(posts: posts))
/// ```
public struct PageRenderer: Sendable {
    public let theme: SiteTheme
    public let siteMetadata: SiteMetadata
    /// Inline `<script>` tags injected into every rendered page (e.g. dev hot-reload JS).
    public let defaultInlineScripts: [String]

    // Pre-computed once from the immutable theme — avoids rebuilding on every render call.
    private let themeCSS: String
    private let themeFontLinks: String

    public init(
        theme: SiteTheme = .default,
        siteMetadata: SiteMetadata,
        defaultInlineScripts: [String] = []
    ) {
        self.theme = theme
        self.siteMetadata = siteMetadata
        self.defaultInlineScripts = defaultInlineScripts
        self.themeCSS = theme.cssVariables()
        self.themeFontLinks = theme.fontLinkTags()
    }

    // MARK: - Full page render

    /// Render a `Page` to a complete HTML document.
    ///
    /// - Parameters:
    ///   - page: The page to render.
    ///   - cssLinks: Paths to external CSS files (e.g. fingerprinted bundles).
    ///   - scriptSrcs: Paths to external JS module files.
    ///   - inlineCSS: CSS string to inject inline inside a `<style>` tag after
    ///     the theme variables.
    public func render<P: Page>(
        _ page: P,
        cssLinks: [String] = [],
        scriptSrcs: [String] = [],
        inlineCSS: String = "",
        inlineScripts: [String] = []
    ) throws -> String {
        // 1. Render the view body to HTML — per-element scoped CSS accumulates in ctx.cssBuffer
        var ctx = RenderContext()
        ctx.componentTypeName = String(describing: type(of: page))
        let bodyHTML = page.body._renderInto(&ctx)

        // 2. Build <head> content
        let pageMetadata = page.metadata
        let seoHTML = siteMetadata.headHTML(pageMetadata: pageMetadata)

        var headParts: [String] = []
        headParts.append(seoHTML)

        // Font preconnect / preload / stylesheet links — must come before CSS
        if !themeFontLinks.isEmpty {
            headParts.append(themeFontLinks)
        }

        // Theme CSS variables (color tokens, radii, shadows, component styles, custom themes/palettes)
        if !themeCSS.isEmpty {
            headParts.append("<style>\(themeCSS)</style>")
        }

        // Per-element scoped CSS collected during rendering (hover, media, animation, dark-mode)
        let scopedCSS = ctx.cssBuffer + inlineCSS
        if !scopedCSS.isEmpty {
            headParts.append("<style>\(scopedCSS)</style>")
        }

        // External CSS links
        for link in cssLinks {
            headParts.append("<link rel=\"stylesheet\" href=\"\(attributeEscape(link))\">")
        }

        // Script modules
        for src in scriptSrcs {
            headParts.append("<script type=\"module\" src=\"\(attributeEscape(src))\"></script>")
        }

        // Inline scripts (e.g. dev hot-reload)
        for script in (defaultInlineScripts + inlineScripts) {
            headParts.append("<script>\(script)</script>")
        }

        let headHTML = headParts.joined()

        // 3. Assemble document
        // Note: SiteMetadata.headHTML already emits <meta charset> and <meta viewport>,
        // so we intentionally omit them here to avoid duplication.
        return """
        <!DOCTYPE html>\
        <html lang="\(attributeEscape(siteMetadata.locale))">\
        <head>\(headHTML)</head>\
        <body>\(bodyHTML)</body>\
        </html>
        """
    }

    // MARK: - CSS collection

    /// Collect and return all CSS produced by the view tree of a page.
    ///
    /// The returned string contains the minified component styles ready for
    /// injection or writing to a bundle file.
    public func collectCSS<P: Page>(from page: P) -> String {
        let componentTypeName = String(describing: type(of: page))
        let collector = CSSCollector()
        let rules = collector.collect(from: page.body, componentTypeName: componentTypeName)
        return rules.map { $0.renderMinified() }.joined()
    }

    // MARK: - Body-only render (for incremental / ISR)

    /// Render only the `<body>` content of a page, without the surrounding
    /// HTML document shell.  Useful for server-side partial updates.
    public func renderBody<P: Page>(_ page: P) -> String {
        var ctx = RenderContext()
        ctx.componentTypeName = String(describing: type(of: page))
        return page.body._renderInto(&ctx)
    }
}
