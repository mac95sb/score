/// The visible heading of a `Details` element (`<summary>`).
///
/// ```swift
/// Details {
///     Summary { "Click to expand" }
///     Text { "Hidden content." }
/// }
/// ```
public struct Summary: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<summary>\(content.renderHTML(context: &context))</summary>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
