/// A footer for the nearest sectioning ancestor or the document as a whole (`<footer>`).
///
/// Use `Footer` at the bottom of a page to hold copyright notices, secondary
/// navigation links, social media links, or legal text. When placed inside an
/// ``Article`` or ``Section``, it is the footer for that specific piece of
/// content rather than the page.
///
/// A page-level `Footer` (a direct child of the document `<body>`) receives the
/// `contentinfo` ARIA landmark role automatically, making it discoverable by
/// screen readers and other assistive tools. Footers nested inside sectioning
/// elements do not carry this landmark.
///
/// ## Example
///
/// ```swift
/// Footer {
///     HStack {
///         Text { "© 2026 My Site. Built with " }
///             .font(size: .sm, color: .muted)
///         Link(to: "https://github.com/mac95sb/score") { "Score" }
///             .font(size: .sm, color: .primary)
///         Text { "." }
///             .font(size: .sm, color: .muted)
///     }
///     .flex(justify: .center, align: .center)
///     .padding(8)
/// }
/// .border(color: .muted.opacity(0.15), edge: .top)
/// ```
///
/// ## HTML output
///
/// ```html
/// <footer>…</footer>
/// ```
///
/// - SeeAlso: ``Header``, ``Main``, ``Nav``
public struct Footer: View, _HTMLRenderable {
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
        let result = "<footer\(attrs)>\(content.renderHTML(context: &context))</footer>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
