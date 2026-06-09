/// A page or section header element (`<header>`).
public struct Header: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<header>\(content.renderHTML(context: &context))</header>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
