/// A native browser disclosure widget that shows or hides content on demand (`<details>`).
///
/// Use `Details` for FAQ sections, inline help, spoilers, or any pattern where
/// a heading should be visible and the body hidden until the user interacts.
/// The browser handles toggle behaviour natively — no JavaScript required.
/// Always place a ``Summary`` element as the first child; it becomes the
/// clickable heading (the visible trigger). Content after ``Summary`` is the
/// collapsible body.
///
/// When multiple `Details` elements share the same `group` string, the browser
/// enforces exclusive-open (accordion) behaviour — opening one collapses the
/// others. This maps directly to the HTML `name` attribute on `<details>`.
///
/// - Parameters:
///   - isOpen: When `true`, the widget renders pre-expanded with the `open` attribute. Defaults to `false`.
///   - group: An optional group name for exclusive-open (accordion) behaviour. Maps to `name` attribute.
///   - content: Child views, starting with a ``Summary`` followed by the collapsible content.
///
/// ## Example
///
/// ```swift
/// // Simple disclosure
/// Details {
///     Summary { "What is Score?" }
///     Text { "Score is a Swift framework for building fast, type-safe websites." }
/// }
///
/// // FAQ accordion — only one item open at a time
/// let faqs: [(String, String)] = [
///     ("Is Score free?",     "Yes, Score is MIT-licensed open source."),
///     ("Does it need Node?", "No, Score is pure Swift with no JS build step."),
/// ]
/// for faq in faqs {
///     Details(group: "faq") {
///         Summary { faq.0 }
///         Text { faq.1 }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <details><summary>What is Score?</summary><p>…</p></details>
/// <details name="faq"><summary>Is Score free?</summary><p>…</p></details>
/// ```
///
/// - SeeAlso: ``Summary``, ``Section``, ``Aside``
public struct Details: View, _HTMLRenderable {
    let isOpen: Bool
    let group: String?
    let content: AnyView

    public init(isOpen: Bool = false, group: String? = nil, @ViewBuilder content: () -> some View) {
        self.isOpen = isOpen
        self.group = group
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = ""
        if isOpen { attrs += " open" }
        if let group = group { attrs += " name=\"\(attributeEscape(group))\"" }
        return "<details\(attrs)>\(content.renderHTML(context: &context))</details>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
