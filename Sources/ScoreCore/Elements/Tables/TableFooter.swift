/// The summary or totals section at the bottom of a ``Table`` (`<tfoot>`).
///
/// Use `TableFooter` to hold summary, aggregate, or repeated header rows at
/// the bottom of a ``Table`` — for example, column totals in a financial
/// report or pagination metadata. Browsers render `<tfoot>` after `<tbody>`
/// in the visual flow regardless of source order, and some CSS table
/// implementations pin it to the bottom when the body scrolls. Wrap cells in
/// ``TableRow`` as you would for ``TableBody``.
///
/// - Parameters:
///   - content: ``TableRow`` child elements forming the footer rows.
///
/// ## Example
///
/// ```swift
/// TableFooter {
///     TableRow {
///         TableCell(.header) { "Total" }
///         TableCell { "$131,900" }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <tfoot><tr>…</tr></tfoot>
/// ```
///
/// - SeeAlso: ``Table``, ``TableHeader``, ``TableBody``, ``TableRow``
public struct TableFooter: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<tfoot>\(content.renderHTML(context: &context))</tfoot>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
