/// The visible caption that provides an accessible name for a ``Fieldset`` (`<legend>`).
///
/// `Legend` must be the first child of a ``Fieldset``. Browsers render it as
/// an inline heading overlaying the fieldset border, and assistive technologies
/// prepend it to the name of every control inside the group — so a screen
/// reader may announce "Shipping address: Street, text field" for an input
/// inside a fieldset whose legend is "Shipping address".
///
/// - Parameters:
///   - content: The caption text or child views for the legend.
///
/// ## Example
///
/// ```swift
/// Fieldset {
///     Legend { "Payment details" }
///     Label(for: "card") { "Card number" }
///     Input(type: .text, name: "card", placeholder: "•••• •••• •••• ••••")
///     Label(for: "expiry") { "Expiry" }
///     Input(type: .month, name: "expiry")
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <legend>Payment details</legend>
/// ```
///
/// - SeeAlso: ``Fieldset``, ``Label``, ``Input``
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
