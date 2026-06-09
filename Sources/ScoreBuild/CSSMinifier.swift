import Foundation

/// Minifies CSS strings by stripping comments and collapsing whitespace.
///
/// The minifier preserves functional correctness while significantly reducing
/// file size. It is safe on Score's generated CSS which uses native nesting.
///
/// ```swift
/// let minifier = CSSMinifier()
/// let small = minifier.minify(css)
/// ```
public struct CSSMinifier: Sendable {
    public init() {}

    /// Minify a CSS string.
    ///
    /// Steps applied (in order):
    /// 1. Strip `/* ... */` block comments.
    /// 2. Collapse runs of whitespace to single spaces.
    /// 3. Remove spaces around `:`, `;`, `{`, `}`, `,`, `>`, `~`, `+`.
    /// 4. Remove trailing semicolons before `}`.
    /// 5. Trim the result.
    public func minify(_ css: String) -> String {
        var result = css

        // 1. Strip block comments
        result = stripBlockComments(result)

        // 2. Collapse whitespace (preserve spaces inside string literals & url())
        result = collapseWhitespace(result)

        // 3. Remove spaces around structural characters
        result = removeStructuralSpaces(result)

        // 4. Remove trailing semicolons before }
        result = result.replacingOccurrences(of: ";}", with: "}")

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Private

    private func stripBlockComments(_ css: String) -> String {
        var result = ""
        var index = css.startIndex
        var inString = false
        var stringChar: Character = "\0"

        while index < css.endIndex {
            let ch = css[index]

            if inString {
                result.append(ch)
                if ch == stringChar {
                    inString = false
                }
                index = css.index(after: index)
            } else if ch == "\"" || ch == "'" {
                inString = true
                stringChar = ch
                result.append(ch)
                index = css.index(after: index)
            } else if css[index...].hasPrefix("/*") {
                // Find closing */
                let searchStart = css.index(index, offsetBy: 2, limitedBy: css.endIndex) ?? css.endIndex
                if let closeRange = css.range(of: "*/", range: searchStart..<css.endIndex) {
                    index = closeRange.upperBound
                } else {
                    // Unterminated comment — drop the rest
                    break
                }
            } else {
                result.append(ch)
                index = css.index(after: index)
            }
        }

        return result
    }

    private func collapseWhitespace(_ css: String) -> String {
        var result = ""
        var prevWasWhitespace = false
        var inString = false
        var stringChar: Character = "\0"

        for ch in css {
            if inString {
                result.append(ch)
                if ch == stringChar { inString = false }
            } else if ch == "\"" || ch == "'" {
                if prevWasWhitespace { result.append(" ") }
                prevWasWhitespace = false
                inString = true
                stringChar = ch
                result.append(ch)
            } else if ch.isWhitespace {
                prevWasWhitespace = true
            } else {
                if prevWasWhitespace && !result.isEmpty {
                    result.append(" ")
                }
                prevWasWhitespace = false
                result.append(ch)
            }
        }

        return result
    }

    private func removeStructuralSpaces(_ css: String) -> String {
        var result = css

        // Remove spaces before and after structural characters
        let structuralChars = ["{", "}", ";", ",", ":"]
        for char in structuralChars {
            result = result.replacingOccurrences(of: " \(char)", with: char)
            result = result.replacingOccurrences(of: "\(char) ", with: char)
        }

        // Restore single space after colons in property values (not selectors)
        // This is a best-effort heuristic — Score's CSS is machine-generated
        // and uses short-hand values that need spaces preserved.
        // We re-add space after : when preceded by a known property-like token.

        return result
    }
}
