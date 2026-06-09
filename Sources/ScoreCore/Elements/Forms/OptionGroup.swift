/// A group of related `Option` elements inside a select (`<optgroup>`).
///
/// ```swift
/// Input(type: .select, name: "country") {
///     OptionGroup(label: "Europe") {
///         Option(value: "de") { "Germany" }
///         Option(value: "fr") { "France" }
///     }
///     OptionGroup(label: "Americas") {
///         Option(value: "us") { "United States" }
///     }
/// }
/// ```
public struct OptionGroup: View, _HTMLRenderable {
    let label: String
    let disabled: Bool
    let content: AnyView

    public init(label: String, disabled: Bool = false, @ViewBuilder content: () -> some View) {
        self.label = label
        self.disabled = disabled
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = "label=\"\(attributeEscape(label))\""
        if disabled { attrs += " disabled" }
        return "<optgroup \(attrs)>\(content.renderHTML(context: &context))</optgroup>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
