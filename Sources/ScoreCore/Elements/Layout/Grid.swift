/// A CSS grid container (`<div>` with `display: grid`).
///
/// Use `Grid` to create multi-column or multi-row layouts where children are
/// automatically placed into tracks. Pass `columns:` for an equal-width
/// column count; combine with `.flex(gap:)` to set gutters. For more complex
/// track definitions (mixed sizes, named areas, auto-fit), apply
/// `.grid(columns:)` and `.grid(rows:)` modifiers directly to a ``Stack``.
///
/// - Parameters:
///   - columns: The number of equal-width columns. Omit to apply column
///     sizing via modifiers instead.
///   - content: The child views placed into grid cells.
///
/// ## Example
///
/// ```swift
/// // A responsive 3-column card grid
/// Grid(columns: 3) {
///     for post in posts {
///         ArticleCard(post: post)
///     }
/// }
/// .flex(gap: 6)
///
/// // Auto-fit columns with a minimum width
/// Stack {
///     for item in items { ItemCard(item: item) }
/// }
/// .grid(columns: "repeat(auto-fit, minmax(240px, 1fr))")
/// .flex(gap: 4)
/// ```
///
/// ## HTML output
///
/// ```html
/// <div style="display:grid;grid-template-columns:repeat(3,minmax(0,1fr));…">…</div>
/// ```
///
/// - SeeAlso: ``Stack``, ``HStack``, ``VStack``
public struct Grid: View, _HTMLRenderable {
    let columns: Int?
    let content: AnyView

    public init(columns: Int? = nil, @ViewBuilder content: () -> some View) {
        self.columns = columns
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var style = "display:grid"
        if let columns = columns {
            style += ";grid-template-columns:repeat(\(columns),minmax(0,1fr))"
        }
        if !extra.isEmpty { style += ";\(extra)" }
        var gridAttrs = " style=\"\(style)\""
        if let cls { gridAttrs += " class=\"\(cls)\"" }
        let result = "<div\(gridAttrs)>\(content.renderHTML(context: &context))</div>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
