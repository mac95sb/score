/// A description list element (`<dl>`).
///
/// Contains `Term` and `Description` child elements.
///
/// ```swift
/// DescriptionList {
///     Term { "Score" }
///     Description { "A Swift web framework." }
/// }
/// ```
public struct DescriptionList: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<dl>\(content.renderHTML(context: &context))</dl>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
