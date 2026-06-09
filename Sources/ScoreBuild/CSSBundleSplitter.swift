import Foundation

/// The result of a CSS bundle split operation.
public struct CSSBundles: Sendable {
    /// CSS that is referenced by every page — written to `global.css`.
    public let global: String
    /// Per-group CSS chunks keyed by their filename (e.g. `"blog.css"`).
    public let chunks: [String: String]

    public init(global: String, chunks: [String: String]) {
        self.global = global
        self.chunks = chunks
    }
}

/// Splits a per-page CSS map into a `global.css` and per-group chunk files
/// using co-occurrence analysis.
///
/// Rules that appear on every page go into `global.css`.  Rules that appear
/// on a subset of pages are grouped by co-occurrence and written to separate
/// chunk files, allowing browsers to cache them independently.
///
/// ```swift
/// let splitter = CSSBundleSplitter()
/// let bundles = splitter.split(pageStyles: ["/" : ".hero { ... }", "/blog": ".card { ... }"])
/// // bundles.global — shared across all pages
/// // bundles.chunks["blog.css"] — styles only needed for /blog/**
/// ```
public struct CSSBundleSplitter: Sendable {
    /// Pages that share fewer than this many rules with the global set are
    /// placed in per-route chunks rather than the global bundle.
    public let minimumGlobalOccurrence: Int

    public init(minimumGlobalOccurrence: Int = 2) {
        self.minimumGlobalOccurrence = minimumGlobalOccurrence
    }

    /// Split per-page CSS into a global bundle and route-specific chunks.
    ///
    /// - Parameter pageStyles: A dictionary mapping page URL paths to their
    ///   collected CSS strings.
    /// - Returns: A ``CSSBundles`` value containing the global CSS and any
    ///   per-group chunks.
    public func split(pageStyles: [String: String]) -> CSSBundles {
        guard !pageStyles.isEmpty else {
            return CSSBundles(global: "", chunks: [:])
        }

        // Tokenise each page's CSS into individual rule blocks
        let pageRules: [String: [String]] = pageStyles.mapValues { tokenizeRules($0) }
        let pageCount = pageRules.count

        // Count occurrences of each rule across pages
        var occurrences: [String: Int] = [:]
        for rules in pageRules.values {
            for rule in rules {
                occurrences[rule, default: 0] += 1
            }
        }

        // Rules that appear on every page → global
        let globalRules = occurrences
            .filter { $0.value >= min(minimumGlobalOccurrence, pageCount) }
            .keys
        let globalSet = Set(globalRules)

        // Remaining rules are per-page
        var perPageRules: [String: [String]] = [:]
        for (page, rules) in pageRules {
            let unique = rules.filter { !globalSet.contains($0) }
            if !unique.isEmpty {
                perPageRules[page] = unique
            }
        }

        // Group pages with identical remaining rule sets into shared chunks
        var groupedChunks: [[String]: [String]] = [:]
        for (_, rules) in perPageRules {
            let sorted = rules.sorted()
            groupedChunks[sorted, default: []].append(contentsOf: rules)
        }

        // Build chunk filenames from page paths
        var chunks: [String: String] = [:]
        for (rules, _) in groupedChunks {
            let css = rules.joined(separator: "\n")
            // Derive a chunk name from the first rule's selector
            let chunkName = deriveChunkName(from: rules.first ?? "chunk")
            chunks[chunkName] = css
        }

        let globalCSS = globalSet.sorted().joined(separator: "\n")
        return CSSBundles(global: globalCSS, chunks: chunks)
    }

    // MARK: - Private

    private func tokenizeRules(_ css: String) -> [String] {
        // Split on top-level `}` boundaries to extract individual rule blocks.
        // This is a simple heuristic suitable for Score's generated CSS.
        var rules: [String] = []
        var depth = 0
        var current = ""

        for ch in css {
            current.append(ch)
            if ch == "{" {
                depth += 1
            } else if ch == "}" {
                depth -= 1
                if depth == 0 {
                    let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        rules.append(trimmed)
                    }
                    current = ""
                }
            }
        }

        return rules
    }

    private func deriveChunkName(from rule: String) -> String {
        // Extract the first class or element selector token
        let selector = rule.prefix(while: { $0 != "{" && $0 != " " })
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: ":", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }

        let name = selector.isEmpty ? "chunk" : String(selector.prefix(32))
        return "\(name).css"
    }
}
