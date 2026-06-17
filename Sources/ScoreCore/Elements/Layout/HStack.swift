/// A horizontal flex container (`<div>` with `flex-direction: row`).
///
/// `HStack` is a convenience wrapper around ``Stack`` that pre-applies
/// `display: flex; flex-direction: row`. Use it to arrange children side by
/// side. Add `.flex(gap:)`, `.flex(align:)`, `.flex(justify:)`, and
/// `.flex(wrap:)` modifiers to fine-tune the layout.
///
/// For vertical stacking use ``VStack``; for absolute-position layering use
/// ``ZStack``; for CSS grid layouts use ``Grid``.
///
/// - Parameters:
///   - id: An optional HTML `id` attribute.
///   - content: The child views arranged horizontally.
///
/// ## Example
///
/// ```swift
/// HStack {
///     Image(src: "/avatar.jpg", alt: "Avatar")
///         .frame(width: .px(40), height: .px(40))
///         .border(radius: .full)
///     VStack {
///         Text { author.name }.font(weight: .semibold)
///         Text { author.role }.font(size: .sm, color: .muted)
///     }
/// }
/// .flex(gap: 3, align: .center)
/// ```
///
/// ## HTML output
///
/// ```html
/// <div style="display:flex;flex-direction:row;…">…</div>
/// ```
///
/// - SeeAlso: ``VStack``, ``Stack``, ``ZStack``, ``Grid``
public struct HStack: View, _HTMLRenderable {
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
        var style = "display:flex;flex-direction:row"
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
