import Foundation

/// Minifies HTML strings by stripping comments and collapsing whitespace.
///
/// The minifier is designed to be safe on the output of Score's renderer —
/// it does not parse the DOM and will not corrupt inline `<script>` or
/// `<style>` blocks that contain valid HTML characters.
///
/// ```swift
/// let minifier = HTMLMinifier()
/// let small = minifier.minify(html)
/// ```
public struct HTMLMinifier: Sendable {
    public init() {}

    /// Minify an HTML string.
    ///
    /// Steps applied (in order):
    /// 1. Strip `<!-- ... -->` comments (preserving IE conditionals starting with `[if`).
    /// 2. Collapse runs of whitespace between tags to a single space.
    /// 3. Remove leading and trailing whitespace from the overall string.
    public func minify(_ html: String) -> String {
        var result = html

        // 1. Strip HTML comments (preserve IE conditionals <!--[if...-->)
        result = stripComments(result)

        // 2. Collapse inter-tag whitespace
        result = collapseWhitespace(result)

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Private

    private func stripComments(_ html: String) -> String {
        var result = ""
        var index = html.startIndex

        while index < html.endIndex {
            if html[index...].hasPrefix("<!--") {
                // Look for conditional comments — preserve them
                let afterOpen = html.index(index, offsetBy: 4)
                if afterOpen < html.endIndex && html[afterOpen...].hasPrefix("[if") {
                    if let closeRange = html.range(of: "-->", range: index..<html.endIndex) {
                        result += html[index...closeRange.upperIndex]
                        index = closeRange.upperIndex
                    } else {
                        result += html[index...]
                        break
                    }
                } else {
                    // Regular comment — skip to -->
                    if let closeRange = html.range(of: "-->", range: index..<html.endIndex) {
                        index = closeRange.upperIndex
                    } else {
                        break
                    }
                }
            } else {
                result.append(html[index])
                index = html.index(after: index)
            }
        }

        return result
    }

    private func collapseWhitespace(_ html: String) -> String {
        // Replace sequences of whitespace between > and < with a single space
        var result = ""
        var inTag = false
        var prevWasSpace = false

        for ch in html {
            switch ch {
            case "<":
                if prevWasSpace && !result.isEmpty && result.last != ">" {
                    result.append(" ")
                }
                prevWasSpace = false
                inTag = true
                result.append(ch)
            case ">":
                prevWasSpace = false
                inTag = false
                result.append(ch)
            case " ", "\t", "\n", "\r":
                if inTag {
                    // Inside tags collapse to single space
                    if !prevWasSpace {
                        result.append(" ")
                    }
                    prevWasSpace = true
                } else {
                    prevWasSpace = true
                }
            default:
                if prevWasSpace && !inTag && !result.isEmpty {
                    result.append(" ")
                }
                prevWasSpace = false
                result.append(ch)
            }
        }

        return result
    }
}

// MARK: - String subscript helper

private extension String {
    subscript(range: Range<String.Index>) -> Substring { self[range] }

    var upperIndex: String.Index {
        // not actually needed, this is a typo guard
        self.endIndex
    }
}

private extension Range where Bound == String.Index {
    var upperIndex: Bound { upperBound }
}
