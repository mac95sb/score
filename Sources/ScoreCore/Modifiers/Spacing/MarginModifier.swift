// MARK: - MarginModifier

/// A modifier that applies CSS `margin` to an element.
///
/// Use ``View/margin(_:on:)`` and its overloads rather than constructing
/// `MarginModifier` directly.
///
/// ```swift
/// Section { ... }
///     .margin(x: .auto)    // horizontal centering
///     .margin(y: 8)        // 32px top and bottom
///     .margin(top: 4)      // 16px top only
/// ```
///
/// - SeeAlso: ``View/margin(_:on:)``, ``PaddingModifier``
public struct MarginModifier: ThemeAwareModifier {
    let top: SpacingValue?
    let right: SpacingValue?
    let bottom: SpacingValue?
    let left: SpacingValue?
    let condition: ModifierCondition?

    public init(all: SpacingValue, condition: ModifierCondition? = nil) {
        self.top = all
        self.right = all
        self.bottom = all
        self.left = all
        self.condition = condition
    }

    public init(x: SpacingValue? = nil, y: SpacingValue? = nil, condition: ModifierCondition? = nil) {
        self.top = y
        self.right = x
        self.bottom = y
        self.left = x
        self.condition = condition
    }

    public init(
        top: SpacingValue? = nil,
        right: SpacingValue? = nil,
        bottom: SpacingValue? = nil,
        left: SpacingValue? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        if let t = top, let r = right, let b = bottom, let l = left {
            if t.css == r.css && r.css == b.css && b.css == l.css {
                return [ConditionedDeclaration("margin", t.css, condition: condition)]
            }
            if t.css == b.css && r.css == l.css {
                return [ConditionedDeclaration("margin", "\(t.css) \(r.css)", condition: condition)]
            }
            return [ConditionedDeclaration("margin", "\(t.css) \(r.css) \(b.css) \(l.css)", condition: condition)]
        }
        var result: [ConditionedDeclaration] = []
        if let t = top { result.append(ConditionedDeclaration("margin-top", t.css, condition: condition)) }
        if let r = right { result.append(ConditionedDeclaration("margin-right", r.css, condition: condition)) }
        if let b = bottom { result.append(ConditionedDeclaration("margin-bottom", b.css, condition: condition)) }
        if let l = left { result.append(ConditionedDeclaration("margin-left", l.css, condition: condition)) }
        return result
    }
}
