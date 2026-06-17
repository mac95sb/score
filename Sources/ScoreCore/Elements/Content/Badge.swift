/// A small inline label used to highlight status, counts, or categories (`<span class="badge">`).
///
/// Use `Badge` for short, high-visibility labels such as notification counts,
/// status indicators ("New", "Beta", "Draft"), or category tags. The element
/// renders as an inline `<span>` with the `badge` CSS class, which your theme
/// styles to stand out from surrounding text. Keep badge content short — one
/// to three words or a small number.
///
/// - Parameters:
///   - content: The badge's child views, typically a short string or icon.
///
/// ## Example
///
/// ```swift
/// HStack {
///     Text { "Unread messages" }
///     Badge { "12" }
/// }
///
/// NavLink(to: "/blog") {
///     "Blog"
///     Badge { "New" }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <span class="badge">12</span>
/// ```
///
/// - SeeAlso: ``Text``, ``Highlight``, ``NavLink``
public struct Badge: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<span class=\"badge\">\(content.renderHTML(context: &context))</span>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
