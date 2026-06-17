/// A live region that displays the result of a form calculation or user interaction (`<output>`).
///
/// Use `Output` to show the computed result of one or more form controls —
/// for example, a running total updated when the user changes a quantity,
/// the estimated reading time calculated from a textarea's word count, or the
/// result of a tip calculator. The `for` parameter links the output to the
/// `id`s of the controls that feed it, which assistive technologies use to
/// announce updates.
///
/// `Output` has an implicit `aria-live="polite"` role so screen readers
/// announce its content when it changes without interrupting the current focus.
///
/// - Parameters:
///   - inputId: Space-separated `id` values of the controls this output is derived from.
///   - content: The computed result to display.
///
/// ## Example
///
/// ```swift
/// // Tip calculator output
/// HStack(gap: 4) {
///     Label(for: "tip-pct") { "Tip %" }
///     Input(type: .range, name: "tip-pct", min: 0, max: 30)
///         .attribute("id", "tip-pct")
///     Text { "Total:" }
///     Output(for: "tip-pct") { "$0.00" }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <output for="tip-pct">$0.00</output>
/// ```
///
/// - SeeAlso: ``Input``, ``Form``, ``Label``
public struct Output: View, _HTMLRenderable {
    let for_: String?
    let content: AnyView

    public init(for inputId: String? = nil, @ViewBuilder content: () -> some View) {
        self.for_ = inputId
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = ""
        if let f = for_ { attrs = " for=\"\(attributeEscape(f))\"" }
        return "<output\(attrs)>\(content.renderHTML(context: &context))</output>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
