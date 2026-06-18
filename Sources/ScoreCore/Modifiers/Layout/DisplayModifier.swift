// MARK: - DisplayModifier

/// A modifier that sets the CSS `display` property of an element.
///
/// Use ``View/display(_:on:)`` rather than constructing `DisplayModifier` directly.
///
/// ```swift
/// Sidebar { ... }
///     .display(.none, at: .mobile)
///     .display(.block, at: .tablet)
/// ```
///
/// - SeeAlso: ``View/display(_:on:)``, ``VisibilityModifier``
public struct DisplayModifier: ThemeAwareModifier {
    let value: DisplayValue
    let condition: ModifierCondition?

    public init(_ value: DisplayValue, condition: ModifierCondition? = nil) {
        self.value = value
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("display", value.rawValue, condition: condition)]
    }
}

// MARK: - VisibilityModifier

/// A modifier that sets the CSS `visibility` property.
///
/// Use ``View/hidden(_:on:)`` rather than constructing `VisibilityModifier` directly.
/// Unlike `display: none`, `visibility: hidden` keeps the element in the layout flow.
///
/// - SeeAlso: ``View/hidden(_:on:)``, ``DisplayModifier``
public struct VisibilityModifier: ThemeAwareModifier {
    let hidden: Bool
    let condition: ModifierCondition?

    public init(hidden: Bool, condition: ModifierCondition? = nil) {
        self.hidden = hidden
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("visibility", hidden ? "hidden" : "visible", condition: condition)]
    }
}
