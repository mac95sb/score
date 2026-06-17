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
