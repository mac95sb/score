/// Text marked as relevant or highlighted in the current context (`<mark>`).
///
/// Use `Highlight` to draw attention to text that is particularly relevant to
/// the reader's current task — for example, search result matches, a key term
/// referenced in a surrounding passage, or content the user has selected.
/// Browsers render `<mark>` with a yellow background by default; your theme
/// can override this via CSS.
///
/// Unlike `<strong>` (importance) or `<em>` (stress emphasis), `<mark>`
/// conveys relevance without implying editorial importance. Screen readers
/// may or may not announce it depending on user settings.
///
/// - Parameters:
///   - content: The child views whose text should be highlighted.
///
/// ## Example
///
/// ```swift
/// Text {
///     "Results for "
///     Highlight { searchQuery }
///     ":"
/// }
///
/// // Highlight a term in a search result snippet
/// Text { "The framework uses " ; Highlight { "reactive state" } ; " to update the DOM." }
/// ```
///
/// ## HTML output
///
/// ```html
/// <mark>reactive state</mark>
/// ```
///
/// - SeeAlso: ``Text``, ``Badge``, ``Abbreviation``
public struct Highlight: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<mark>\(content.renderHTML(context: &context))</mark>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
