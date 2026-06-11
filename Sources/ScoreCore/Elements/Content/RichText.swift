import Foundation

/// Renders markdown content as HTML.
///
/// ```swift
/// RichText(markdown: post.content)
/// RichText(markdown: post.content, theme: .default)
/// ```
public struct RichText: View, _HTMLRenderable {
    let markdown: String
    let theme: ContentTheme?

    public init(markdown: String, theme: ContentTheme? = nil) {
        self.markdown = markdown
        self.theme = theme
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let rendered = MarkdownRenderer.render(markdown)
        return "<div class=\"rich-text\">\(rendered)</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}

// MARK: - MarkdownRenderer

/// Simple markdown-to-HTML renderer covering common cases.
///
/// Full production use should integrate swift-markdown; this handles
/// headings, paragraphs, lists, code blocks, blockquotes, and inline
/// formatting (bold, italic, code, links, strikethrough).
public enum MarkdownRenderer {
    public static func render(_ markdown: String) -> String {
        var html = ""
        let lines = markdown.components(separatedBy: "\n")
        var i = 0

        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                i += 1
                continue
            }

            // Fenced code block
            if trimmed.hasPrefix("```") {
                let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                i += 1
                var code = ""
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    code += htmlEscape(lines[i]) + "\n"
                    i += 1
                }
                let langAttr = lang.isEmpty ? "" : " class=\"language-\(htmlEscape(lang))\""
                html += "<pre><code\(langAttr)>\(code)</code></pre>"
                i += 1
                continue
            }

            // Headings
            if trimmed.hasPrefix("######") {
                html += "<h6>\(inlineMarkdown(String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespaces)))</h6>"
            } else if trimmed.hasPrefix("#####") {
                html += "<h5>\(inlineMarkdown(String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespaces)))</h5>"
            } else if trimmed.hasPrefix("####") {
                html += "<h4>\(inlineMarkdown(String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespaces)))</h4>"
            } else if trimmed.hasPrefix("###") {
                html += "<h3>\(inlineMarkdown(String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)))</h3>"
            } else if trimmed.hasPrefix("##") {
                html += "<h2>\(inlineMarkdown(String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)))</h2>"
            } else if trimmed.hasPrefix("#") {
                html += "<h1>\(inlineMarkdown(String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces)))</h1>"
            }
            // Blockquote
            else if trimmed.hasPrefix(">") {
                html += "<blockquote>\(inlineMarkdown(String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces)))</blockquote>"
            }
            // Horizontal rule
            else if trimmed == "---" || trimmed == "***" || trimmed == "___" {
                html += "<hr>"
            }
            // Unordered list
            else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                html += "<ul>"
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    if t.hasPrefix("- ") || t.hasPrefix("* ") {
                        html += "<li>\(inlineMarkdown(String(t.dropFirst(2))))</li>"
                        i += 1
                    } else {
                        break
                    }
                }
                html += "</ul>"
                continue
            }
            // Ordered list
            else if trimmed.first?.isNumber == true, trimmed.contains(". ") {
                html += "<ol>"
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    if let dot = t.firstIndex(of: "."),
                       t[t.startIndex..<dot].allSatisfy(\.isNumber) {
                        let rest = String(t[t.index(after: dot)...]).trimmingCharacters(in: .whitespaces)
                        html += "<li>\(inlineMarkdown(rest))</li>"
                        i += 1
                    } else {
                        break
                    }
                }
                html += "</ol>"
                continue
            }
            // Paragraph
            else {
                html += "<p>\(inlineMarkdown(trimmed))</p>"
            }

            i += 1
        }

        return html
    }

    // MARK: - Inline markdown

    static func inlineMarkdown(_ text: String) -> String {
        var result = htmlEscape(text)
        // Bold **text**
        result = result.replacingOccurrences(
            of: "\\*\\*(.+?)\\*\\*",
            with: "<strong>$1</strong>",
            options: .regularExpression
        )
        // Italic *text*
        result = result.replacingOccurrences(
            of: "\\*(.+?)\\*",
            with: "<em>$1</em>",
            options: .regularExpression
        )
        // Inline code `text`
        result = result.replacingOccurrences(
            of: "`(.+?)`",
            with: "<code>$1</code>",
            options: .regularExpression
        )
        // Links [text](url) — only safe URL schemes become anchors; anything
        // else (javascript:, data:, …) renders as plain text. This is part of
        // the pre-launch "no customJS/customHTML" guarantee: markdown content
        // cannot smuggle script execution through link URLs.
        result = replaceLinks(in: result)
        // Strikethrough ~~text~~
        result = result.replacingOccurrences(
            of: "~~(.+?)~~",
            with: "<del>$1</del>",
            options: .regularExpression
        )
        return result
    }

    // MARK: - Link safety

    static func replaceLinks(in text: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: #"\[(.+?)\]\((.+?)\)"#) else {
            return text
        }
        let nsText = text as NSString
        var out = ""
        var cursor = 0
        for match in regex.matches(in: text, range: NSRange(location: 0, length: nsText.length)) {
            out += nsText.substring(with: NSRange(location: cursor, length: match.range.location - cursor))
            let label = nsText.substring(with: match.range(at: 1))
            let url = nsText.substring(with: match.range(at: 2))
            if isSafeLinkURL(url) {
                out += "<a href=\"\(url)\">\(label)</a>"
            } else {
                out += label
            }
            cursor = match.range.location + match.range.length
        }
        out += nsText.substring(from: cursor)
        return out
    }

    /// Allow relative URLs, fragments, and the http/https/mailto/tel schemes.
    static func isSafeLinkURL(_ url: String) -> Bool {
        let lower = url.lowercased().trimmingCharacters(in: .whitespaces)
        if lower.hasPrefix("/") || lower.hasPrefix("#") || lower.hasPrefix("./") || lower.hasPrefix("../") {
            return true
        }
        for scheme in ["http://", "https://", "mailto:", "tel:"] where lower.hasPrefix(scheme) {
            return true
        }
        // Scheme-less relative URLs ("page.html", "docs/page?q=1") are fine as
        // long as no scheme delimiter appears before the first path separator.
        if let colon = lower.firstIndex(of: ":") {
            if let slash = lower.firstIndex(of: "/"), slash < colon { return true }
            return false
        }
        return true
    }
}
