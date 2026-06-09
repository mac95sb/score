/// A text element that renders as `<p>` by default, or `<span>` when inline.
///
/// For simple text content, prefer string literals directly in parent closures:
/// ```swift
/// VStack {
///     "Some inline text"          // → escaped text node
///     Text { "Paragraph text." }  // → <p>
///     Text(inline: true) { "Inline span." }  // → <span>
/// }
/// ```
public struct Text: View, _HTMLRenderable {
    let content: AnyView
    let inline: Bool?

    public init(inline: Bool? = nil, @ViewBuilder content: () -> some View) {
        self.inline = inline
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let inner = content.renderHTML(context: &context)
        let tag = (inline == true) ? "span" : "p"
        return "<\(tag)>\(inner)</\(tag)>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
