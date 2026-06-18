// MARK: - Spacing scale

/// Resolve a spacing scale step to pixels.
///
/// The base unit is 4 px. Exact table entries are used first; arbitrary
/// values fall back to `step × 4`.
public func spacingPx(_ step: Double) -> Double {
    let table: [Double: Double] = [
        0: 0, 0.5: 2, 1: 4, 1.5: 6, 2: 8, 2.5: 10, 3: 12, 3.5: 14,
        4: 16, 5: 20, 6: 24, 7: 28, 8: 32, 9: 36, 10: 40, 11: 44,
        12: 48, 14: 56, 16: 64, 20: 80, 24: 96, 28: 112, 32: 128,
        36: 144, 40: 160, 44: 176, 48: 192, 52: 208, 56: 224,
        60: 240, 64: 256, 72: 288, 80: 320, 96: 384,
    ]
    return table[step] ?? step * 4
}

// MARK: - SpacingValue

/// A dimensional value for use in spacing, sizing, and layout modifiers.
public enum SpacingValue: Sendable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    case step(Double)
    case px(Double)
    case rem(Double)
    case percent(Double)
    case vw(Double)
    case vh(Double)
    case dvh(Double)
    case fr(Double)
    case auto
    case full
    case screen
    case min
    case max
    case fit
    case none

    public init(integerLiteral value: Int) { self = .step(Double(value)) }
    public init(floatLiteral value: Double) { self = .step(value) }

    /// CSS string representation for width/height contexts.
    public var css: String {
        switch self {
        case .step(let n): return "\(spacingPx(n).cssStr)px"
        case .px(let n): return "\(n.cssStr)px"
        case .rem(let n): return "\(n.cssStr)rem"
        case .percent(let n): return "\(n.cssStr)%"
        case .vw(let n): return "\(n.cssStr)vw"
        case .vh(let n): return "\(n.cssStr)vh"
        case .dvh(let n): return "\(n.cssStr)dvh"
        case .fr(let n): return "\(n.cssStr)fr"
        case .auto: return "auto"
        case .full: return "100%"
        case .screen: return "100vw"
        case .min: return "min-content"
        case .max: return "max-content"
        case .fit: return "fit-content"
        case .none: return "0"
        }
    }

    /// CSS string for height contexts (`.screen` maps to `100vh`).
    public var cssHeight: String {
        if case .screen = self { return "100vh" }
        return css
    }
}
