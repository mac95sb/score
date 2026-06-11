import Foundation

// MARK: - SiteTheme

/// The complete visual design system for a Score application.
///
/// Override in your ``Application`` conformance to customise colours, fonts, spacing, and more.
public struct SiteTheme: Sendable {
    public var colors: ThemeColors
    public var fonts: ThemeFonts
    public var spacing: ThemeSpacing
    public var radii: ThemeRadii
    public var shadows: ThemeShadows
    public var breakpoints: ThemeBreakpoints
    public var syntaxTheme: any SyntaxTheme
    public var darkColors: ThemeColors?
    public var customThemes: [String: ThemeColors]
    public var tokens: [ThemeToken]

    public static let `default` = SiteTheme()

    public init(
        colors: ThemeColors = .default,
        fonts: ThemeFonts = .default,
        spacing: ThemeSpacing = .default,
        radii: ThemeRadii = .default,
        shadows: ThemeShadows = .default,
        breakpoints: ThemeBreakpoints = .default,
        syntaxTheme: any SyntaxTheme = ScoreDarkSyntaxTheme(),
        darkColors: ThemeColors? = nil,
        customThemes: [String: ThemeColors] = [:],
        tokens: [ThemeToken] = []
    ) {
        self.colors       = colors
        self.fonts        = fonts
        self.spacing      = spacing
        self.radii        = radii
        self.shadows      = shadows
        self.breakpoints  = breakpoints
        self.syntaxTheme  = syntaxTheme
        self.darkColors   = darkColors
        self.customThemes = customThemes
        self.tokens       = tokens
    }

    // MARK: - CSS variable emission

    /// Emit all CSS custom properties for this theme as a `<style>` block string.
    public func cssVariables() -> String {
        var out = ":root {"
        // Color tokens
        out += "--color-primary:\(colors.primary.cssValue);"
        out += "--color-accent:\(colors.accent.cssValue);"
        out += "--color-surface:\(colors.surface.cssValue);"
        out += "--color-secondary:\(colors.secondary.cssValue);"
        out += "--color-tertiary:\(colors.tertiary.cssValue);"
        out += "--color-text:\(colors.text.cssValue);"
        out += "--color-muted:\(colors.muted.cssValue);"
        out += "--color-destructive:\(colors.destructive.cssValue);"
        // Shadow tokens
        out += "--shadow-sm:\(shadows.sm);"
        out += "--shadow-md:\(shadows.md);"
        out += "--shadow-lg:\(shadows.lg);"
        out += "--shadow-xl:\(shadows.xl);"
        out += "--shadow-2xl:\(shadows.twoXL);"
        out += "--shadow-inner:\(shadows.inner);"
        // Radius tokens
        out += "--radius-sm:\(radii.sm.cssStr)px;"
        out += "--radius-md:\(radii.md.cssStr)px;"
        out += "--radius-lg:\(radii.lg.cssStr)px;"
        out += "--radius-xl:\(radii.xl.cssStr)px;"
        out += "--radius-2xl:\(radii.twoXL.cssStr)px;"
        out += "--radius-full:\(radii.full.cssStr)px;"
        // Custom tokens
        for token in tokens {
            out += "\(token.name):\(token.value);"
        }
        out += "}"

        // Dark mode — media-query variant
        if let dark = darkColors {
            out += "@media(prefers-color-scheme:dark){:root{"
            out += "--color-primary:\(dark.primary.cssValue);"
            out += "--color-accent:\(dark.accent.cssValue);"
            out += "--color-surface:\(dark.surface.cssValue);"
            out += "--color-secondary:\(dark.secondary.cssValue);"
            out += "--color-tertiary:\(dark.tertiary.cssValue);"
            out += "--color-text:\(dark.text.cssValue);"
            out += "--color-muted:\(dark.muted.cssValue);"
            out += "--color-destructive:\(dark.destructive.cssValue);"
            out += "}}"
            // Manual dark-mode toggle via data attribute
            out += "[data-theme=\"dark\"]{--color-primary:\(dark.primary.cssValue);"
            out += "--color-accent:\(dark.accent.cssValue);"
            out += "--color-surface:\(dark.surface.cssValue);"
            out += "--color-secondary:\(dark.secondary.cssValue);"
            out += "--color-tertiary:\(dark.tertiary.cssValue);"
            out += "--color-text:\(dark.text.cssValue);"
            out += "--color-muted:\(dark.muted.cssValue);"
            out += "--color-destructive:\(dark.destructive.cssValue);}"
        }

        // Custom named themes
        for (themeName, themeColors) in customThemes {
            out += "[data-theme=\"\(themeName)\"]{--color-primary:\(themeColors.primary.cssValue);"
            out += "--color-accent:\(themeColors.accent.cssValue);"
            out += "--color-surface:\(themeColors.surface.cssValue);"
            out += "--color-secondary:\(themeColors.secondary.cssValue);"
            out += "--color-tertiary:\(themeColors.tertiary.cssValue);"
            out += "--color-text:\(themeColors.text.cssValue);"
            out += "--color-muted:\(themeColors.muted.cssValue);"
            out += "--color-destructive:\(themeColors.destructive.cssValue);}"
        }

        return out
    }
}

// MARK: - ThemeColors

public struct ThemeColors: Sendable {
    public var primary: Color
    public var accent: Color
    public var surface: Color
    public var secondary: Color
    public var tertiary: Color
    public var text: Color
    public var muted: Color
    public var destructive: Color

    public static let `default` = ThemeColors(
        primary:     .violet(600),
        accent:      .emerald(400),
        surface:     Color(oklch: 1.0, 0, 0),
        secondary:   .slate(100),
        tertiary:    .slate(50),
        text:        .slate(900),
        muted:       .slate(500),
        destructive: .rose(600)
    )

    public init(
        primary: Color,
        accent: Color,
        surface: Color,
        secondary: Color,
        tertiary: Color,
        text: Color,
        muted: Color,
        destructive: Color
    ) {
        self.primary     = primary
        self.accent      = accent
        self.surface     = surface
        self.secondary   = secondary
        self.tertiary    = tertiary
        self.text        = text
        self.muted       = muted
        self.destructive = destructive
    }
}

// MARK: - ThemeFonts

public struct ThemeFonts: Sendable {
    public var body: FontFamily
    public var heading: FontFamily
    public var mono: FontFamily

    public static let `default` = ThemeFonts(body: .system, heading: .system, mono: .system)

    public init(body: FontFamily, heading: FontFamily, mono: FontFamily) {
        self.body = body; self.heading = heading; self.mono = mono
    }
}

// MARK: - FontFamily

public enum FontFamily: Sendable {
    case system
    case custom(String, url: String? = nil)

    public var css: String {
        switch self {
        case .system:
            return "system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif"
        case .custom(let name, _):
            return "'\(name)',system-ui,sans-serif"
        }
    }

    /// The mono-spaced system font stack.
    public static var systemMono: FontFamily {
        .custom("ui-monospace,SFMono-Regular,'SF Mono',Consolas,'Liberation Mono',Menlo,monospace")
    }
}

// MARK: - ThemeSpacing

public struct ThemeSpacing: Sendable {
    public var base: Double
    public var multiplier: Double

    public static let `default` = ThemeSpacing(base: 4, multiplier: 1.0)

    public init(base: Double, multiplier: Double) {
        self.base = base; self.multiplier = multiplier
    }

    public func px(for step: Double) -> Double {
        spacingPx(step) * multiplier
    }
}

// MARK: - ThemeRadii

public struct ThemeRadii: Sendable {
    public var sm: Double
    public var md: Double
    public var lg: Double
    public var xl: Double
    public var twoXL: Double
    public var full: Double

    public static let `default` = ThemeRadii(sm: 4, md: 8, lg: 12, xl: 16, twoXL: 24, full: 9999)

    public init(sm: Double, md: Double, lg: Double, xl: Double, twoXL: Double, full: Double) {
        self.sm = sm; self.md = md; self.lg = lg
        self.xl = xl; self.twoXL = twoXL; self.full = full
    }

    public subscript(token: RadiusToken) -> Double {
        switch token {
        case .sm:    return sm
        case .md:    return md
        case .lg:    return lg
        case .xl:    return xl
        case .twoXL: return twoXL
        case .full:  return full
        }
    }
}

// MARK: - ThemeShadows

public struct ThemeShadows: Sendable {
    public var sm: String
    public var md: String
    public var lg: String
    public var xl: String
    public var twoXL: String
    public var inner: String

    public static let `default` = ThemeShadows(
        sm:    "0 1px 2px oklch(0 0 0/0.05)",
        md:    "0 4px 6px oklch(0 0 0/0.07)",
        lg:    "0 10px 15px oklch(0 0 0/0.1)",
        xl:    "0 20px 25px oklch(0 0 0/0.1)",
        twoXL: "0 25px 50px oklch(0 0 0/0.25)",
        inner: "inset 0 2px 4px oklch(0 0 0/0.06)"
    )

    public init(sm: String, md: String, lg: String, xl: String, twoXL: String, inner: String) {
        self.sm = sm; self.md = md; self.lg = lg
        self.xl = xl; self.twoXL = twoXL; self.inner = inner
    }
}

// MARK: - ThemeBreakpoints

public struct ThemeBreakpoints: Sendable {
    public var phone: Int
    public var tablet: Int
    public var desktop: Int
    public var wide: Int
    public var ultrawide: Int

    public static let `default` = ThemeBreakpoints(
        phone: 480, tablet: 768, desktop: 1024, wide: 1280, ultrawide: 1536
    )

    public init(phone: Int, tablet: Int, desktop: Int, wide: Int, ultrawide: Int) {
        self.phone = phone; self.tablet = tablet; self.desktop = desktop
        self.wide = wide; self.ultrawide = ultrawide
    }

    public func minWidth(for breakpoint: Breakpoint) -> Int {
        switch breakpoint {
        case .phone:      return phone
        case .tablet:     return tablet
        case .desktop:    return desktop
        case .wide:       return wide
        case .ultrawide:  return ultrawide
        }
    }
}

// MARK: - Supporting enums / types

public enum Breakpoint: String, Sendable {
    case phone, tablet, desktop, wide, ultrawide
}

public struct ThemeToken: Sendable {
    public let name: String
    public let value: String
    public init(_ name: String, _ value: String) {
        self.name = name; self.value = value
    }
}

public enum RadiusToken: String, Sendable {
    case sm, md, lg, xl, twoXL, full

    public var cssName: String {
        switch self {
        case .twoXL: return "2xl"
        default:     return rawValue
        }
    }
}

