import Foundation
import ScoreCore

/// Collects and deduplicates CSS from a set of view trees.
///
/// `StyleCollector` wraps ``CSSCollector`` and exposes a higher-level API
/// for collecting styles from multiple pages or components in a single pass,
/// returning the combined CSS ready for writing to a bundle file.
///
/// ```swift
/// let collector = StyleCollector()
/// for page in pages {
///     collector.collect(from: page.body, componentTypeName: "\(type(of: page))")
/// }
/// let css = collector.buildCSS(minify: true)
/// ```
public final class StyleCollector: @unchecked Sendable {
    private var rules: [CSSRule] = []
    private var seenComponents: Set<String> = []
    private let lock = NSLock()

    public init() {}

    // MARK: - Collection

    /// Collect CSS from a view tree.
    ///
    /// - Parameters:
    ///   - view: The root of the view tree (typically `page.body`).
    ///   - componentTypeName: The PascalCase Swift type name of the owning component.
    public func collect(from view: some View, componentTypeName: String) {
        lock.lock()
        defer { lock.unlock() }
        guard !seenComponents.contains(componentTypeName) else { return }
        seenComponents.insert(componentTypeName)
        let collector = CSSCollector()
        let collected = collector.collect(from: view, componentTypeName: componentTypeName)
        rules.append(contentsOf: collected)
    }

    // MARK: - Output

    /// Return the combined CSS string.
    ///
    /// - Parameter minify: When `true`, strips whitespace and comments.
    public func buildCSS(minify: Bool = false) -> String {
        lock.lock()
        defer { lock.unlock() }
        guard minify else {
            return rules.map { $0.render() }.joined(separator: "\n")
        }
        return rules.map { $0.renderMinified() }.joined()
    }

    /// Reset all collected data.
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        rules.removeAll()
        seenComponents.removeAll()
    }
}
