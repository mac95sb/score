import Foundation

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
        60: 240, 64: 256, 72: 288, 80: 320, 96: 384
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

    public init(integerLiteral value: Int)    { self = .step(Double(value)) }
    public init(floatLiteral value: Double)   { self = .step(value) }

    /// CSS string representation for width/height contexts.
    public var css: String {
        switch self {
        case .step(let n):    return "\(spacingPx(n).cssStr)px"
        case .px(let n):      return "\(n.cssStr)px"
        case .rem(let n):     return "\(n.cssStr)rem"
        case .percent(let n): return "\(n.cssStr)%"
        case .vw(let n):      return "\(n.cssStr)vw"
        case .vh(let n):      return "\(n.cssStr)vh"
        case .dvh(let n):     return "\(n.cssStr)dvh"
        case .fr(let n):      return "\(n.cssStr)fr"
        case .auto:           return "auto"
        case .full:           return "100%"
        case .screen:         return "100vw"
        case .min:            return "min-content"
        case .max:            return "max-content"
        case .fit:            return "fit-content"
        case .none:           return "0"
        }
    }

    /// CSS string for height contexts (`.screen` maps to `100vh`).
    public var cssHeight: String {
        if case .screen = self { return "100vh" }
        return css
    }
}

// MARK: - FontSize

public enum FontSize: Sendable {
    case xs        // 12 px
    case sm        // 14 px
    case base      // 16 px
    case lg        // 18 px
    case xl        // 20 px
    case twoXL     // 24 px
    case threeXL   // 30 px
    case fourXL    // 36 px
    case fiveXL    // 48 px
    case sixXL     // 60 px
    case sevenXL   // 72 px
    case px(Double)

    public var css: String {
        switch self {
        case .xs:      return "12px"
        case .sm:      return "14px"
        case .base:    return "16px"
        case .lg:      return "18px"
        case .xl:      return "20px"
        case .twoXL:   return "24px"
        case .threeXL: return "30px"
        case .fourXL:  return "36px"
        case .fiveXL:  return "48px"
        case .sixXL:   return "60px"
        case .sevenXL: return "72px"
        case .px(let n): return "\(n.cssStr)px"
        }
    }
}

// MARK: - FontWeight

public enum FontWeight: Int, Sendable {
    case thin       = 100
    case extraLight = 200
    case light      = 300
    case regular    = 400
    case medium     = 500
    case semibold   = 600
    case bold       = 700
    case extraBold  = 800
    case black      = 900

    public var css: String { "\(rawValue)" }
}

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
        case .first:       return "-9999"
        case .last:        return "9999"
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

// MARK: - Text Transform

public enum TextTransform: String, Sendable {
    case none, uppercase, lowercase, capitalize
}

// MARK: - Text Decoration

public enum TextDecoration: String, Sendable {
    case none, underline, overline, lineThrough = "line-through"
}

// MARK: - Font Style

public enum FontStyle: String, Sendable {
    case normal, italic, oblique
}

// MARK: - Line Height (Leading)

public enum LineHeight: Sendable {
    case none           // 1
    case tight          // 1.25
    case snug           // 1.375
    case normal         // 1.5
    case relaxed        // 1.625
    case loose          // 2
    case custom(Double)

    public var css: String {
        switch self {
        case .none:          return "1"
        case .tight:         return "1.25"
        case .snug:          return "1.375"
        case .normal:        return "1.5"
        case .relaxed:       return "1.625"
        case .loose:         return "2"
        case .custom(let n): return n.cssStr
        }
    }
}

// MARK: - Letter Spacing (Tracking)

public enum LetterSpacing: Sendable {
    case tighter        // -0.05em
    case tight          // -0.025em
    case normal         // 0
    case wide           // 0.025em
    case wider          // 0.05em
    case widest         // 0.1em
    case custom(Double)

    public var css: String {
        switch self {
        case .tighter:       return "-0.05em"
        case .tight:         return "-0.025em"
        case .normal:        return "0"
        case .wide:          return "0.025em"
        case .wider:         return "0.05em"
        case .widest:        return "0.1em"
        case .custom(let n): return "\(n)em"
        }
    }
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
    case noWrap   = "nowrap"
    case pre
    case preLine  = "pre-line"
    case preWrap  = "pre-wrap"
}

// MARK: - Word Break

public enum WordBreak: String, Sendable {
    case normal
    case breakAll = "break-all"
    case keepAll  = "keep-all"
}

// MARK: - Blend Mode

public enum BlendMode: String, Sendable {
    case normal, multiply, screen, overlay, darken, lighten
    case colorDodge = "color-dodge"
    case colorBurn  = "color-burn"
    case hardLight  = "hard-light"
    case softLight  = "soft-light"
    case difference, exclusion, hue, saturation, color, luminosity
}

// MARK: - Background Size

public enum BackgroundSize: Sendable {
    case cover, contain, auto
    case custom(String)

    public var css: String {
        switch self {
        case .cover:         return "cover"
        case .contain:       return "contain"
        case .auto:          return "auto"
        case .custom(let s): return s
        }
    }
}

// MARK: - Background Position

public enum BackgroundPosition: String, Sendable {
    case center, top, bottom, left, right
    case topLeft     = "top left"
    case topRight    = "top right"
    case bottomLeft  = "bottom left"
    case bottomRight = "bottom right"
}

// MARK: - Background Clip

public enum BackgroundClip: String, Sendable {
    case text
    case border  = "border-box"
    case padding = "padding-box"
    case content = "content-box"
}

// MARK: - Border Style

public enum BorderStyle: String, Sendable {
    case solid, dashed, dotted, double, none
}

// MARK: - Edge

public enum Edge: Sendable {
    case top, right, bottom, left
    case x  // horizontal (left + right)
    case y  // vertical (top + bottom)
}

// MARK: - Transform Origin

public enum TransformOrigin: Sendable {
    case center, top, bottom, left, right
    case topLeft, topRight, bottomLeft, bottomRight
    case custom(SpacingValue, SpacingValue)

    public var css: String {
        switch self {
        case .center:      return "center"
        case .top:         return "top"
        case .bottom:      return "bottom"
        case .left:        return "left"
        case .right:       return "right"
        case .topLeft:     return "top left"
        case .topRight:    return "top right"
        case .bottomLeft:  return "bottom left"
        case .bottomRight: return "bottom right"
        case .custom(let x, let y): return "\(x.css) \(y.css)"
        }
    }
}

// MARK: - Shadow Token

public enum ShadowToken: Sendable {
    case sm, md, lg, xl, twoXL, inner, none
    case custom(String)

    public func css(theme: SiteTheme) -> String {
        switch self {
        case .sm:            return theme.shadows.sm
        case .md:            return theme.shadows.md
        case .lg:            return theme.shadows.lg
        case .xl:            return theme.shadows.xl
        case .twoXL:         return theme.shadows.twoXL
        case .inner:         return theme.shadows.inner
        case .none:          return "none"
        case .custom(let s): return s
        }
    }
}

// MARK: - User Select

public enum UserSelect: String, Sendable {
    case none, text, all, auto
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

// MARK: - Animation helpers

public struct AnimationDuration: Sendable {
    public let ms: Int
    public init(_ ms: Int) { self.ms = ms }
    public var css: String { "\(ms)ms" }
}

extension Int {
    public var ms: AnimationDuration { AnimationDuration(self) }
}

extension Double {
    public var ms: AnimationDuration { AnimationDuration(Int(self)) }
}

public enum AnimationTiming: Sendable {
    case linear
    case ease
    case easeIn
    case easeOut
    case easeInOut
    case custom(String)

    public var css: String {
        switch self {
        case .linear:         return "linear"
        case .ease:           return "ease"
        case .easeIn:         return "ease-in"
        case .easeOut:        return "ease-out"
        case .easeInOut:      return "ease-in-out"
        case .custom(let s):  return s
        }
    }
}

public struct AnimationIterations: Sendable {
    let value: String
    public static let infinite = AnimationIterations(value: "infinite")
    public static func times(_ n: Int) -> AnimationIterations { AnimationIterations(value: "\(n)") }
    public static let once = times(1)
    public var css: String { value }
}

public enum Animation: Sendable {
    case none
    case spin
    case ping
    case pulse
    case bounce
    case fadeIn
    case fadeOut
    case slideInLeft
    case slideInRight
    case slideInUp
    case slideInDown
    case custom(String)

    public var css: String {
        switch self {
        case .none:        return "none"
        case .spin:        return "spin"
        case .ping:        return "ping"
        case .pulse:       return "pulse"
        case .bounce:      return "bounce"
        case .fadeIn:      return "fade-in"
        case .fadeOut:     return "fade-out"
        case .slideInLeft: return "slide-in-left"
        case .slideInRight: return "slide-in-right"
        case .slideInUp:   return "slide-in-up"
        case .slideInDown: return "slide-in-down"
        case .custom(let s): return s
        }
    }
}

public enum TransitionProperty: Sendable {
    case all
    case transform
    case opacity
    case color
    case backgroundColor
    case border
    case shadow
    case filter
    case custom(String)

    public var css: String {
        switch self {
        case .all:             return "all"
        case .transform:       return "transform"
        case .opacity:         return "opacity"
        case .color:           return "color"
        case .backgroundColor: return "background-color"
        case .border:          return "border"
        case .shadow:          return "box-shadow"
        case .filter:          return "filter"
        case .custom(let s):   return s
        }
    }
}

// MARK: - Gradient

public struct Gradient: Sendable {
    let cssString: String

    public static func linear(from: Color, to: Color, angle: Double = 180) -> Gradient {
        Gradient(cssString: "linear-gradient(\(angle.cssStr)deg,\(from.cssValue),\(to.cssValue))")
    }

    public static func radial(from: Color, to: Color) -> Gradient {
        Gradient(cssString: "radial-gradient(circle,\(from.cssValue),\(to.cssValue))")
    }

    public static func linearMulti(angle: Double = 180, stops: [(Color, Double)]) -> Gradient {
        let stopStr = stops.map { "\($0.0.cssValue) \($0.1.cssStr)%" }.joined(separator: ",")
        return Gradient(cssString: "linear-gradient(\(angle.cssStr)deg,\(stopStr))")
    }

    public var css: String { cssString }
}

// MARK: - Double / Int CSS helpers

extension Double {
    public var cssStr: String {
        if self == self.rounded() && !self.isInfinite { return String(Int(self)) }
        return String(format: "%g", self)
    }
}

extension Int {
    public var cssStr: String { "\(self)" }
}
