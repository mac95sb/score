/// A list of term–description pairs for glossaries, metadata, and key–value displays (`<dl>`).
///
/// Use `DescriptionList` for structured key–value content: glossary entries,
/// product metadata (size, colour, weight), API response field descriptions,
/// or any list where each item has a distinct name and one or more values.
/// Nest ``Term`` (`<dt>`) and ``Description`` (`<dd>`) children in order.
/// A single ``Term`` may be followed by multiple ``Description`` elements.
///
/// Browsers provide minimal default styling (`<dt>` is bold, `<dd>` is
/// indented); apply grid or flex modifiers to produce side-by-side layouts.
///
/// - Parameters:
///   - content: ``Term`` and ``Description`` child elements in term–description order.
///
/// ## Example
///
/// ```swift
/// DescriptionList {
///     Term { "Author" }
///     Description { "Jane Smith" }
///
///     Term { "Published" }
///     Description { TimeElement(post.publishedAt) }
///
///     Term { "Tags" }
///     for tag in post.tags {
///         Description { tag }
///     }
/// }
/// .grid(columns: 2, gap: 2)
/// ```
///
/// ## HTML output
///
/// ```html
/// <dl><dt>Author</dt><dd>Jane Smith</dd>…</dl>
/// ```
///
/// - SeeAlso: ``Term``, ``Description``, ``List``
public struct DescriptionList: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<dl>\(content.renderHTML(context: &context))</dl>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
