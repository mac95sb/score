/// A navigation link that automatically receives an active state when the current
/// URL matches its `to` path.
///
/// Score's JS runtime sets `data-active="true"` on the element when the browser
/// location matches `href`.
///
/// ```swift
/// NavLink(to: "/about") { "About" }
/// ```
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
        "<a href=\"\(attributeEscape(href))\" data-navlink>\(content.renderHTML(context: &context))</a>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
