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
        let rendered = Self.render(markdown)
        return "<div class=\"rich-text\">\(rendered)</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}

// MARK: - Markdown rendering

/// Simple markdown-to-HTML rendering covering common cases.
///
/// Full production use should integrate swift-markdown (see ``MarkdownRenderer``);
/// this handles headings, paragraphs, lists, code blocks, blockquotes, and inline
/// formatting (bold, italic, code, links, strikethrough).
extension RichText {
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
        // Links [text](url) — the URL lands in an href, so reject dangerous
        // schemes (javascript:, data:, vbscript:) to prevent XSS on click.
        result = replaceLinks(in: result)
        // Strikethrough ~~text~~
        result = result.replacingOccurrences(
            of: "~~(.+?)~~",
            with: "<del>$1</del>",
            options: .regularExpression
        )
        return result
    }

    /// Replace `[text](url)` with anchors. URLs whose scheme is not on the safe
    /// allowlist are rendered as plain text instead of links, so a
    /// `javascript:`/`data:`/`vbscript:` payload can never reach an `href`.
    /// Operates on already-HTML-escaped text.
    static func replaceLinks(in input: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "\\[(.+?)\\]\\((.+?)\\)") else {
            return input
        }
        let ns = input as NSString
        var output = ""
        var lastEnd = 0
        for match in regex.matches(in: input, range: NSRange(location: 0, length: ns.length)) {
            output += ns.substring(with: NSRange(location: lastEnd, length: match.range.location - lastEnd))
            let text = ns.substring(with: match.range(at: 1))
            let url = ns.substring(with: match.range(at: 2))
            if isSafeLinkURL(url) {
                output += "<a href=\"\(url)\">\(text)</a>"
            } else {
                output += text
            }
            lastEnd = match.range.location + match.range.length
        }
        output += ns.substring(from: lastEnd)
        return output
    }

    /// Whether `url` is safe to place in an `href`: either a relative reference
    /// (no scheme) or one using an allow-listed, non-script scheme. Accepts both
    /// raw and HTML-escaped input — only the scheme is inspected.
    public static func isSafeLinkURL(_ url: String) -> Bool {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let colon = trimmed.firstIndex(of: ":") else {
            // No colon → relative URL / anchor / query — always safe.
            return true
        }
        let scheme = trimmed[trimmed.startIndex..<colon]
        // A "scheme" containing /, ?, or # is really a path segment (e.g.
        // "foo/bar:baz"), so the reference is relative and safe.
        if scheme.contains("/") || scheme.contains("?") || scheme.contains("#") {
            return true
        }
        let allowed: Set<String> = ["http", "https", "mailto", "tel"]
        return allowed.contains(scheme.lowercased())
    }
}
