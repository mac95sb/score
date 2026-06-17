// MARK: - Flex values

public enum FlexDirection: String, Sendable {
    case horizontal         = "row"
    case vertical           = "column"
    case horizontalReversed = "row-reverse"
    case verticalReversed   = "column-reverse"
}

public enum FlexAlignment: String, Sendable {
    case start        = "flex-start"
    case end          = "flex-end"
    case center
    case stretch
    case baseline
    case spaceBetween = "space-between"
    case spaceAround  = "space-around"
    case spaceEvenly  = "space-evenly"
}

public enum FlexWrap: String, Sendable {
    case wrap, nowrap, wrapReverse = "wrap-reverse"
}

public enum FlexOrder: Sendable {
    case first          // order: -9999
    case last           // order:  9999
    case custom(Int)

    public var css: String {
        switch self {
        case .first:         return "-9999"
        case .last:          return "9999"
        case .custom(let n): return "\(n)"
        }
    }
}

// MARK: - Grid values

public enum GridAutoFlow: String, Sendable {
    case row, column, rowDense = "row dense", columnDense = "column dense"
}

// MARK: - Position

public enum PositionType: String, Sendable {
    case `static`, relative, absolute, fixed, sticky
}

// MARK: - Overflow

public enum OverflowValue: String, Sendable {
    case visible, hidden, scroll, auto, clip
}

// MARK: - Display

public enum DisplayValue: String, Sendable {
    case none
    case block
    case inline
    case inlineBlock   = "inline-block"
    case flex
    case inlineFlex    = "inline-flex"
    case grid
    case inlineGrid    = "inline-grid"
    case contents
    case table
    case listItem      = "list-item"
}

// MARK: - Cursor

public enum CursorValue: String, Sendable {
    case auto, `default`, pointer, wait, text, move, help
    case notAllowed = "not-allowed"
    case crosshair, grab, grabbing
    case zoomIn     = "zoom-in"
    case zoomOut    = "zoom-out"
    case noDrop     = "no-drop"
    case none
}

// MARK: - Object Fit

public enum ObjectFit: String, Sendable {
    case fill, contain, cover, none, scaleDown = "scale-down"
}

// MARK: - User Select

public enum UserSelect: String, Sendable {
    case none, text, all, auto
}
