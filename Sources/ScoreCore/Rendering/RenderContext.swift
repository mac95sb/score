import Foundation

/// Context passed through the HTML rendering process.
///
/// Tracks the current component scope, accumulated modifiers, per-element
/// scoped CSS, and element counters.
/// Passed as `inout` so that mutations made while rendering a child view are visible
/// to sibling views that render afterwards (e.g., `tagOccurrences` counter).
public struct RenderContext: Sendable {
    /// The Swift type name of the current top-level component (PascalCase).
    public var componentTypeName: String = ""

    /// Stack of modifiers accumulated on the path from the component root to the
    /// current element.  The last element is the innermost modifier.
    public var modifierStack: [any ViewModifier] = []

    /// When set by `ConditionGroupView`, every modifier consumed from the stack
    /// during the next `takeStyles()` call is treated as conditional under this
    /// condition — unless the modifier already carries its own condition.
    public var conditionOverride: ModifierCondition? = nil

    /// Per-element scoped CSS accumulated during a single render pass.
    /// Injected into the page `<style>` block by `PageRenderer`.
    public var cssBuffer: String = ""

    /// Monotonically increasing counter used to generate unique scoped class names
    /// (`sc-1`, `sc-2`, …) within a single render.
    public var elementCounter: Int = 0

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

    // MARK: - Style extraction

    /// Extract inline styles and any scoped CSS class from the current modifier
    /// stack, then clear the stack and conditionOverride so children don't inherit
    /// ancestor modifiers.
    ///
    /// - Unconditional modifiers → inline `style=""` string.
    /// - Conditional modifiers (`:hover`, `@media`, animations, etc.) → a unique
    ///   scoped class appended to `cssBuffer`.
    ///
    /// Callers **must** restore `modifierStack` and `conditionOverride` from the
    /// returned saved values after rendering children, so that `ModifiedContent`
    /// can pop correctly.
    mutating func takeStyles(theme: SiteTheme = .default) -> (
        inlineStyle: String,
        className: String?,
        savedStack: [any ViewModifier],
        savedCondition: ModifierCondition?
    ) {
        let savedStack = modifierStack
        let savedCondition = conditionOverride

        var inlineParts: [String] = []
        var condBlock = ComponentStyleBlock()
        var hasConditional = false

        for modifier in modifierStack {
            if let themeAware = modifier as? any ThemeAwareModifier {
                for condDecl in themeAware.declarations(theme: theme) {
                    // Per-declaration condition takes priority; fall back to group override.
                    let effectiveCondition = condDecl.condition ?? conditionOverride
                    if let condition = effectiveCondition {
                        hasConditional = true
                        if let cssCondition = condition.cssCondition(theme: theme) {
                            condBlock.add(
                                CSSDeclaration(condDecl.property, condDecl.value),
                                condition: cssCondition
                            )
                        }
                    } else {
                        inlineParts.append("\(condDecl.property):\(condDecl.value)")
                    }
                }
            } else {
                let ownCSSCondition = modifier.cssCondition()
                let effectiveCSSCondition: CSSCondition? = ownCSSCondition
                    ?? conditionOverride?.cssCondition(theme: theme)
                if let condition = effectiveCSSCondition {
                    hasConditional = true
                    for decl in modifier.cssDeclarations() {
                        condBlock.add(decl, condition: condition)
                    }
                } else {
                    for decl in modifier.cssDeclarations() {
                        inlineParts.append("\(decl.property):\(decl.value)")
                    }
                }
            }
        }

        // Clear stack and condition so children don't inherit them.
        modifierStack = []
        conditionOverride = nil

        var className: String? = nil
        if hasConditional && !condBlock.isEmpty {
            elementCounter += 1
            let cls = "sc-\(elementCounter)"
            className = cls
            cssBuffer += condBlock.toRule(componentClass: cls).renderMinified()
        }

        return (inlineParts.joined(separator: ";"), className, savedStack, savedCondition)
    }

    /// Legacy helper — returns only the unconditional inline style string.
    /// Prefer `takeStyles()` for new code.
    public func unconditionalInlineStyle(theme: SiteTheme = .default) -> String {
        var parts: [String] = []
        for modifier in modifierStack {
            if let themeAware = modifier as? any ThemeAwareModifier {
                for condDecl in themeAware.declarations(theme: theme) where condDecl.condition == nil {
                    parts.append("\(condDecl.property):\(condDecl.value)")
                }
            } else if modifier.cssCondition() == nil {
                for decl in modifier.cssDeclarations() {
                    parts.append("\(decl.property):\(decl.value)")
                }
            }
        }
        return parts.joined(separator: ";")
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
