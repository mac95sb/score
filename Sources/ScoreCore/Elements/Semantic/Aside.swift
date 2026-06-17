/// Content that is tangentially related to the surrounding page or section (`<aside>`).
///
/// Use `Aside` for supplementary content that complements, but is not essential
/// to, the main flow: pull quotes, sidebars, call-out boxes, related-links
/// panels, or advertising blocks. The element maps to the
/// `complementary` ARIA landmark role, allowing assistive technologies to
/// navigate to or skip past it independently.
///
/// An `Aside` inside an ``Article`` is considered related to that article;
/// one at the page level is considered related to the whole page.
///
/// ## Example
///
/// ```swift
/// HStack {
///     Main {
///         // Primary article content
///     }
///     Aside {
///         Heading(2) { "Related posts" }
///         for post in relatedPosts {
///             Link(to: "/blog/\(post.slug)") { post.title }
///         }
///     }
///     .frame(width: .px(260))
///     .padding(6)
///     .border(radius: .lg)
///     .background(color: .secondary)
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <aside>…</aside>
/// ```
///
/// - SeeAlso: ``Main``, ``Article``, ``Section``
public struct Aside: View, _HTMLRenderable {
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
        let result = "<aside\(attrs)>\(content.renderHTML(context: &context))</aside>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
