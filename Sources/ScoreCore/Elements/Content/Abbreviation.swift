/// An inline abbreviation with an expanded title (`<abbr>`).
///
/// Use `Abbreviation` whenever you introduce an acronym or abbreviation for
/// the first time on a page. Browsers render a dotted underline by default and
/// expose the `title` as a tooltip. Screen readers may announce the full
/// expansion depending on user settings, improving comprehension without
/// cluttering the visible text.
///
/// - Parameters:
///   - text: The abbreviated form shown in the document (e.g. `"HTML"`).
///   - title: The full expansion shown as a tooltip (e.g. `"HyperText Markup Language"`).
///
/// ## Example
///
/// ```swift
/// Text {
///     "Built with "
///     Abbreviation("SSG", title: "Static Site Generation")
///     " for maximum performance."
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <abbr title="Static Site Generation">SSG</abbr>
/// ```
///
/// - SeeAlso: ``Text``, ``RichText``
public struct Abbreviation: View, _HTMLRenderable {
    let text: String
    let title: String

    public init(_ text: String, title: String) {
        self.text = text
        self.title = title
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<abbr title=\"\(attributeEscape(title))\">\(htmlEscape(text))</abbr>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
