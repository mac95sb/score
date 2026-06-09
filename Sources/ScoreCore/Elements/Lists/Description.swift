/// A description detail element (`<dd>`).
///
/// Used inside `DescriptionList` to define the value for a `Term`.
public struct Description: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<dd>\(content.renderHTML(context: &context))</dd>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
