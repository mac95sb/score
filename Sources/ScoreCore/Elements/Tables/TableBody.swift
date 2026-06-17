/// The primary data section of a ``Table`` containing one or more ``TableRow`` elements (`<tbody>`).
///
/// `TableBody` wraps the main data rows of a table, distinct from the column
/// headings in ``TableHeader`` and summary rows in ``TableFooter``. Browsers
/// and assistive technologies treat `<tbody>` as the canonical data region
/// and allow it to scroll independently of a fixed header in CSS table
/// implementations. A `<table>` may contain multiple `<tbody>` elements to
/// group related rows with visual separators.
///
/// - Parameters:
///   - content: ``TableRow`` child elements.
///
/// ## Example
///
/// ```swift
/// Table {
///     TableHeader {
///         TableRow {
///             TableCell(.header) { "Name" }
///             TableCell(.header) { "Role" }
///         }
///     }
///     TableBody {
///         TableRow {
///             TableCell { "Alice" }
///             TableCell { "Engineer" }
///         }
///         TableRow {
///             TableCell { "Bob" }
///             TableCell { "Designer" }
///         }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <tbody><tr>…</tr></tbody>
/// ```
///
/// - SeeAlso: ``Table``, ``TableHeader``, ``TableFooter``, ``TableRow``
public struct TableBody: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<tbody>\(content.renderHTML(context: &context))</tbody>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
