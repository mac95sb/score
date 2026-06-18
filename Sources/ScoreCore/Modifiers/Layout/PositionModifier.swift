// MARK: - PositionModifier

/// A modifier that applies CSS `position`, inset, and `z-index` properties.
///
/// Use ``View/position(_:top:right:bottom:left:at:)`` and its overloads rather
/// than constructing `PositionModifier` directly.
///
/// ```swift
/// Overlay { Spinner() }
///     .position(.absolute, inset: 0)
///
/// SiteNavigation()
///     .position(.sticky, top: 0)
///     .position(zIndex: 10)
/// ```
///
/// - SeeAlso: ``View/position(_:top:right:bottom:left:at:)``
public struct PositionModifier: ThemeAwareModifier {
    let type: PositionType?
    let top: SpacingValue?
    let right: SpacingValue?
    let bottom: SpacingValue?
    let left: SpacingValue?
    let inset: SpacingValue?
    let insetX: SpacingValue?
    let insetY: SpacingValue?
    let zIndex: Int?
    let condition: ModifierCondition?

    public init(
        type: PositionType? = nil,
        top: SpacingValue? = nil,
        right: SpacingValue? = nil,
        bottom: SpacingValue? = nil,
        left: SpacingValue? = nil,
        inset: SpacingValue? = nil,
        insetX: SpacingValue? = nil,
        insetY: SpacingValue? = nil,
        zIndex: Int? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.type = type
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.inset = inset
        self.insetX = insetX
        self.insetY = insetY
        self.zIndex = zIndex
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []
        if let t = type { result.append(ConditionedDeclaration("position", t.rawValue, condition: condition)) }
        if let i = inset {
            result.append(ConditionedDeclaration("inset", i.css, condition: condition))
        } else {
            if let ix = insetX {
                result.append(ConditionedDeclaration("left", ix.css, condition: condition))
                result.append(ConditionedDeclaration("right", ix.css, condition: condition))
            }
            if let iy = insetY {
                result.append(ConditionedDeclaration("top", iy.css, condition: condition))
                result.append(ConditionedDeclaration("bottom", iy.css, condition: condition))
            }
            if let t = top { result.append(ConditionedDeclaration("top", t.css, condition: condition)) }
            if let r = right { result.append(ConditionedDeclaration("right", r.css, condition: condition)) }
            if let b = bottom { result.append(ConditionedDeclaration("bottom", b.css, condition: condition)) }
            if let l = left { result.append(ConditionedDeclaration("left", l.css, condition: condition)) }
        }
        if let z = zIndex { result.append(ConditionedDeclaration("z-index", "\(z)", condition: condition)) }
        return result
    }
}
