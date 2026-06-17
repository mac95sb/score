/// A self-contained, independently distributable content unit (`<article>`).
///
/// Use `Article` for content that makes sense on its own when excerpted or
/// syndicated — blog posts, news items, forum threads, product cards, or
/// user-generated content entries. The element provides an implicit
/// `document` landmark role, helping screen readers and search engines
/// identify and navigate discrete pieces of content on the page.
///
/// When nesting `Article` elements, the inner article should be related to
/// the outer one (e.g. comments on a post). Use ``Section`` for thematic
/// groupings within the same page flow when syndication independence is not
/// the intent.
///
/// ## Example
///
/// ```swift
/// Article {
///     Heading(1) { post.title }
///         .font(size: .fourXL, weight: .bold)
///     Text { post.excerpt }
///         .font(color: .muted)
///     Divider().margin(y: 6)
///     RichText(markdown: post.content)
/// }
/// .frame(maxWidth: .px(720))
/// .margin(x: .auto)
/// .padding(8)
/// ```
///
/// ## HTML output
///
/// ```html
/// <article>…</article>
/// ```
///
/// - SeeAlso: ``Section``, ``Main``, ``Aside``, ``RichText``
public struct Article: View, _HTMLRenderable {
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
        let result = "<article\(attrs)>\(content.renderHTML(context: &context))</article>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
