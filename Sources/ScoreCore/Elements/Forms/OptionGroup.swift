/// A labelled group of ``Option`` elements inside a select dropdown (`<optgroup>`).
///
/// Use `OptionGroup` to visually and semantically separate clusters of related
/// choices within an `Input(type: .select)`. The `label` is displayed as a
/// non-selectable header above the group. Browsers render the label in bold or
/// italic by default. Options inside a disabled `OptionGroup` are all
/// individually disabled.
///
/// - Parameters:
///   - label: The visible, non-selectable heading for this group of options.
///   - disabled: When `true`, all options inside the group are disabled. Defaults to `false`.
///   - content: The ``Option`` elements belonging to this group.
///
/// ## Example
///
/// ```swift
/// Input(type: .select, name: "timezone") {
///     OptionGroup(label: "Americas") {
///         Option(value: "America/New_York")    { "Eastern Time" }
///         Option(value: "America/Chicago")     { "Central Time" }
///         Option(value: "America/Los_Angeles") { "Pacific Time" }
///     }
///     OptionGroup(label: "Europe") {
///         Option(value: "Europe/London") { "London" }
///         Option(value: "Europe/Paris")  { "Paris" }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <optgroup label="Americas"><option value="…">…</option>…</optgroup>
/// ```
///
/// - SeeAlso: ``Option``, ``Input``
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
