/// A thematic grouping element (`<section>`).
///
/// ```swift
/// Section(id: "hero") {
///     Heading(1) { "Welcome" }
/// }
/// ```
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
        var attrs = ""
        if let id = id { attrs = " id=\"\(attributeEscape(id))\"" }
        return "<section\(attrs)>\(content.renderHTML(context: &context))</section>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
