/// A hyperlink element (`<a>`).
///
/// External links (starting with `http://` or `https://`) automatically receive
/// `target="_blank" rel="noopener noreferrer"` unless `external` is set explicitly.
///
/// ```swift
/// Link(to: "/blog") { "Read the blog" }
/// Link(to: "https://example.com") { "External site" }
/// Link(to: "https://example.com", external: false) { "Opens in same tab" }
/// ```
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
        var attrs = "href=\"\(attributeEscape(href))\""
        if isExternal {
            attrs += " target=\"_blank\" rel=\"noopener noreferrer\""
        }
        return "<a \(attrs)>\(content.renderHTML(context: &context))</a>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
