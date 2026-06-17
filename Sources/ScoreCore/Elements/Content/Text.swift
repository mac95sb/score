/// A text container that renders as `<p>` or `<span>` based on its content.
///
/// `Text` is the primary way to output styled prose in Score. The wrapper tag
/// is chosen automatically: if the inner HTML contains only inline-level nodes
/// (no block tags like `<p>`, `<div>`, `<h1>`–`<h6>`, `<ul>`, `<ol>`,
/// `<table>`, `<blockquote>`, `<pre>`, or semantic sectioning elements) the
/// element renders as `<span>`; otherwise it renders as `<p>`. Pass
/// `inline: true` or `inline: false` to override the automatic inference.
///
/// For multi-paragraph or fully authored content, use ``RichText`` with a
/// Markdown string instead.
///
/// - Parameters:
///   - inline: Override the automatic block/inline inference. `true` forces
///     `<span>`, `false` forces `<p>`, `nil` (default) auto-detects.
///   - content: The child views that make up the text content.
///
/// ## Example
///
/// ```swift
/// VStack {
///     "Bare string — no wrapper tag"
///
///     Text { "A standalone paragraph." }            // → <p>
///
///     Text { "Visit " ; Link(to: "/docs") { "the docs" } ; "." }  // → <span>
///
///     Text(inline: true) { "Forced span regardless of children." } // → <span>
/// }
/// .font(size: .base)
/// .font(color: .primary)
/// ```
///
/// ## HTML output
///
/// ```html
/// <p>A standalone paragraph.</p>
/// <span>Visit <a href="/docs">the docs</a>.</span>
/// ```
///
/// - SeeAlso: ``RichText``, ``Heading``, ``Blockquote``
public struct Text: View, _HTMLRenderable {
    let content: AnyView
    let inline: Bool?

    public init(inline: Bool? = nil, @ViewBuilder content: () -> some View) {
        self.inline = inline
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = extra.isEmpty ? "" : " style=\"\(extra)\""
        if let cls { attrs += " class=\"\(cls)\"" }
        let inner = content.renderHTML(context: &context)
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        let tag: String
        if let override = inline {
            tag = override ? "span" : "p"
        } else {
            tag = Self.isInlineContent(inner) ? "span" : "p"
        }
        return "<\(tag)\(attrs)>\(inner)</\(tag)>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }

    // Returns true when `html` contains only inline-level content — i.e. no
    // opening tag for a known block element.
    private static let blockTags: [String] = [
        "p", "div", "h1", "h2", "h3", "h4", "h5", "h6",
        "ul", "ol", "li", "dl", "dt", "dd",
        "table", "thead", "tbody", "tfoot", "tr", "th", "td",
        "blockquote", "pre", "figure", "figcaption",
        "section", "article", "header", "footer", "nav", "main", "aside",
        "details", "summary", "form", "fieldset",
    ]

    private static func isInlineContent(_ html: String) -> Bool {
        // Pure text (no HTML tags) → treat as a standalone paragraph, not inline.
        guard html.contains("<") else { return false }
        // Any block tag → block.
        for tag in blockTags {
            if html.range(of: "<\(tag)[> ]", options: [.regularExpression, .caseInsensitive]) != nil {
                return false
            }
        }
        // Has tags, none are block (e.g. <a>, <code>, <em>) → inline.
        return true
    }
}
