/// The semantic role of a ``TableCell`` — a data cell (`<td>`) or a header cell (`<th>`).
public enum CellRole: Sendable {
    /// A standard data cell (`<td>`).
    case data
    /// A header cell (`<th>`).
    case header
}

/// A single cell inside a ``TableRow``, rendered as `<td>` or `<th>` based on its role.
///
/// Use `TableCell(.data)` (or just `TableCell { … }` — the default) for data
/// cells inside ``TableBody`` or ``TableFooter`` rows. Use `TableCell(.header)`
/// for column or row headings inside ``TableHeader`` — browsers and screen
/// readers treat `<th>` cells as labels for all cells in the same column or
/// row, which is essential for assistive technology navigation.
///
/// The `span` parameter maps to `colspan`, allowing a single cell to fill
/// multiple columns — useful for footer totals or spanning section headers.
///
/// - Parameters:
///   - role: `.data` (`<td>`) for content cells, `.header` (`<th>`) for heading cells. Defaults to `.data`.
///   - span: The number of columns this cell should span (`colspan`). `nil` omits the attribute.
///   - content: The cell's content.
///
/// ## Example
///
/// ```swift
/// TableHeader {
///     TableRow {
///         TableCell(.header) { "Product" }
///         TableCell(.header) { "Units" }
///         TableCell(.header) { "Revenue" }
///     }
/// }
/// TableBody {
///     TableRow {
///         TableCell { "Widget A" }
///         TableCell { "1,200" }
///         TableCell { "$24,000" }
///     }
/// }
/// TableFooter {
///     TableRow {
///         TableCell { "Total" }
///         TableCell(span: 2) { "$24,000" }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <th>Product</th>
/// <td>Widget A</td>
/// <td colspan="2">$24,000</td>
/// ```
///
/// - SeeAlso: ``TableRow``, ``TableHeader``, ``TableBody``, ``TableFooter``, ``CellRole``
public struct TableCell: View, _HTMLRenderable {
    let role: CellRole
    let span: Int?
    let content: AnyView

    public init(_ role: CellRole = .data, span: Int? = nil, @ViewBuilder content: () -> some View) {
        self.role = role
        self.span = span
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let tag = role == .header ? "th" : "td"
        var attrs = ""
        if let span = span { attrs = " colspan=\"\(span)\"" }
        return "<\(tag)\(attrs)>\(content.renderHTML(context: &context))</\(tag)>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
