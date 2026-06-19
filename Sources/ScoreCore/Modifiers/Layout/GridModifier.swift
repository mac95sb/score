// MARK: - GridModifier

/// A modifier that applies CSS Grid properties to an element.
///
/// Use ``View/grid(columns:rows:gap:columnGap:rowGap:span:rowSpan:spanFull:area:autoFlow:placeItems:alignSelf:justifySelf:at:)``
/// rather than constructing `GridModifier` directly.
///
/// ```swift
/// HStack {
///     Card { "One" }.gridItem(span: 2)
///     Card { "Two" }
///     Card { "Three" }
/// }
/// .grid(columns: 3, gap: 6)
/// .grid(columns: 1, at: .mobile)
/// ```
///
/// - SeeAlso: ``View/grid(columns:rows:gap:columnGap:rowGap:span:rowSpan:spanFull:area:autoFlow:placeItems:alignSelf:justifySelf:at:)``, ``FlexModifier``
public struct GridModifier: ThemeAwareModifier {
    let columns: Int?
    let columnsTemplate: String?
    let rows: String?
    let gap: SpacingValue?
    let columnGap: SpacingValue?
    let rowGap: SpacingValue?
    let span: Int?
    let rowSpan: Int?
    let spanFull: Bool?
    let area: String?
    let autoFlow: GridAutoFlow?
    let autoColumns: SpacingValue?
    let autoRows: SpacingValue?
    let placeItems: String?
    let alignSelf: String?
    let justifySelf: String?
    let condition: ModifierCondition?

    public init(
        columns: Int? = nil,
        columnsTemplate: String? = nil,
        rows: String? = nil,
        gap: SpacingValue? = nil,
        columnGap: SpacingValue? = nil,
        rowGap: SpacingValue? = nil,
        span: Int? = nil,
        rowSpan: Int? = nil,
        spanFull: Bool? = nil,
        area: String? = nil,
        autoFlow: GridAutoFlow? = nil,
        autoColumns: SpacingValue? = nil,
        autoRows: SpacingValue? = nil,
        placeItems: String? = nil,
        alignSelf: String? = nil,
        justifySelf: String? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.columns = columns
        self.columnsTemplate = columnsTemplate
        self.rows = rows
        self.gap = gap
        self.columnGap = columnGap
        self.rowGap = rowGap
        self.span = span
        self.rowSpan = rowSpan
        self.spanFull = spanFull
        self.area = area
        self.autoFlow = autoFlow
        self.autoColumns = autoColumns
        self.autoRows = autoRows
        self.placeItems = placeItems
        self.alignSelf = alignSelf
        self.justifySelf = justifySelf
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []

        // Container properties → emit display:grid
        let isContainer =
            columns != nil || columnsTemplate != nil || rows != nil || gap != nil || columnGap != nil || rowGap != nil || autoFlow != nil || autoColumns != nil || autoRows != nil
            || placeItems != nil
        if isContainer {
            result.append(ConditionedDeclaration("display", "grid", condition: condition))
        }

        // Template columns
        if let ct = columnsTemplate {
            result.append(ConditionedDeclaration("grid-template-columns", ct, condition: condition))
        } else if let c = columns {
            result.append(ConditionedDeclaration("grid-template-columns", "repeat(\(c),minmax(0,1fr))", condition: condition))
        }

        if let r = rows { result.append(ConditionedDeclaration("grid-template-rows", r, condition: condition)) }
        if let g = gap { result.append(ConditionedDeclaration("gap", g.css, condition: condition)) }
        if let cg = columnGap { result.append(ConditionedDeclaration("column-gap", cg.css, condition: condition)) }
        if let rg = rowGap { result.append(ConditionedDeclaration("row-gap", rg.css, condition: condition)) }
        if let af = autoFlow { result.append(ConditionedDeclaration("grid-auto-flow", af.rawValue, condition: condition)) }
        if let ac = autoColumns { result.append(ConditionedDeclaration("grid-auto-columns", ac.css, condition: condition)) }
        if let ar = autoRows { result.append(ConditionedDeclaration("grid-auto-rows", ar.css, condition: condition)) }
        if let pi = placeItems { result.append(ConditionedDeclaration("place-items", pi, condition: condition)) }

        // Item/child properties
        if let sf = spanFull, sf {
            result.append(ConditionedDeclaration("grid-column", "1/-1", condition: condition))
        } else if let s = span {
            result.append(ConditionedDeclaration("grid-column", "span \(s)/span \(s)", condition: condition))
        }
        if let rs = rowSpan { result.append(ConditionedDeclaration("grid-row", "span \(rs)/span \(rs)", condition: condition)) }
        if let a = area { result.append(ConditionedDeclaration("grid-area", a, condition: condition)) }
        if let as_ = alignSelf { result.append(ConditionedDeclaration("align-self", as_, condition: condition)) }
        if let js = justifySelf { result.append(ConditionedDeclaration("justify-self", js, condition: condition)) }

        return result
    }
}
