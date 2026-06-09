/// A fieldset groups related form controls (`<fieldset>`).
///
/// Use `Legend` as the first child to provide a caption for the group.
///
/// ```swift
/// Fieldset {
///     Legend { "Shipping address" }
///     Input(type: .text, name: "street", placeholder: "Street")
///     Input(type: .text, name: "city",   placeholder: "City")
/// }
/// ```
public struct Fieldset: View, _HTMLRenderable {
    let disabled: Bool
    let content: AnyView

    public init(disabled: Bool = false, @ViewBuilder content: () -> some View) {
        self.disabled = disabled
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = ""
        if disabled { attrs = " disabled" }
        return "<fieldset\(attrs)>\(content.renderHTML(context: &context))</fieldset>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
