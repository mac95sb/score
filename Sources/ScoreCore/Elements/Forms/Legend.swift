/// The caption for a `Fieldset` element (`<legend>`).
///
/// ```swift
/// Fieldset {
///     Legend { "Personal information" }
///     Input(type: .text, name: "name", placeholder: "Full name")
/// }
/// ```
public struct Legend: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<legend>\(content.renderHTML(context: &context))</legend>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
