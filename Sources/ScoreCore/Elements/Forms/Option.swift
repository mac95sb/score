/// A selectable choice inside an `Input(type: .select)` dropdown (`<option>`).
///
/// Each `Option` represents one item in a `<select>` element. The `value`
/// string is what the browser sends in the form submission; the child content
/// is the visible label. Mark the pre-selected item with `selected: true`.
/// Use ``OptionGroup`` to cluster related options under a labelled header.
///
/// - Parameters:
///   - value: The value submitted with the form when this option is selected.
///   - selected: Whether this option is selected by default. Defaults to `false`.
///   - disabled: Whether this option is unselectable. Defaults to `false`.
///   - content: The visible label for the option.
///
/// ## Example
///
/// ```swift
/// Input(type: .select, name: "plan") {
///     Option(value: "free", selected: true) { "Free" }
///     Option(value: "pro")                  { "Pro — $9/mo" }
///     Option(value: "team")                 { "Team — $29/mo" }
///     Option(value: "enterprise", disabled: true) { "Enterprise (contact us)" }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <option value="pro">Pro — $9/mo</option>
/// ```
///
/// - SeeAlso: ``OptionGroup``, ``Input``
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
