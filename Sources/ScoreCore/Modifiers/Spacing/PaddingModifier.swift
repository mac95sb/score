// MARK: - PaddingModifier

/// A modifier that applies CSS `padding` to an element.
///
/// Create instances through the ``View/padding(_:on:)`` family of methods rather
/// than constructing `PaddingModifier` directly.
///
/// ```swift
/// Text { "Hello" }
///     .padding(4)               // all sides — step 4 = 16px
///     .padding(x: 6, y: 3)     // horizontal / vertical
///     .padding(top: 2, left: 4) // individual edges
/// ```
///
/// Values accept spacing-scale steps (`Int` or `Double`) or explicit
/// ``SpacingValue`` variants such as `.px(n)`, `.rem(n)`, and `.auto`.
///
/// - SeeAlso: ``View/padding(_:on:)``, ``View/margin(_:on:)``
public struct PaddingModifier: ThemeAwareModifier {
    let top: SpacingValue?
    let right: SpacingValue?
    let bottom: SpacingValue?
    let left: SpacingValue?
    let condition: ModifierCondition?

    public init(all: SpacingValue, condition: ModifierCondition? = nil) {
        self.top = all; self.right = all; self.bottom = all; self.left = all
        self.condition = condition
    }

    public init(x: SpacingValue? = nil, y: SpacingValue? = nil, condition: ModifierCondition? = nil) {
        self.top = y; self.right = x; self.bottom = y; self.left = x
        self.condition = condition
    }

    public init(
        top: SpacingValue? = nil,
        right: SpacingValue? = nil,
        bottom: SpacingValue? = nil,
        left: SpacingValue? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.top = top; self.right = right; self.bottom = bottom; self.left = left
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        // All four sides set
        if let t = top, let r = right, let b = bottom, let l = left {
            // All equal → shorthand
            if t.css == r.css && r.css == b.css && b.css == l.css {
                return [ConditionedDeclaration("padding", t.css, condition: condition)]
            }
            // Vertical == vertical, horizontal == horizontal → 2-value shorthand
            if t.css == b.css && r.css == l.css {
                return [ConditionedDeclaration("padding", "\(t.css) \(r.css)", condition: condition)]
            }
            // 4-value shorthand
            return [ConditionedDeclaration("padding", "\(t.css) \(r.css) \(b.css) \(l.css)", condition: condition)]
        }
        // Individual sides
        var result: [ConditionedDeclaration] = []
        if let t = top    { result.append(ConditionedDeclaration("padding-top",    t.css, condition: condition)) }
        if let r = right  { result.append(ConditionedDeclaration("padding-right",  r.css, condition: condition)) }
        if let b = bottom { result.append(ConditionedDeclaration("padding-bottom", b.css, condition: condition)) }
        if let l = left   { result.append(ConditionedDeclaration("padding-left",   l.css, condition: condition)) }
        return result
    }
}
