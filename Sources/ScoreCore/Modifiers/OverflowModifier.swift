// MARK: - OverflowModifier

public struct OverflowModifier: ThemeAwareModifier {
    let both: OverflowValue?
    let x: OverflowValue?
    let y: OverflowValue?
    let overscroll: String?
    let condition: ModifierCondition?

    public init(
        both: OverflowValue? = nil,
        x: OverflowValue? = nil,
        y: OverflowValue? = nil,
        overscroll: String? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.both = both; self.x = x; self.y = y
        self.overscroll = overscroll; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []
        if let b = both {
            result.append(ConditionedDeclaration("overflow", b.rawValue, condition: condition))
        } else {
            if let xv = x { result.append(ConditionedDeclaration("overflow-x", xv.rawValue, condition: condition)) }
            if let yv = y { result.append(ConditionedDeclaration("overflow-y", yv.rawValue, condition: condition)) }
        }
        if let os = overscroll {
            result.append(ConditionedDeclaration("overscroll-behavior", os, condition: condition))
        }
        return result
    }
}
