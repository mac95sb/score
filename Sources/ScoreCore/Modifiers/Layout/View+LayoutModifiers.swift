// MARK: - Layout modifiers (flex, grid, position, overflow, display, visibility)

extension View {

    // MARK: Flex

    /// Apply flex layout properties.
    public func flex(
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
        order: FlexOrder? = nil,
        placeItems: String? = nil,
        at condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, FlexModifier> {
        modifier(FlexModifier(
            direction: direction, wrap: wrap, align: align, justify: justify,
            gap: gap, columnGap: columnGap, rowGap: rowGap,
            grow: grow, shrink: shrink, basis: basis,
            alignSelf: alignSelf, order: order, placeItems: placeItems,
            condition: condition
        ))
    }

    // MARK: Grid

    /// Apply grid layout properties.
    public func grid(
        columns: Int? = nil,
        rows: String? = nil,
        gap: SpacingValue? = nil,
        columnGap: SpacingValue? = nil,
        rowGap: SpacingValue? = nil,
        span: Int? = nil,
        rowSpan: Int? = nil,
        spanFull: Bool? = nil,
        area: String? = nil,
        autoFlow: GridAutoFlow? = nil,
        placeItems: String? = nil,
        alignSelf: String? = nil,
        justifySelf: String? = nil,
        at condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, GridModifier> {
        modifier(GridModifier(
            columns: columns, rows: rows, gap: gap,
            columnGap: columnGap, rowGap: rowGap,
            span: span, rowSpan: rowSpan, spanFull: spanFull,
            area: area, autoFlow: autoFlow, placeItems: placeItems,
            alignSelf: alignSelf, justifySelf: justifySelf,
            condition: condition
        ))
    }

    // MARK: Position

    /// Apply CSS positioning.
    public func position(
        _ type: PositionType? = nil,
        top: SpacingValue? = nil,
        right: SpacingValue? = nil,
        bottom: SpacingValue? = nil,
        left: SpacingValue? = nil,
        inset: SpacingValue? = nil,
        zIndex: Int? = nil
    ) -> ModifiedContent<Self, PositionModifier> {
        modifier(PositionModifier(
            type: type, top: top, right: right, bottom: bottom,
            left: left, inset: inset, zIndex: zIndex
        ))
    }

    // MARK: Overflow

    /// Set overflow on both axes.
    public func overflow(_ value: OverflowValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, OverflowModifier> {
        modifier(OverflowModifier(both: value, condition: condition))
    }

    /// Set overflow independently on X and Y axes.
    public func overflow(x: OverflowValue? = nil, y: OverflowValue? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, OverflowModifier> {
        modifier(OverflowModifier(x: x, y: y, condition: condition))
    }

    // MARK: Display

    /// Set the CSS `display` property.
    public func display(_ value: DisplayValue, at condition: ModifierCondition? = nil) -> ModifiedContent<Self, DisplayModifier> {
        modifier(DisplayModifier(value, condition: condition))
    }

    /// Toggle CSS visibility.
    public func visibility(_ hidden: Bool, at condition: ModifierCondition? = nil) -> ModifiedContent<Self, VisibilityModifier> {
        modifier(VisibilityModifier(hidden: hidden, condition: condition))
    }
}
