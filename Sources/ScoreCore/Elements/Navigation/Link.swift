/// A hyperlink that navigates to a URL when clicked (`<a>`).
///
/// Use `Link` for navigation — internal routes, external sites, mailto, tel,
/// or anchor links. For navigation links that automatically highlight when the
/// current URL matches, use ``NavLink`` instead.
///
/// External links (those starting with `https://` or `http://`) automatically
/// receive `target="_blank" rel="noopener noreferrer"` to open in a new tab
/// safely. Pass `external: false` to suppress this behaviour for an absolute
/// URL that should still open in the same tab.
///
/// - Parameters:
///   - href: The destination URL. Can be a relative path, absolute URL, `mailto:`, `tel:`, or anchor.
///   - external: Override the automatic external-link detection. `nil` (default) auto-detects
///     based on whether `href` starts with `http://` or `https://`.
///   - content: The link's visible label or child views.
///
/// ## Example
///
/// ```swift
/// // Internal navigation
/// Link(to: "/blog") { "Read the blog" }
///
/// // External site — opens in new tab automatically
/// Link(to: "https://swift.org") { "Swift.org" }
///
/// // Inline text link
/// Text {
///     "Read the "
///     Link(to: "/docs/getting-started") { "Getting Started guide" }
///     " before diving in."
/// }
///
/// // Email link
/// Link(to: "mailto:hello@example.com") { "Contact us" }
/// ```
///
/// ## HTML output
///
/// ```html
/// <a href="/blog">Read the blog</a>
/// <a href="https://swift.org" target="_blank" rel="noopener noreferrer">Swift.org</a>
/// ```
///
/// - SeeAlso: ``NavLink``, ``Button``, ``Nav``
public struct Link: View, _HTMLRenderable {
    let href: String
    let external: Bool?
    let content: AnyView

    public init(to href: String, external: Bool? = nil, @ViewBuilder content: () -> some View) {
        self.href = href
        self.external = external
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    var isExternal: Bool {
        external ?? (href.hasPrefix("https://") || href.hasPrefix("http://"))
    }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = "href=\"\(attributeEscape(href))\""
        if isExternal { attrs += " target=\"_blank\" rel=\"noopener noreferrer\"" }
        if !extra.isEmpty { attrs += " style=\"\(extra)\"" }
        if let cls { attrs += " class=\"\(cls)\"" }
        let result = "<a \(attrs)>\(content.renderHTML(context: &context))</a>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
