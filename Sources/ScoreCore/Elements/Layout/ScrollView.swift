/// The scroll axis of a ``ScrollView``.
public enum ScrollAxis: Sendable {
    /// Scroll on both axes (default).
    case x
    /// Scroll vertically only.
    case y
    /// Scroll horizontally only.
    case both
}

/// A scrollable container (`<div>` with `overflow: auto`).
///
/// Wraps content in a div that scrolls when its children overflow the
/// available space. Use `axis` to restrict scrolling to one direction —
/// this is particularly useful for horizontally scrollable tables, code
/// blocks, or image carousels.
///
/// The container must have a constrained dimension (via `.frame(height:)` or
/// similar) for scrolling to engage. Without a fixed height or width, the div
/// expands to fit its content and no scroll bar appears.
///
/// - Parameters:
///   - axis: Which axes to allow scrolling on. Defaults to ``ScrollAxis/both``.
///   - content: The child views that may overflow and scroll.
///
/// ## Example
///
/// ```swift
/// // Vertical scroll with a fixed height
/// ScrollView(axis: .y) {
///     for item in longList {
///         ListRow(item: item)
///     }
/// }
/// .frame(height: .px(400))
///
/// // Horizontal scroll for a wide table
/// ScrollView(axis: .x) {
///     DataTable(rows: rows)
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <!-- axis: .both -->
/// <div style="overflow:auto;…">…</div>
///
/// <!-- axis: .y -->
/// <div style="overflow-y:auto;…">…</div>
///
/// <!-- axis: .x -->
/// <div style="overflow-x:auto;…">…</div>
/// ```
///
/// - SeeAlso: ``Stack``, ``VStack``
public struct ScrollView: View, _HTMLRenderable {
    let axis: ScrollAxis
    let content: AnyView

    public init(axis: ScrollAxis = .both, @ViewBuilder content: () -> some View) {
        self.axis = axis
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        let base: String
        switch axis {
        case .y:    base = "overflow-y:auto"
        case .x:    base = "overflow-x:auto"
        case .both: base = "overflow:auto"
        }
        let style = extra.isEmpty ? base : "\(base);\(extra)"
        var svAttrs = " style=\"\(style)\""
        if let cls { svAttrs += " class=\"\(cls)\"" }
        let result = "<div\(svAttrs)>\(content.renderHTML(context: &context))</div>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
