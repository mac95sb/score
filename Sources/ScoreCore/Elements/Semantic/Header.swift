/// Introductory content or a group of navigational aids for a page or section (`<header>`).
///
/// Use `Header` to wrap the opening content of a page or sectioning element:
/// site branding, a main ``Nav``, page titles, or a hero block. When `Header`
/// is a direct descendant of `<body>` (i.e. a page-level header), it carries
/// the `banner` ARIA landmark role, giving screen reader users a fast path to
/// the top of the page. Inside an ``Article``, ``Section``, or ``Aside``,
/// `Header` is treated as a non-landmark container for that section's
/// introductory content.
///
/// ## Example
///
/// ```swift
/// Header {
///     HStack {
///         Link(to: "/") { "My Site" }
///             .font(size: .xl, weight: .bold)
///         Spacer()
///         Nav(label: "Main navigation") {
///             HStack {
///                 NavLink(to: "/") { "Home" }
///                 NavLink(to: "/blog") { "Blog" }
///                 NavLink(to: "/about") { "About" }
///             }
///             .flex(gap: 6)
///         }
///     }
///     .flex(align: .center)
///     .padding(x: 6, y: 4)
///     .frame(maxWidth: .px(1200))
///     .margin(x: .auto)
/// }
/// .background(color: .surface)
/// .border(color: .muted.opacity(0.15), edge: .bottom)
/// .position(.sticky, top: 0)
/// .position(zIndex: 10)
/// ```
///
/// ## HTML output
///
/// ```html
/// <header>…</header>
/// ```
///
/// - SeeAlso: ``Footer``, ``Nav``, ``Main``
public struct Header: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = extra.isEmpty ? "" : " style=\"\(extra)\""
        if let cls { attrs += " class=\"\(cls)\"" }
        let result = "<header\(attrs)>\(content.renderHTML(context: &context))</header>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
