/// A CSS grid container element.
///
/// ```swift
/// Grid(columns: 3) {
///     ArticleCard(post: post1)
///     ArticleCard(post: post2)
///     ArticleCard(post: post3)
/// }
/// ```
public struct Grid: View, _HTMLRenderable {
    let columns: Int?
    let content: AnyView

    public init(columns: Int? = nil, @ViewBuilder content: () -> some View) {
        self.columns = columns
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var style = "display:grid"
        if let columns = columns {
            style += ";grid-template-columns:repeat(\(columns),minmax(0,1fr))"
        }
        return "<div style=\"\(style)\">\(content.renderHTML(context: &context))</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
