/// A text element that automatically renders as `<p>` (block paragraph) or
/// `<span>` (inline run) based on grammatical context.
///
/// The tag is inferred from the rendered content: if the inner HTML contains
/// only inline-level nodes (no `<p>`, `<div>`, `<h1>`–`<h6>`, `<ul>`, `<ol>`,
/// `<table>`, `<blockquote>`, `<pre>`, `<figure>`, `<section>`, `<article>`,
/// `<header>`, `<footer>`, `<nav>`, `<main>`, `<aside>`) the tag is `<span>`;
/// otherwise `<p>`.  Pass `inline: true` or `inline: false` to override.
///
/// ```swift
/// VStack {
///     "Some bare text"               // → escaped text node (no wrapper)
///     Text { "A paragraph." }        // → <p>  (block content inferred)
///     Text { "Runs " ; Code("inline") ; " here." }  // → <span> (inline-only)
///     Text(inline: true) { "Force span." }           // → <span> (override)
/// }
/// ```
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
        let inner = content.renderHTML(context: &context)
        let tag: String
        if let override = inline {
            tag = override ? "span" : "p"
        } else {
            tag = Self.isInlineContent(inner) ? "span" : "p"
        }
        return "<\(tag)>\(inner)</\(tag)>"
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
        for tag in blockTags {
            if html.range(of: "<\(tag)[> ]", options: [.regularExpression, .caseInsensitive]) != nil {
                return false
            }
        }
        return true
    }
}
