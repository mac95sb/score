/// A caption for a form control that provides an accessible name (`<label>`).
///
/// Every interactive form control should have an associated `Label`. When the
/// `for` parameter matches the `id` of an ``Input``, clicking the label focuses
/// the control and screen readers announce the label text when the control
/// gains focus. Omitting `for` still renders the label but loses the programmatic
/// association — only acceptable when the label directly wraps its control.
///
/// - Parameters:
///   - inputId: The `id` of the associated ``Input``. Rendered as `for="…"` on the `<label>`.
///   - content: The label's visible text or child views.
///
/// ## Example
///
/// ```swift
/// VStack(gap: 1) {
///     Label(for: "username") { "Username" }
///     Input(type: .text, name: "username")
///         .attribute("id", "username")
///
///     Label(for: "bio") { "Short bio" }
///     Input(type: .textarea, name: "bio", rows: 3)
///         .attribute("id", "bio")
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <label for="username">Username</label>
/// ```
///
/// - SeeAlso: ``Input``, ``Fieldset``, ``Legend``
public struct Label: View, _HTMLRenderable {
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
        return "<label\(attrs)>\(content.renderHTML(context: &context))</label>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
