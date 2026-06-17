/// A horizontal row of cells inside a table section (`<tr>`).
///
/// Place ``TableCell`` elements as children. `TableRow` can appear inside
/// ``TableHeader``, ``TableBody``, or ``TableFooter`` — the parent section
/// determines the semantic role of the row. Use `TableCell(.header)` for cells
/// inside a ``TableHeader`` row, and `TableCell(.data)` (or just `TableCell`)
/// for data rows inside ``TableBody`` and ``TableFooter``.
///
/// - Parameters:
///   - content: ``TableCell`` child elements forming the cells of this row.
///
/// ## Example
///
/// ```swift
/// TableBody {
///     for item in invoice.lineItems {
///         TableRow {
///             TableCell { item.description }
///             TableCell { item.quantity.description }
///             TableCell { NumberElement(item.total, format: .currency(code: "USD")) }
///         }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <tr><td>…</td><td>…</td></tr>
/// ```
///
/// - SeeAlso: ``TableCell``, ``TableBody``, ``TableHeader``, ``TableFooter``
public struct TableRow: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<tr>\(content.renderHTML(context: &context))</tr>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
