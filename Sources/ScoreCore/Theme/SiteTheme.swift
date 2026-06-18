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
    /// Palette overrides keyed by name. Set `data-palette="<key>"` on `<html>`
    /// at runtime to swap the colour tokens while leaving radii and shadows
    /// unchanged. Populate from ``ThemePalette`` light variants:
    ///
    /// ```swift
    /// t.customPalettes = [
    ///     "forest":   ThemePalette.forest.light,
    ///     "sunset":   ThemePalette.sunset.light,
    /// ]
    /// ```
    public var customPalettes: [String: ThemeColors]
    /// Preset shape overrides keyed by name. Set `data-preset="<key>"` on `<html>`
    /// at runtime to swap the radius and shadow tokens while leaving colours and
    /// component variant classes unchanged. Populate from ``ThemePreset/presetOverride``:
    ///
    /// ```swift
    /// t.customPresets = Dictionary(uniqueKeysWithValues:
    ///     ThemePreset.allCases.map { ($0.rawValue, $0.presetOverride) }
    /// )
    /// ```
    public var customPresets: [String: PresetOverride]
    public var components: ComponentTheme

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
        customPalettes: [String: ThemeColors] = [:],
        customPresets: [String: PresetOverride] = [:],
        components: ComponentTheme = .none
    ) {
        self.colors = colors
        self.fonts = fonts
        self.spacing = spacing
        self.radii = radii
        self.shadows = shadows
        self.breakpoints = breakpoints
        self.syntaxTheme = syntaxTheme
        self.darkColors = darkColors
        self.customThemes = customThemes
        self.customPalettes = customPalettes
        self.customPresets = customPresets
        self.components = components
    }

    // MARK: - CSS variable emission

    /// Emit all CSS custom properties for this theme as a `<style>` block string.
    public func cssVariables() -> String {
        var out = ":root {"
        // Color tokens — must use rawCSSValue to avoid circular var() references.
        out += "--color-primary:\(colors.primary.rawCSSValue);"
        out += "--color-accent:\(colors.accent.rawCSSValue);"
        out += "--color-surface:\(colors.surface.rawCSSValue);"
        out += "--color-secondary:\(colors.secondary.rawCSSValue);"
        out += "--color-tertiary:\(colors.tertiary.rawCSSValue);"
        out += "--color-text:\(colors.text.rawCSSValue);"
        out += "--color-muted:\(colors.muted.rawCSSValue);"
        out += "--color-destructive:\(colors.destructive.rawCSSValue);"
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
        out += "}"

        // @font-face rules for self-hosted custom fonts
        for family in [fonts.body, fonts.heading, fonts.mono] {
            if case .custom(let name, let url?, _) = family,
                url.hasSuffix(".woff2") || url.hasSuffix(".woff") || url.hasSuffix(".ttf") || url.hasSuffix(".otf")
            {
                out += "@font-face{font-family:'\(name)';src:url('\(url)') format('woff2');font-display:swap;}"
            }
        }

        // Dark mode — OS system preference (lowest priority of the dark-mode rules).
        if let dark = darkColors {
            out += "@media(prefers-color-scheme:dark){:root{"
            out += "--color-primary:\(dark.primary.rawCSSValue);"
            out += "--color-accent:\(dark.accent.rawCSSValue);"
            out += "--color-surface:\(dark.surface.rawCSSValue);"
            out += "--color-secondary:\(dark.secondary.rawCSSValue);"
            out += "--color-tertiary:\(dark.tertiary.rawCSSValue);"
            out += "--color-text:\(dark.text.rawCSSValue);"
            out += "--color-muted:\(dark.muted.rawCSSValue);"
            out += "--color-destructive:\(dark.destructive.rawCSSValue);"
            out += "}}"
        }

        // Custom named themes — emit full colour token set under [data-theme="key"].
        for (themeName, themeColors) in customThemes.sorted(by: { $0.key < $1.key }) {
            out += colorBlock(selector: "[data-theme=\"\(cssIdentifierSanitize(themeName))\"]", colors: themeColors)
        }

        // Custom palettes — colour-only overrides under [data-palette="key"].
        for (paletteName, paletteColors) in customPalettes.sorted(by: { $0.key < $1.key }) {
            out += colorBlock(selector: "[data-palette=\"\(cssIdentifierSanitize(paletteName))\"]", colors: paletteColors)
        }

        // Manual dark/light toggles — emitted LAST so they beat both the media query
        // and any active palette selection (equal specificity, last-wins cascade).
        if let dark = darkColors {
            // Force dark regardless of OS preference or palette.
            out += "[data-theme=\"dark\"]{--color-primary:\(dark.primary.rawCSSValue);"
            out += "--color-accent:\(dark.accent.rawCSSValue);"
            out += "--color-surface:\(dark.surface.rawCSSValue);"
            out += "--color-secondary:\(dark.secondary.rawCSSValue);"
            out += "--color-tertiary:\(dark.tertiary.rawCSSValue);"
            out += "--color-text:\(dark.text.rawCSSValue);"
            out += "--color-muted:\(dark.muted.rawCSSValue);"
            out += "--color-destructive:\(dark.destructive.rawCSSValue);}"
            // Force light — overrides the dark media query so the user can pin light mode.
            out += "[data-theme=\"light\"]{--color-primary:\(colors.primary.rawCSSValue);"
            out += "--color-accent:\(colors.accent.rawCSSValue);"
            out += "--color-surface:\(colors.surface.rawCSSValue);"
            out += "--color-secondary:\(colors.secondary.rawCSSValue);"
            out += "--color-tertiary:\(colors.tertiary.rawCSSValue);"
            out += "--color-text:\(colors.text.rawCSSValue);"
            out += "--color-muted:\(colors.muted.rawCSSValue);"
            out += "--color-destructive:\(colors.destructive.rawCSSValue);}"
        }

        // Custom presets — radius + shadow token overrides under [data-preset="key"].
        for (presetName, over) in customPresets.sorted(by: { $0.key < $1.key }) {
            let sel = "[data-preset=\"\(cssIdentifierSanitize(presetName))\"]"
            out += "\(sel){"
            out += "--radius-sm:\(over.radii.sm.cssStr)px;"
            out += "--radius-md:\(over.radii.md.cssStr)px;"
            out += "--radius-lg:\(over.radii.lg.cssStr)px;"
            out += "--radius-xl:\(over.radii.xl.cssStr)px;"
            out += "--radius-2xl:\(over.radii.twoXL.cssStr)px;"
            out += "--radius-full:\(over.radii.full.cssStr)px;"
            out += "--shadow-sm:\(over.shadows.sm);"
            out += "--shadow-md:\(over.shadows.md);"
            out += "--shadow-lg:\(over.shadows.lg);"
            out += "--shadow-xl:\(over.shadows.xl);"
            out += "--shadow-2xl:\(over.shadows.twoXL);"
            out += "--shadow-inner:\(over.shadows.inner);"
            out += "}"
        }

        // Component theme CSS (buttons, inputs, badges, links, dialogs).
        let componentCSS = components.css()
        if !componentCSS.isEmpty {
            out += componentCSS
        }

        return out
    }

    /// Emit `<link>` tags for custom fonts — preconnect hints and font file preloads.
    ///
    /// Inject the result into the `<head>` before the theme `<style>` block so
    /// the browser can begin fetching fonts as early as possible.
    public func fontLinkTags() -> String {
        var tags = ""
        var seenPreconnects: Set<String> = []

        for family in [fonts.body, fonts.heading, fonts.mono] {
            guard case .custom(_, let url, let supplementaryURLs) = family else { continue }

            // Preconnect hints (e.g. Google Fonts domains)
            for preconnect in supplementaryURLs where !seenPreconnects.contains(preconnect) {
                tags += "<link rel=\"preconnect\" href=\"\(attributeEscape(preconnect))\" crossorigin>"
                seenPreconnects.insert(preconnect)
            }

            // Preload self-hosted font files; load remote stylesheets directly
            if let url {
                let lower = url.lowercased()
                if lower.hasSuffix(".woff2") || lower.hasSuffix(".woff") || lower.hasSuffix(".ttf") || lower.hasSuffix(".otf") {
                    tags += "<link rel=\"preload\" href=\"\(attributeEscape(url))\" as=\"font\" crossorigin>"
                } else {
                    tags += "<link rel=\"stylesheet\" href=\"\(attributeEscape(url))\">"
                }
            }
        }

        return tags
    }

    private func colorBlock(selector: String, colors: ThemeColors) -> String {
        "\(selector){"
            + "--color-primary:\(colors.primary.rawCSSValue);"
            + "--color-accent:\(colors.accent.rawCSSValue);"
            + "--color-surface:\(colors.surface.rawCSSValue);"
            + "--color-secondary:\(colors.secondary.rawCSSValue);"
            + "--color-tertiary:\(colors.tertiary.rawCSSValue);"
            + "--color-text:\(colors.text.rawCSSValue);"
            + "--color-muted:\(colors.muted.rawCSSValue);"
            + "--color-destructive:\(colors.destructive.rawCSSValue);}"
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
        primary: .violet(600),
        accent: .emerald(400),
        surface: Color(oklch: 1.0, 0, 0),
        secondary: .slate(100),
        tertiary: .slate(50),
        text: .slate(900),
        muted: .slate(500),
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
        self.primary = primary
        self.accent = accent
        self.surface = surface
        self.secondary = secondary
        self.tertiary = tertiary
        self.text = text
        self.muted = muted
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
        self.body = body
        self.heading = heading
        self.mono = mono
    }
}

// MARK: - FontFamily

public enum FontFamily: Sendable {
    case system
    /// A named custom font.
    ///
    /// - Parameters:
    ///   - name: The CSS font-family name (e.g. `"Fraunces"`).
    ///   - url: URL to the font resource. A `.woff2`/`.woff`/`.ttf`/`.otf` path
    ///     generates a `<link rel="preload">` and an `@font-face` rule. Any other
    ///     URL (e.g. a Google Fonts stylesheet) generates a `<link rel="stylesheet">`.
    ///   - supplementaryURLs: Additional URLs to preconnect to before the font
    ///     loads — typically the CDN origins required by remote font services.
    ///     For Google Fonts, pass `["https://fonts.googleapis.com",
    ///     "https://fonts.gstatic.com"]`.
    case custom(String, url: String? = nil, supplementaryURLs: [String] = [])

    public var css: String {
        switch self {
        case .system:
            return "system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif"
        case .custom(let name, _, _):
            return "'\(name)',system-ui,sans-serif"
        }
    }

    /// The monospaced system font stack.
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
        self.base = base
        self.multiplier = multiplier
    }

    public func px(for step: Double) -> Double {
        spacingPx(step) * multiplier
    }
}

// MARK: - PresetOverride

/// The radius and shadow values for a theme preset.
///
/// Register these in ``SiteTheme/customPresets`` so the runtime ``ThemeSelector``
/// can switch `--radius-*` and `--shadow-*` CSS variables live via `data-preset`.
public struct PresetOverride: Sendable {
    public var radii: ThemeRadii
    public var shadows: ThemeShadows

    public init(radii: ThemeRadii, shadows: ThemeShadows) {
        self.radii = radii
        self.shadows = shadows
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
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.twoXL = twoXL
        self.full = full
    }

    public subscript(token: RadiusToken) -> Double {
        switch token {
        case .sm: return sm
        case .md: return md
        case .lg: return lg
        case .xl: return xl
        case .twoXL: return twoXL
        case .full: return full
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
        sm: "0 1px 2px oklch(0 0 0/0.05)",
        md: "0 4px 6px oklch(0 0 0/0.07)",
        lg: "0 10px 15px oklch(0 0 0/0.1)",
        xl: "0 20px 25px oklch(0 0 0/0.1)",
        twoXL: "0 25px 50px oklch(0 0 0/0.25)",
        inner: "inset 0 2px 4px oklch(0 0 0/0.06)"
    )

    public init(sm: String, md: String, lg: String, xl: String, twoXL: String, inner: String) {
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.twoXL = twoXL
        self.inner = inner
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
        self.phone = phone
        self.tablet = tablet
        self.desktop = desktop
        self.wide = wide
        self.ultrawide = ultrawide
    }

    public func minWidth(for breakpoint: Breakpoint) -> Int {
        switch breakpoint {
        case .phone: return phone
        case .tablet: return tablet
        case .desktop: return desktop
        case .wide: return wide
        case .ultrawide: return ultrawide
        }
    }
}

// MARK: - Supporting enums / types

public enum Breakpoint: String, Sendable {
    case phone, tablet, desktop, wide, ultrawide
}

public enum RadiusToken: String, Sendable {
    case sm, md, lg, xl, twoXL, full

    public var cssName: String {
        switch self {
        case .twoXL: return "2xl"
        default: return rawValue
        }
    }
}
