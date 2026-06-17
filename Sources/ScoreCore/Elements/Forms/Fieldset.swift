/// A group of related form controls with an optional caption (`<fieldset>`).
///
/// Use `Fieldset` to cluster semantically related inputs — for example, a
/// shipping address block or a set of payment fields. Browsers draw a border
/// around the group by default and expose it as a named group to assistive
/// technologies. Always pair `Fieldset` with a ``Legend`` as its first child
/// to give the group an accessible name.
///
/// Setting `disabled: true` disables every descendant form control at once,
/// which is convenient for locking a section of a multi-step form.
///
/// - Parameters:
///   - disabled: When `true`, all descendant controls are disabled. Defaults to `false`.
///   - content: The child form controls, typically starting with a ``Legend``.
///
/// ## Example
///
/// ```swift
/// Form(action: "/checkout", method: .post) {
///     Fieldset {
///         Legend { "Shipping address" }
///         Label(for: "street") { "Street" }
///         Input(type: .text, name: "street", placeholder: "123 Main St", required: true)
///         Label(for: "city") { "City" }
///         Input(type: .text, name: "city", placeholder: "Springfield", required: true)
///     }
///     Fieldset(disabled: true) {
///         Legend { "Payment (coming soon)" }
///         Input(type: .text, name: "card", placeholder: "Card number")
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <fieldset><legend>…</legend>…</fieldset>
/// ```
///
/// - SeeAlso: ``Legend``, ``Form``, ``Input``, ``Label``
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
