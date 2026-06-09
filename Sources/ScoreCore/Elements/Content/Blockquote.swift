/// A block quotation element (`<blockquote>`).
public struct Blockquote: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<blockquote>\(content.renderHTML(context: &context))</blockquote>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
