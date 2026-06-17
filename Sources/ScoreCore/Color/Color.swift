import Foundation

// MARK: - Color

/// A color stored internally in the OKLCh color space.
///
/// OKLCh is a perceptually uniform color space well-suited to interpolation,
/// lightening, darkening, and mixing. It maps directly to the CSS `oklch()`
/// function supported in all modern browsers.
///
/// ```swift
/// let primary = Color(hex: "#7C3AED")
/// let lighter = primary.lighten(0.1)
/// let css     = lighter.cssValue  // "oklch(0.6 0.22 293)"
/// ```
public struct Color: Sendable, Hashable, Equatable {

    // MARK: - Stored channels

    /// Lightness in 0…1 (0 = black, 1 = white).
    public let l: Double
    /// Chroma (saturation) — typically 0…0.4.
    public let c: Double
    /// Hue angle in degrees 0…360.
    public let h: Double
    /// Alpha transparency 0 (transparent) … 1 (opaque).
    public let alpha: Double
    /// When set, `cssValue` emits `var(--color-<tokenName>)` so the color responds
    /// to palette, dark-mode, and preset switches at runtime. Only semantic theme
    /// tokens (`.primary`, `.surface`, etc.) set this; raw palette colors do not.
    public let tokenName: String?

    // MARK: - Designated initialiser

    public init(oklch l: Double, _ c: Double, _ h: Double, alpha: Double = 1, tokenName: String? = nil) {
        self.l         = l
        self.c         = c
        self.h         = h
        self.alpha     = alpha
        self.tokenName = tokenName
    }

    // MARK: - RGB initialiser (0–1 per channel)

    public init(rgb r: Double, _ g: Double, _ b: Double, alpha: Double = 1) {
        let (l, c, h) = Self.rgbToOKLCh(r: r, g: g, b: b)
        self.l         = l
        self.c         = c
        self.h         = h
        self.alpha     = alpha
        self.tokenName = nil
    }

    // MARK: - HSL initialiser (h 0-360, s 0-100, l 0-100)

    public init(hsl hue: Double, _ saturation: Double, _ lightness: Double, alpha: Double = 1) {
        let (r, g, b) = Self.hslToRGB(h: hue, s: saturation / 100, l: lightness / 100)
        let (ol, oc, oh) = Self.rgbToOKLCh(r: r, g: g, b: b)
        self.l         = ol
        self.c         = oc
        self.h         = oh
        self.alpha     = alpha
        self.tokenName = nil
    }

    // MARK: - Hex initialiser

    /// Parse a 6-digit hex color string, with or without a leading `#`.
    public init(hex: String) {
        var s = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        // Expand 3-digit shorthand
        if s.count == 3 {
            s = s.map { "\($0)\($0)" }.joined()
        }
        guard s.count == 6,
              let value = UInt32(s, radix: 16) else {
            self.init(oklch: 0, 0, 0)
            return
        }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8)  & 0xFF) / 255.0
        let b = Double(value          & 0xFF) / 255.0
        self.init(rgb: r, g, b)
    }

    // MARK: - Mutations

    /// Return a new color with the given alpha.
    public func opacity(_ alpha: Double) -> Color {
        Color(oklch: l, c, h, alpha: alpha, tokenName: tokenName)
    }

    /// Increase the L channel by `amount` (clamped to 0…1).
    public func lighten(_ amount: Double) -> Color {
        Color(oklch: min(1, l + amount), c, h, alpha: alpha)
    }

    /// Decrease the L channel by `amount` (clamped to 0…1).
    public func darken(_ amount: Double) -> Color {
        Color(oklch: max(0, l - amount), c, h, alpha: alpha)
    }

    /// Linear interpolation in OKLCh space between `self` and `other`.
    ///
    /// `fraction = 0` returns `self`; `fraction = 1` returns `other`.
    public func mix(_ other: Color, by fraction: Double) -> Color {
        let t = max(0, min(1, fraction))
        // Hue interpolation: take the shortest arc
        let dh = ((other.h - h) + 540).truncatingRemainder(dividingBy: 360) - 180
        return Color(
            oklch: l + (other.l - l) * t,
                   c + (other.c - c) * t,
                   (h + dh * t).truncatingRemainder(dividingBy: 360),
            alpha: alpha + (other.alpha - alpha) * t
        )
    }

    // MARK: - CSS output

    /// Raw `oklch()` value, always a concrete color — used when defining CSS variables
    /// in `SiteTheme.cssVariables()`. Callers that write `--color-X: <value>` must use
    /// this to avoid circular `var()` references.
    public var rawCSSValue: String {
        let lStr = l.oklchStr
        let cStr = c.oklchStr
        let hStr = h.oklchStr
        if alpha >= 1 {
            return "oklch(\(lStr) \(cStr) \(hStr))"
        } else {
            return "oklch(\(lStr) \(cStr) \(hStr) / \(alpha.oklchStr))"
        }
    }

    /// CSS color reference. For semantic theme tokens (those with a `tokenName`) this
    /// emits `var(--color-X)` so the color responds to dark-mode and palette switches.
    /// For opacity-modified tokens it uses CSS relative color syntax:
    /// `oklch(from var(--color-X) l c h/alpha)`.
    /// For raw colors (no tokenName) it falls back to `rawCSSValue`.
    public var cssValue: String {
        guard let token = tokenName else { return rawCSSValue }
        if alpha >= 1 {
            return "var(--color-\(token))"
        }
        return "oklch(from var(--color-\(token)) l c h/\(alpha.oklchStr))"
    }

    // MARK: - Private: Color conversions

    // sRGB → linear sRGB
    private static func linearize(_ c: Double) -> Double {
        c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    // Linear sRGB → OKLab
    private static func linearSRGBToOKLab(r: Double, g: Double, b: Double) -> (Double, Double, Double) {
        // XYZ-D65 from linear sRGB (IEC 61966-2-1)
        let x = 0.4124564 * r + 0.3575761 * g + 0.1804375 * b
        let y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b
        let z = 0.0193339 * r + 0.1191920 * g + 0.9503041 * b

        // XYZ → LMS (Oklab M1)
        let l_ = pow(max(0,  0.8189330101 * x + 0.3618667424 * y - 0.1288597137 * z), 1.0/3.0)
        let m_ = pow(max(0,  0.0329845436 * x + 0.9293118715 * y + 0.0361456387 * z), 1.0/3.0)
        let s_ = pow(max(0,  0.0482003018 * x + 0.2643662691 * y + 0.6338517070 * z), 1.0/3.0)

        // LMS → OKLab (Oklab M2)
        let L  =  0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
        let a  =  1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
        let bv = -0.0259040371 * l_ + 0.7827717662 * m_ - 0.8068767776 * s_
        return (L, a, bv)
    }

    // RGB [0,1] → OKLCh
    static func rgbToOKLCh(r: Double, g: Double, b: Double) -> (Double, Double, Double) {
        let lr = linearize(r)
        let lg = linearize(g)
        let lb = linearize(b)
        let (L, a, bv) = linearSRGBToOKLab(r: lr, g: lg, b: lb)
        let C = sqrt(a * a + bv * bv)
        var H = atan2(bv, a) * 180 / .pi
        if H < 0 { H += 360 }
        return (L, C, H)
    }

    // HSL → RGB [0,1]
    private static func hslToRGB(h: Double, s: Double, l: Double) -> (Double, Double, Double) {
        if s == 0 { return (l, l, l) }
        func hue2rgb(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var t = t
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1/6 { return p + (q - p) * 6 * t }
            if t < 1/2 { return q }
            if t < 2/3 { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        let r = hue2rgb(p, q, h / 360 + 1/3)
        let g = hue2rgb(p, q, h / 360)
        let b = hue2rgb(p, q, h / 360 - 1/3)
        return (r, g, b)
    }
}

// MARK: - Double formatting helper

private extension Double {
    /// Format for CSS oklch values — max 4 significant digits, no trailing zeros.
    var oklchStr: String {
        if self == self.rounded() { return String(Int(self)) }
        return String(format: "%g", (self * 10000).rounded() / 10000)
    }
}
