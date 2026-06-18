// MARK: - FontSize

public enum FontSize: Sendable {
    case xs  // 12 px
    case sm  // 14 px
    case base  // 16 px
    case lg  // 18 px
    case xl  // 20 px
    case twoXL  // 24 px
    case threeXL  // 30 px
    case fourXL  // 36 px
    case fiveXL  // 48 px
    case sixXL  // 60 px
    case sevenXL  // 72 px
    case px(Double)

    public var css: String {
        switch self {
        case .xs: return "12px"
        case .sm: return "14px"
        case .base: return "16px"
        case .lg: return "18px"
        case .xl: return "20px"
        case .twoXL: return "24px"
        case .threeXL: return "30px"
        case .fourXL: return "36px"
        case .fiveXL: return "48px"
        case .sixXL: return "60px"
        case .sevenXL: return "72px"
        case .px(let n): return "\(n.cssStr)px"
        }
    }
}

// MARK: - FontWeight

public enum FontWeight: Int, Sendable {
    case thin = 100
    case extraLight = 200
    case light = 300
    case regular = 400
    case medium = 500
    case semibold = 600
    case bold = 700
    case extraBold = 800
    case black = 900

    public var css: String { "\(rawValue)" }
}

// MARK: - FontStyle

public enum FontStyle: String, Sendable {
    case normal, italic, oblique
}

// MARK: - Text Transform

public enum TextTransform: String, Sendable {
    case none, uppercase, lowercase, capitalize
}

// MARK: - Text Decoration

public enum TextDecoration: String, Sendable {
    case none, underline, overline
    case lineThrough = "line-through"
}

// MARK: - Text Align

public enum TextAlign: String, Sendable {
    case start, end, left, right, center, justify
}

// MARK: - Text Wrap

public enum TextWrap: String, Sendable {
    case wrap, nowrap, balance, pretty
}

// MARK: - Whitespace

public enum WhiteSpace: String, Sendable {
    case normal
    case noWrap = "nowrap"
    case pre
    case preLine = "pre-line"
    case preWrap = "pre-wrap"
}

// MARK: - Word Break

public enum WordBreak: String, Sendable {
    case normal
    case breakAll = "break-all"
    case keepAll = "keep-all"
}

// MARK: - Line Height (Leading)

public enum LineHeight: Sendable {
    case none  // 1
    case tight  // 1.25
    case snug  // 1.375
    case normal  // 1.5
    case relaxed  // 1.625
    case loose  // 2
    case custom(Double)

    public var css: String {
        switch self {
        case .none: return "1"
        case .tight: return "1.25"
        case .snug: return "1.375"
        case .normal: return "1.5"
        case .relaxed: return "1.625"
        case .loose: return "2"
        case .custom(let n): return n.cssStr
        }
    }
}

// MARK: - Letter Spacing (Tracking)

public enum LetterSpacing: Sendable {
    case tighter  // -0.05em
    case tight  // -0.025em
    case normal  // 0
    case wide  // 0.025em
    case wider  // 0.05em
    case widest  // 0.1em
    case custom(Double)

    public var css: String {
        switch self {
        case .tighter: return "-0.05em"
        case .tight: return "-0.025em"
        case .normal: return "0"
        case .wide: return "0.025em"
        case .wider: return "0.05em"
        case .widest: return "0.1em"
        case .custom(let n): return "\(n)em"
        }
    }
}

// MARK: - Font helpers

public enum DecorationStyle: String, Sendable {
    case solid, double, dotted, dashed, wavy
}

public enum FontVariant: String, Sendable {
    case normal
    case smallCaps = "small-caps"
}

public enum FontSmoothing: String, Sendable {
    case auto
    case antialiased
    case subpixel = "subpixel-antialiased"
}
