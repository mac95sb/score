import Foundation

/// Context passed through the HTML rendering process.
///
/// Tracks the current component scope, accumulated modifiers, and element counters.
/// Passed as `inout` so that mutations made while rendering a child view are visible
/// to sibling views that render afterwards (e.g., `tagOccurrences` counter).
public struct RenderContext: Sendable {
    /// The Swift type name of the current top-level component (PascalCase).
    public var componentTypeName: String = ""

    /// Stack of modifiers accumulated on the path from the component root to the
    /// current element.  The last element is the innermost modifier.
    public var modifierStack: [any ViewModifier] = []

    /// Tracks how many times each HTML tag has been seen in the current component
    /// scope.  Used to disambiguate duplicate tags and assign scoped CSS classes.
    public var tagOccurrences: [String: Int] = [:]

    /// The current rendering depth.  Used for diagnostics (lint P001).
    public var depth: Int = 0

    public init() {}

    // MARK: - Derived helpers

    /// Kebab-case CSS class name for the current component.
    ///
    /// `ArticleCard` → `"article-card"`
    public var componentCSSClass: String {
        StyleScope.cssClass(from: componentTypeName)
    }

    // MARK: - Modifier stack

    mutating func pushModifier(_ modifier: any ViewModifier) {
        modifierStack.append(modifier)
    }

    mutating func popModifier() {
        if !modifierStack.isEmpty { modifierStack.removeLast() }
    }

    // MARK: - Tag occurrence tracking

    /// Record a tag occurrence; returns the 1-based count for this tag in the
    /// current component scope.
    mutating func recordTag(_ tag: String) -> Int {
        let count = (tagOccurrences[tag] ?? 0) + 1
        tagOccurrences[tag] = count
        return count
    }
}
