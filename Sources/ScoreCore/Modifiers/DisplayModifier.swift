// MARK: - DisplayModifier

public struct DisplayModifier: ThemeAwareModifier {
    let value: DisplayValue
    let condition: ModifierCondition?

    public init(_ value: DisplayValue, condition: ModifierCondition? = nil) {
        self.value = value; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("display", value.rawValue, condition: condition)]
    }
}

// MARK: - VisibilityModifier

public struct VisibilityModifier: ThemeAwareModifier {
    let hidden: Bool
    let condition: ModifierCondition?

    public init(hidden: Bool, condition: ModifierCondition? = nil) {
        self.hidden = hidden; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("visibility", hidden ? "hidden" : "visible", condition: condition)]
    }
}
