import Foundation
import Markdown

// MARK: - MarkdownRenderer

/// Renders a Markdown string into a Score `View` tree.
///
/// Uses `swift-markdown` (Apple) to parse the Markdown AST and maps each node
/// to the corresponding Score element.  A `ContentTheme` controls the visual
/// styling of headings, paragraphs, blockquotes, lists, and so on.
///
/// ```swift
/// let renderer = MarkdownRenderer(theme: .blog)
/// let view = renderer.render(post.content)
/// ```
public struct MarkdownRenderer {
    public let theme: ContentTheme

    public init(theme: ContentTheme = .default) {
        self.theme = theme
    }

    // MARK: - Public API

    /// Render a Markdown string to a Score `View`.
    public func render(_ markdown: String) -> AnyView {
        let document = Document(parsing: markdown)
        let blockViews = document.children.map { renderBlock($0) }
        return AnyView(Stack { ForEach(blockViews) { $0 } })
    }

    /// Render a `ContentPost`'s body to a Score `View`.
    public func render(_ post: ContentPost) -> AnyView {
        render(post.content)
    }

    // MARK: - Block-level nodes

    private func renderBlock(_ markup: any Markup) -> AnyView {
        switch markup {
        case let heading as Markdown.Heading:
            return renderHeading(heading)
        case let paragraph as Markdown.Paragraph:
            return renderParagraph(paragraph)
        case let blockquote as Markdown.BlockQuote:
            return renderBlockquote(blockquote)
        case let codeBlock as Markdown.CodeBlock:
            return renderCodeBlock(codeBlock)
        case let list as Markdown.UnorderedList:
            return renderUnorderedList(list)
        case let list as Markdown.OrderedList:
            return renderOrderedList(list)
        case is Markdown.ThematicBreak:
            return AnyView(theme.divider(AnyView(Divider())))
        case let table as Markdown.Table:
            return renderTable(table)
        default:
            let inlines = markup.children.map { renderInline($0) }
            return AnyView(Stack { ForEach(inlines) { $0 } })
        }
    }

    // MARK: - Headings

    private func renderHeading(_ heading: Markdown.Heading) -> AnyView {
        let level = min(max(heading.level, 1), 6)
        let text = heading.plainText
        let inner = AnyView(ScoreCore.Heading(level) { text })
        return AnyView(theme.heading(level, inner))
    }

    // MARK: - Paragraphs

    private func renderParagraph(_ paragraph: Markdown.Paragraph) -> AnyView {
        let inlines = paragraph.children.map { renderInline($0) }
        let inner = AnyView(Stack { ForEach(inlines) { $0 } })
        return AnyView(theme.paragraph(inner))
    }

    // MARK: - Blockquotes

    private func renderBlockquote(_ blockquote: Markdown.BlockQuote) -> AnyView {
        let children = blockquote.children.map { renderBlock($0) }
        let inner = AnyView(Stack { ForEach(children) { $0 } })
        return AnyView(theme.blockquote(inner))
    }

    // MARK: - Code blocks

    private func renderCodeBlock(_ codeBlock: Markdown.CodeBlock) -> AnyView {
        let lang = codeBlock.language.flatMap { CodeLanguage(rawValue: $0) }
        let inner = AnyView(ScoreCore.CodeBlock(language: lang, syntaxTheme: nil, codeBlock.code))
        return AnyView(theme.codeBlock(codeBlock.language, inner))
    }

    // MARK: - Lists

    private func renderUnorderedList(_ list: Markdown.UnorderedList) -> AnyView {
        let items = Array(list.listItems).map { renderListItem($0) }
        let inner = AnyView(ScoreCore.List(.unordered) { ForEach(items) { $0 } })
        return AnyView(theme.list(.unordered, inner))
    }

    private func renderOrderedList(_ list: Markdown.OrderedList) -> AnyView {
        let items = Array(list.listItems).map { renderListItem($0) }
        let inner = AnyView(ScoreCore.List(.ordered) { ForEach(items) { $0 } })
        return AnyView(theme.list(.ordered, inner))
    }

    private func renderListItem(_ item: Markdown.ListItem) -> AnyView {
        let children = item.children.map { renderBlock($0) }
        let inner = Stack { ForEach(children) { $0 } }
        return AnyView(theme.listItem(AnyView(ScoreCore.ListItem { inner })))
    }

    // MARK: - Tables

    private func renderTable(_ table: Markdown.Table) -> AnyView {
        // swift-markdown: table.head.children = cells; table.body.children = rows
        let headerCells = Array(table.head.cells).map { cell -> AnyView in
            let inlines = cell.children.map { renderInline($0) }
            let inner = AnyView(Stack { ForEach(inlines) { $0 } })
            return AnyView(ScoreCore.TableCell(.header) { inner })
        }
        let bodyRows = Array(table.body.rows).map { row -> AnyView in
            let cells = Array(row.cells).map { cell -> AnyView in
                let inlines = cell.children.map { renderInline($0) }
                let inner = AnyView(Stack { ForEach(inlines) { $0 } })
                return AnyView(ScoreCore.TableCell { inner })
            }
            return AnyView(ScoreCore.TableRow { ForEach(cells) { $0 } })
        }
        let scoreTable = ScoreCore.Table {
            ScoreCore.TableHeader {
                ScoreCore.TableRow { ForEach(headerCells) { $0 } }
            }
            ScoreCore.TableBody { ForEach(bodyRows) { $0 } }
        }
        return AnyView(theme.table(AnyView(scoreTable)))
    }

    // MARK: - Inline nodes

    private func renderInline(_ markup: any Markup) -> AnyView {
        switch markup {
        case let text as Markdown.Text:
            return AnyView(ScoreCore.Text { text.string })
        case let strong as Markdown.Strong:
            let inners = strong.children.map { renderInline($0) }
            let inner = AnyView(Stack { ForEach(inners) { $0 } })
            return AnyView(theme.strong(inner))
        case let emphasis as Markdown.Emphasis:
            let inners = emphasis.children.map { renderInline($0) }
            let inner = AnyView(Stack { ForEach(inners) { $0 } })
            return AnyView(theme.emphasis(inner))
        case let strike as Markdown.Strikethrough:
            let inners = strike.children.map { renderInline($0) }
            let inner = AnyView(Stack { ForEach(inners) { $0 } })
            return AnyView(theme.strikethrough(inner))
        case let code as Markdown.InlineCode:
            let codeStr = code.code
            return AnyView(theme.code(AnyView(ScoreCore.Code { codeStr })))
        case let link as Markdown.Link:
            let dest = link.destination ?? "#"
            // Reject unsafe schemes that RichText already blocks — AST rendering
            // must apply the same safety invariant.
            let safeDest = isSafeURL(dest) ? dest : "#"
            let inners = link.children.map { renderInline($0) }
            let inner = AnyView(Stack { ForEach(inners) { $0 } })
            return AnyView(theme.link(AnyView(ScoreCore.Link(to: safeDest) { inner })))
        case let image as Markdown.Image:
            let src = image.source ?? ""
            let alt = image.plainText
            return AnyView(theme.image(AnyView(ScoreCore.Image(src, alt: alt))))
        case is Markdown.SoftBreak:
            return AnyView(ScoreCore.Text(inline: true) { " " })
        case is Markdown.LineBreak:
            return AnyView(ScoreCore.Text(inline: true) { "\n" })
        default:
            return AnyView(ScoreCore.Text(inline: true) { markup.format() })
        }
    }

    // MARK: - URL safety

    /// Returns `false` for schemes that must not appear in rendered links
    /// (`javascript:`, `data:`, `vbscript:`, etc.). Mirrors the same check in
    /// `RichText` so every rendering path enforces the same invariant.
    private func isSafeURL(_ url: String) -> Bool {
        let lower = url.lowercased().trimmingCharacters(in: .whitespaces)
        let blockedSchemes = ["javascript:", "data:", "vbscript:", "blob:"]
        return !blockedSchemes.contains(where: { lower.hasPrefix($0) })
    }
}
