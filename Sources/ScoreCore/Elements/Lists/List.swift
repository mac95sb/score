/// A bullet or numbered list of ``ListItem`` elements (`<ul>` or `<ol>`).
///
/// Use `List` to present a collection of items where order either matters
/// (steps, rankings — use `.ordered` or `.decimal`) or does not (features,
/// links — use `.unordered`). The ``ListStyle`` controls which HTML element
/// and optional `type` attribute are emitted. Use `.none` when you want the
/// semantic list structure without visible bullets or numbers, and suppress
/// the default indentation with a padding modifier.
///
/// Place ``ListItem`` elements as children. For key–value pairs, use
/// ``DescriptionList`` instead.
///
/// - Parameters:
///   - style: The list variant. Defaults to `.unordered` (`<ul>`).
///   - content: ``ListItem`` child views.
///
/// ## Example
///
/// ```swift
/// // Feature list
/// List {
///     ListItem { "Static site generation" }
///     ListItem { "Reactive state" }
///     ListItem { "Full SwiftUI-style modifier API" }
/// }
///
/// // Step-by-step instructions
/// List(.ordered) {
///     ListItem { "Install Score via Swift Package Manager." }
///     ListItem { "Run " ; Code { "score dev" } ; " to start the server." }
///     ListItem { "Open http://localhost:8080 in your browser." }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <ul><li>…</li></ul>
/// <ol><li>…</li></ol>
/// ```
///
/// - SeeAlso: ``ListItem``, ``ListStyle``, ``DescriptionList``
public struct List: View, _HTMLRenderable {
    let style: ListStyle
    let content: AnyView

    public init(_ style: ListStyle = .unordered, @ViewBuilder content: () -> some View) {
        self.style = style
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        switch style {
        case .ordered, .decimal:
            return "<ol>\(content.renderHTML(context: &context))</ol>"
        case .alpha:
            return "<ol type=\"a\">\(content.renderHTML(context: &context))</ol>"
        case .unordered, .none:
            return "<ul>\(content.renderHTML(context: &context))</ul>"
        }
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
