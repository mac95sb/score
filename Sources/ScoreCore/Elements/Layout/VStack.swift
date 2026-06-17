/// A vertical flex container (`<div>` with `flex-direction: column`).
///
/// `VStack` is a convenience wrapper around ``Stack`` that pre-applies
/// `display: flex; flex-direction: column`. Use it to stack children top to
/// bottom. Add `.flex(gap:)`, `.flex(align:)`, and `.flex(justify:)` modifiers
/// to control spacing and alignment.
///
/// For horizontal stacking use ``HStack``; for absolute-position layering use
/// ``ZStack``; for CSS grid layouts use ``Grid``.
///
/// - Parameters:
///   - id: An optional HTML `id` attribute.
///   - content: The child views stacked vertically.
///
/// ## Example
///
/// ```swift
/// VStack {
///     Heading(3) { post.title }
///         .font(size: .xl, weight: .semibold)
///     Text { post.excerpt }
///         .font(size: .sm, color: .muted)
///         .margin(top: 2)
///     Link(to: "/blog/\(post.slug)") { "Read more →" }
///         .font(size: .sm, color: .primary)
///         .margin(top: 4)
/// }
/// .flex(gap: 0)
/// .padding(6)
/// .border(radius: .lg)
/// .background(color: .surface)
/// ```
///
/// ## HTML output
///
/// ```html
/// <div style="display:flex;flex-direction:column;…">…</div>
/// ```
///
/// - SeeAlso: ``HStack``, ``Stack``, ``ZStack``, ``Grid``
public struct VStack: View, _HTMLRenderable {
    let content: AnyView
    let id: String?

    public init(id: String? = nil, @ViewBuilder content: () -> some View) {
        self.id = id
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var style = "display:flex;flex-direction:column"
        if !extra.isEmpty { style += ";\(extra)" }
        var attrs = " style=\"\(style)\""
        if let cls { attrs += " class=\"\(cls)\"" }
        if let id = id { attrs = " id=\"\(attributeEscape(id))\"\(attrs)" }
        let result = "<div\(attrs)>\(content.renderHTML(context: &context))</div>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
