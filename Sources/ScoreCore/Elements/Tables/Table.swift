/// A semantic data table with optional caption (`<table>`).
///
/// Use `Table` only for genuinely tabular data — information that has a
/// meaningful two-dimensional relationship between rows and columns. Do not
/// use tables for page layout; use ``Grid``, ``HStack``, or ``VStack`` instead.
///
/// Structure a table with ``TableHeader`` (`<thead>`) for column headings,
/// ``TableBody`` (`<tbody>`) for data rows, and optionally ``TableFooter``
/// (`<tfoot>`) for summary rows. Within each section, add ``TableRow`` elements
/// containing ``TableCell`` items. Use `TableCell(.header)` for `<th>` cells
/// inside ``TableHeader``, which assistive technologies read as column labels
/// for every cell in that column.
///
/// Provide a `caption` to give the table an accessible title — screen readers
/// announce it before the table content, providing context without requiring
/// the user to read the first row.
///
/// - Parameters:
///   - caption: An optional title rendered as `<caption>` above the table. Recommended for accessibility.
///   - content: ``TableHeader``, ``TableBody``, and ``TableFooter`` child sections.
///
/// ## Example
///
/// ```swift
/// Table(caption: "Q1 Revenue by Region") {
///     TableHeader {
///         TableRow {
///             TableCell(.header) { "Region" }
///             TableCell(.header) { "January" }
///             TableCell(.header) { "February" }
///             TableCell(.header) { "March" }
///         }
///     }
///     TableBody {
///         TableRow {
///             TableCell { "North America" }
///             TableCell { "$42,000" }
///             TableCell { "$38,500" }
///             TableCell { "$51,200" }
///         }
///         TableRow {
///             TableCell { "Europe" }
///             TableCell { "$31,000" }
///             TableCell { "$29,800" }
///             TableCell { "$36,400" }
///         }
///     }
///     TableFooter {
///         TableRow {
///             TableCell { "Total" }
///             TableCell(span: 3) { "$228,900" }
///         }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <table><caption>…</caption><thead>…</thead><tbody>…</tbody><tfoot>…</tfoot></table>
/// ```
///
/// - SeeAlso: ``TableHeader``, ``TableBody``, ``TableFooter``, ``TableRow``, ``TableCell``
public struct Table: View, _HTMLRenderable {
    let caption: String?
    let content: AnyView

    public init(caption: String? = nil, @ViewBuilder content: () -> some View) {
        self.caption = caption
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var inner = ""
        if let caption = caption {
            inner += "<caption>\(htmlEscape(caption))</caption>"
        }
        inner += content.renderHTML(context: &context)
        return "<table>\(inner)</table>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
