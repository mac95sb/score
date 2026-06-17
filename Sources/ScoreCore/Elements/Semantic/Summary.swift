/// The always-visible, interactive heading of a ``Details`` disclosure widget (`<summary>`).
///
/// `Summary` must be the first child of a ``Details`` element. Browsers render
/// it with a disclosure triangle (▶/▼) and make it keyboard-focusable. Clicking
/// or pressing Space/Enter on the `<summary>` toggles the parent `<details>`
/// open or closed. Screen readers announce the element as a button with an
/// expanded/collapsed state.
///
/// The content can be plain text, inline elements (``Heading``, ``Badge``), or
/// a combination — but it should be concise since it acts as the trigger label.
///
/// - Parameters:
///   - content: The child views forming the visible trigger label.
///
/// ## Example
///
/// ```swift
/// Details {
///     Summary { "Advanced options" }
///     VStack(gap: 3) {
///         Input(type: .checkbox, name: "debug", label: "Enable debug mode")
///         Input(type: .checkbox, name: "verbose", label: "Verbose output")
///     }
///     .padding(y: 2)
/// }
///
/// Details {
///     Summary {
///         Heading(3) { "Shipping information" }
///     }
///     Text { "Your order ships within 2 business days." }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <summary>Advanced options</summary>
/// ```
///
/// - SeeAlso: ``Details``
public struct Summary: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<summary>\(content.renderHTML(context: &context))</summary>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
