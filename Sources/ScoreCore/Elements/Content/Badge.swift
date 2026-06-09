/// A badge — a small inline label rendered as `<span class="badge">`.
public struct Badge: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<span class=\"badge\">\(content.renderHTML(context: &context))</span>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
