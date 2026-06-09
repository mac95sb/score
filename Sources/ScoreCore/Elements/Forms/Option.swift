/// A selectable option inside an `Input(type: .select)` element (`<option>`).
///
/// ```swift
/// Input(type: .select, name: "size") {
///     Option(value: "sm") { "Small" }
///     Option(value: "md", selected: true) { "Medium" }
///     Option(value: "lg") { "Large" }
/// }
/// ```
public struct Option: View, _HTMLRenderable {
    let value: String
    let selected: Bool
    let disabled: Bool
    let content: AnyView

    public init(
        value: String,
        selected: Bool = false,
        disabled: Bool = false,
        @ViewBuilder content: () -> some View
    ) {
        self.value = value
        self.selected = selected
        self.disabled = disabled
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = "value=\"\(attributeEscape(value))\""
        if selected { attrs += " selected" }
        if disabled { attrs += " disabled" }
        return "<option \(attrs)>\(content.renderHTML(context: &context))</option>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
