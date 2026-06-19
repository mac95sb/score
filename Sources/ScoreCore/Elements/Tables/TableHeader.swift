/// The column-heading section at the top of a ``Table`` (`<thead>`).
///
/// `TableHeader` wraps ``TableRow`` elements that contain column label cells.
/// Use `TableCell(.header)` (`<th>`) for the cells inside so that screen
/// readers can associate each data cell with its column name — essential for
/// accessible data tables. Browsers may also render `<thead>` with a distinct
/// background or bold text by default.
///
/// When a table has many rows and is displayed inside a scrollable container,
/// CSS can pin `<thead>` at the top while `<tbody>` scrolls beneath it.
///
/// - Parameters:
///   - content: ``TableRow`` child elements containing `TableCell(.header)` cells.
///
/// ## Example
///
/// ```swift
/// TableHeader {
///     TableRow {
///         TableCell(.header) { "Date" }
///         TableCell(.header) { "Description" }
///         TableCell(.header) { "Amount" }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <thead><tr><th>Date</th><th>Description</th><th>Amount</th></tr></thead>
/// ```
///
/// - SeeAlso: ``Table``, ``TableBody``, ``TableFooter``, ``TableRow``, ``TableCell``
public struct TableHeader: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<thead>\(content.renderHTML(context: &context))</thead>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
