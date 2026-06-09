/// The role of a `TableCell` — data cell or header cell.
public enum CellRole: Sendable {
    /// A standard data cell (`<td>`).
    case data
    /// A header cell (`<th>`).
    case header
}

/// A table cell element — either `<td>` or `<th>` depending on `role`.
///
/// ```swift
/// TableRow {
///     TableCell(.header) { "Name" }
///     TableCell(.header) { "Score" }
/// }
/// TableRow {
///     TableCell { "Alice" }
///     TableCell { "98" }
/// }
/// // With colspan:
/// TableRow {
///     TableCell(span: 2) { "Spans two columns" }
/// }
/// ```
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
