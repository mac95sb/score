// MARK: - ShadowModifier

/// A modifier that applies a CSS `box-shadow` or focus-ring to an element.
///
/// Use ``View/shadow(_:color:on:)`` and its overloads rather than constructing
/// `ShadowModifier` directly.
///
/// ```swift
/// Card { ... }
///     .shadow(.md)
///     .shadow(.lg, on: .hover)
///     .shadow(ring: 2, color: .primary.opacity(0.5), on: .focus)
/// ```
///
/// - SeeAlso: ``View/shadow(_:color:on:)``, ``ShadowToken``
public struct ShadowModifier: ThemeAwareModifier {
    let token: ShadowToken?
    let customString: String?
    let color: Color?
    let ring: Double?
    let ringColor: Color?
    let dropShadow: ShadowToken?
    let condition: ModifierCondition?

    public init(
        token: ShadowToken? = nil,
        customString: String? = nil,
        color: Color? = nil,
        ring: Double? = nil,
        ringColor: Color? = nil,
        dropShadow: ShadowToken? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.token = token; self.customString = customString
        self.color = color; self.ring = ring; self.ringColor = ringColor
        self.dropShadow = dropShadow; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []

        // Ring shadow: box-shadow inset ring
        if let ringWidth = ring {
            let ringCol = ringColor ?? Color(oklch: 0.606, 0.224, 292.7) // violet-500
            let ringShadow = "0 0 0 \(ringWidth.cssStr)px \(ringCol.cssValue)"
            result.append(ConditionedDeclaration("box-shadow", ringShadow, condition: condition))
            return result
        }

        // Custom string
        if let cs = customString {
            result.append(ConditionedDeclaration("box-shadow", cs, condition: condition))
            return result
        }

        // Token-based shadow
        if let t = token {
            result.append(ConditionedDeclaration("box-shadow", t.css(theme: theme), condition: condition))
        }

        // Drop shadow via CSS filter
        if let ds = dropShadow {
            let shadowValue = ds.css(theme: theme)
            result.append(ConditionedDeclaration("filter", "drop-shadow(\(shadowValue))", condition: condition))
        }

        return result
    }
}
