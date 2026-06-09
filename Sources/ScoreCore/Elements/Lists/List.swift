/// An ordered or unordered list element (`<ol>` or `<ul>`).
///
/// ```swift
/// List {
///     ListItem { "First" }
///     ListItem { "Second" }
/// }
///
/// List(.ordered) {
///     ListItem { "Step one" }
///     ListItem { "Step two" }
/// }
/// ```
public struct List: View, _HTMLRenderable {
    let style: ListStyle
    let content: AnyView

    public init(_ style: ListStyle = .unordered, @ViewBuilder content: () -> some View) {
        self.style = style
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        switch style {
        case .ordered, .decimal:
            return "<ol>\(content.renderHTML(context: &context))</ol>"
        case .alpha:
            return "<ol type=\"a\">\(content.renderHTML(context: &context))</ol>"
        case .unordered, .none:
            return "<ul>\(content.renderHTML(context: &context))</ul>"
        }
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
