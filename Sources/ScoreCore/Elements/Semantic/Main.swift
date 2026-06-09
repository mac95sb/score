/// The main content area of a document (`<main>`).
///
/// There should be only one `Main` per page.
public struct Main: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<main>\(content.renderHTML(context: &context))</main>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
