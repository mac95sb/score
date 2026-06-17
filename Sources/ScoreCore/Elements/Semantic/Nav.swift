/// A navigation landmark — a section of the page with navigation links (`<nav>`).
///
/// Use `Nav` to wrap major groups of navigation links: the site header, a
/// breadcrumb trail, a table of contents, or pagination controls. Browsers and
/// assistive technologies expose each `Nav` as a `navigation` landmark, letting
/// screen reader users jump directly to or skip over navigation sections.
///
/// When a page has more than one `Nav`, provide distinct `label` values so
/// users can tell them apart (e.g. `"Main navigation"` vs `"Breadcrumb"`).
/// A single `Nav` on the page does not need a label.
///
/// Not every group of links needs to be a `Nav` — use it only for major
/// navigation blocks. Inline links within prose, for example, do not warrant
/// a `Nav` wrapper.
///
/// - Parameters:
///   - label: An accessible name for this navigation region, surfaced to
///     screen readers via `aria-label`. Required when multiple `Nav` elements
///     are present on the same page.
///   - content: The navigation links and any surrounding layout.
///
/// ## Example
///
/// ```swift
/// Nav(label: "Main navigation") {
///     HStack {
///         Link(to: "/") { "My Site" }
///             .font(weight: .semibold)
///         Spacer()
///         HStack {
///             NavLink(to: "/")        { "Home" }
///             NavLink(to: "/blog")    { "Blog" }
///             NavLink(to: "/about")   { "About" }
///         }
///         .flex(gap: 6)
///     }
///     .flex(align: .center)
///     .padding(x: 6, y: 4)
///     .frame(maxWidth: .px(1200))
///     .margin(x: .auto)
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <nav aria-label="Main navigation">…</nav>
/// ```
///
/// - SeeAlso: ``NavLink``, ``Link``, ``Header``
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
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = ""
        if let label = label { attrs += " aria-label=\"\(attributeEscape(label))\"" }
        if !extra.isEmpty { attrs += " style=\"\(extra)\"" }
        if let cls { attrs += " class=\"\(cls)\"" }
        let result = "<nav\(attrs)>\(content.renderHTML(context: &context))</nav>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
