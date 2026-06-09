/// A navigation landmark element (`<nav>`).
///
/// Provide `label` when the page contains multiple navigation regions
/// so assistive technologies can distinguish them.
///
/// ```swift
/// Nav(label: "Main") {
///     NavLink(to: "/") { "Home" }
///     NavLink(to: "/blog") { "Blog" }
/// }
/// ```
public struct Nav: View, _HTMLRenderable {
    let label: String?
    let content: AnyView

    public init(label: String? = nil, @ViewBuilder content: () -> some View) {
        self.label = label
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = ""
        if let label = label { attrs = " aria-label=\"\(attributeEscape(label))\"" }
        return "<nav\(attrs)>\(content.renderHTML(context: &context))</nav>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
