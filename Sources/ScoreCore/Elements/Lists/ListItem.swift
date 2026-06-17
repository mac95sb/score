/// A single item inside a ``List`` (`<li>`).
///
/// `ListItem` is the only valid direct child of ``List``. Its content can be
/// plain text, inline elements (``Link``, ``Code``, ``Badge``), or even nested
/// ``List`` elements for multi-level lists. Browsers apply a bullet or number
/// marker automatically based on the parent `<ul>` or `<ol>` element.
///
/// - Parameters:
///   - content: The child views that form the item's content.
///
/// ## Example
///
/// ```swift
/// List {
///     ListItem { "Plain text item" }
///     ListItem {
///         Link(to: "/docs") { "Documentation" }
///         Text { " — guides and API reference." }
///     }
///     ListItem {
///         "Sub-list example"
///         List {
///             ListItem { "Nested item one" }
///             ListItem { "Nested item two" }
///         }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <li>Plain text item</li>
/// ```
///
/// - SeeAlso: ``List``, ``ListStyle``
public struct ListItem: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<li>\(content.renderHTML(context: &context))</li>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
