/// A thematic grouping of content within a page or document (`<section>`).
///
/// Use `Section` to carve a page into named, thematic regions — a hero block,
/// a features grid, a testimonials strip, a contact form, and so on. Each
/// `Section` should ideally have a heading (``Heading``) that describes its
/// theme. When a heading is not visible, provide an `aria-label` or
/// `aria-labelledby` attribute through the `id` parameter combined with a
/// heading's `id` attribute.
///
/// `Section` is not a generic container — use ``Stack``, ``VStack``, or
/// ``HStack`` when you only need layout without semantic meaning. Choose
/// ``Article`` when the content is independently distributable (blog posts,
/// news items), and `Section` when the content is one part of a larger whole.
///
/// - Parameters:
///   - id: An optional HTML `id` attribute. Useful for in-page anchor links
///     and pairing with `aria-labelledby`.
///   - content: The thematically related views inside this section.
///
/// ## Example
///
/// ```swift
/// Section(id: "features") {
///     Heading(2) { "What you get" }
///         .font(size: .threeXL, weight: .bold)
///         .margin(bottom: 8)
///     Grid(columns: 3) {
///         for feature in features {
///             FeatureCard(feature: feature)
///         }
///     }
///     .flex(gap: 6)
/// }
/// .frame(maxWidth: .px(1200))
/// .margin(x: .auto)
/// .padding(8)
/// ```
///
/// ## HTML output
///
/// ```html
/// <section id="features">…</section>
/// ```
///
/// - SeeAlso: ``Article``, ``Main``, ``Aside``, ``Header``, ``Footer``
public struct Section: View, _HTMLRenderable {
    let id: String?
    let content: AnyView

    public init(id: String? = nil, @ViewBuilder content: () -> some View) {
        self.id = id
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = ""
        if let id = id { attrs += " id=\"\(attributeEscape(id))\"" }
        if !extra.isEmpty { attrs += " style=\"\(extra)\"" }
        if let cls { attrs += " class=\"\(cls)\"" }
        let result = "<section\(attrs)>\(content.renderHTML(context: &context))</section>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
