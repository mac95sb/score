// MARK: - FlexModifier

/// A modifier that applies CSS Flexbox properties to an element.
///
/// Use ``View/flex(direction:wrap:align:justify:gap:columnGap:rowGap:grow:shrink:basis:alignSelf:order:placeItems:at:)``
/// rather than constructing `FlexModifier` directly. Multiple `.flex()` calls
/// accumulate — each call only overrides the properties it specifies.
///
/// ```swift
/// HStack {
///     Label { "Name" }
///     Spacer()
///     Text { user.name }
/// }
/// .flex(align: .center)
/// .flex(gap: 4)
/// .flex(direction: .vertical, at: .tablet)
/// ```
///
/// - SeeAlso: ``View/flex(direction:wrap:align:justify:gap:columnGap:rowGap:grow:shrink:basis:alignSelf:order:placeItems:at:)``, ``GridModifier``
public struct FlexModifier: ThemeAwareModifier {
    let direction: FlexDirection?
    let wrap: FlexWrap?
    let align: FlexAlignment?
    let justify: FlexAlignment?
    let gap: SpacingValue?
    let columnGap: SpacingValue?
    let rowGap: SpacingValue?
    let grow: Int?
    let shrink: Int?
    let basis: SpacingValue?
    let alignSelf: FlexAlignment?
    let justifySelf: String?
    let order: FlexOrder?
    let placeItems: String?
    let condition: ModifierCondition?

    public init(
        direction: FlexDirection? = nil,
        wrap: FlexWrap? = nil,
        align: FlexAlignment? = nil,
        justify: FlexAlignment? = nil,
        gap: SpacingValue? = nil,
        columnGap: SpacingValue? = nil,
        rowGap: SpacingValue? = nil,
        grow: Int? = nil,
        shrink: Int? = nil,
        basis: SpacingValue? = nil,
        alignSelf: FlexAlignment? = nil,
        justifySelf: String? = nil,
        order: FlexOrder? = nil,
        placeItems: String? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.direction = direction
        self.wrap = wrap
        self.align = align
        self.justify = justify
        self.gap = gap
        self.columnGap = columnGap
        self.rowGap = rowGap
        self.grow = grow
        self.shrink = shrink
        self.basis = basis
        self.alignSelf = alignSelf
        self.justifySelf = justifySelf
        self.order = order
        self.placeItems = placeItems
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []

        // Only emit display:flex when container-level properties are set
        let isContainer = direction != nil || wrap != nil || align != nil || justify != nil || gap != nil || columnGap != nil || rowGap != nil || placeItems != nil
        if isContainer {
            result.append(ConditionedDeclaration("display", "flex", condition: condition))
        }

        if let d = direction { result.append(ConditionedDeclaration("flex-direction", d.rawValue, condition: condition)) }
        if let w = wrap { result.append(ConditionedDeclaration("flex-wrap", w.rawValue, condition: condition)) }
        if let a = align { result.append(ConditionedDeclaration("align-items", a.rawValue, condition: condition)) }
        if let j = justify { result.append(ConditionedDeclaration("justify-content", j.rawValue, condition: condition)) }
        if let g = gap { result.append(ConditionedDeclaration("gap", g.css, condition: condition)) }
        if let cg = columnGap { result.append(ConditionedDeclaration("column-gap", cg.css, condition: condition)) }
        if let rg = rowGap { result.append(ConditionedDeclaration("row-gap", rg.css, condition: condition)) }
        if let g = grow { result.append(ConditionedDeclaration("flex-grow", "\(g)", condition: condition)) }
        if let s = shrink { result.append(ConditionedDeclaration("flex-shrink", "\(s)", condition: condition)) }
        if let b = basis { result.append(ConditionedDeclaration("flex-basis", b.css, condition: condition)) }
        if let as_ = alignSelf { result.append(ConditionedDeclaration("align-self", as_.rawValue, condition: condition)) }
        if let js = justifySelf { result.append(ConditionedDeclaration("justify-self", js, condition: condition)) }
        if let o = order { result.append(ConditionedDeclaration("order", o.css, condition: condition)) }
        if let pi = placeItems { result.append(ConditionedDeclaration("place-items", pi, condition: condition)) }
        return result
    }
}
