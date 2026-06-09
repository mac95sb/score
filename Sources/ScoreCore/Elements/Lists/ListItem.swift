/// A list item element (`<li>`).
///
/// Used inside `List`, `DescriptionList`, or any `<ul>`/`<ol>` context.
///
/// ```swift
/// List {
///     ListItem { "Apple" }
///     ListItem { "Banana" }
/// }
/// ```
public struct ListItem: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<li>\(content.renderHTML(context: &context))</li>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
