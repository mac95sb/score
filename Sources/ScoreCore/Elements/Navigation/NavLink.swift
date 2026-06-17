/// A navigation link that highlights itself when the current URL matches its destination (`<a>`).
///
/// Use `NavLink` inside navigation menus (``Nav``) instead of plain ``Link``
/// when you want the active item to be visually distinguished. Score's JS
/// runtime sets `data-active="true"` on the anchor whenever the browser
/// location matches the `href`, enabling CSS like `[data-active="true"]` to
/// apply an active indicator without any server-side routing logic.
///
/// Like ``Link``, `NavLink` renders as a plain `<a>` tag. The `data-navlink`
/// attribute is added so the JS runtime can identify and update all nav links
/// on popstate events (e.g. back/forward navigation in an SPA).
///
/// - Parameters:
///   - href: The internal URL this link points to.
///   - content: The visible label or child views for the link.
///
/// ## Example
///
/// ```swift
/// Nav {
///     HStack(gap: 6) {
///         NavLink(to: "/")        { "Home" }
///         NavLink(to: "/blog")    { "Blog" }
///         NavLink(to: "/about")   { "About" }
///         NavLink(to: "/contact") { "Contact" }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <a href="/blog" data-navlink>Blog</a>
/// <!-- runtime adds data-active="true" when on /blog -->
/// ```
///
/// - SeeAlso: ``Link``, ``Nav``, ``Button``
public struct NavLink: View, _HTMLRenderable {
    let href: String
    let content: AnyView

    public init(to href: String, @ViewBuilder content: () -> some View) {
        self.href = href
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = "href=\"\(attributeEscape(href))\" data-navlink"
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
