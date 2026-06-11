import Foundation

// MARK: - ThemePalette

/// A coordinated light + dark colour pairing built from Score's built-in
/// colour scales.
///
/// Palettes feed ``SiteTheme/preset(_:palette:)`` but can also be applied
/// directly:
///
/// ```swift
/// var theme = SiteTheme.default
/// theme.colors = ThemePalette.indigo.light
/// theme.darkColors = ThemePalette.indigo.dark
/// ```
public struct ThemePalette: Sendable {
    public var light: ThemeColors
    public var dark: ThemeColors

    public init(light: ThemeColors, dark: ThemeColors) {
        self.light = light
        self.dark = dark
    }

    /// Build a palette from colour-scale functions (e.g. `Color.indigo`).
    ///
    /// The light palette uses the 600/500 weights on a white surface with
    /// neutral greys; the dark palette lifts the hues to 400 weights on a
    /// near-black neutral surface.
    public init(
        primary: (Int) -> Color,
        accent: (Int) -> Color,
        neutral: (Int) -> Color = Color.slate
    ) {
        self.light = ThemeColors(
            primary:     primary(600),
            accent:      accent(500),
            surface:     .white,
            secondary:   neutral(100),
            tertiary:    neutral(50),
            text:        neutral(900),
            muted:       neutral(500),
            destructive: .rose(600)
        )
        self.dark = ThemeColors(
            primary:     primary(400),
            accent:      accent(400),
            surface:     neutral(950),
            secondary:   neutral(800),
            tertiary:    neutral(900),
            text:        neutral(100),
            muted:       neutral(400),
            destructive: .rose(500)
        )
    }

    // MARK: - Built-in palettes

    /// Violet primary with emerald accent — Score's default pairing.
    public static let violet = ThemePalette(primary: Color.violet, accent: Color.emerald)
    /// Indigo primary with sky accent.
    public static let indigo = ThemePalette(primary: Color.indigo, accent: Color.sky)
    /// Blue primary with cyan accent.
    public static let blue = ThemePalette(primary: Color.blue, accent: Color.cyan)
    /// Emerald primary with amber accent.
    public static let emerald = ThemePalette(primary: Color.emerald, accent: Color.amber)
    /// Teal primary with orange accent.
    public static let teal = ThemePalette(primary: Color.teal, accent: Color.orange)
    /// Rose primary with amber accent.
    public static let rose = ThemePalette(primary: Color.rose, accent: Color.amber)
    /// Near-monochrome: slate primary with a restrained blue accent.
    public static let mono = ThemePalette(primary: Color.slate, accent: Color.blue)
}

// MARK: - ThemePreset

/// Opinionated whole-theme presets. Each preset configures radii, shadows,
/// and component styles, and inherits whatever ``ThemePalette`` you pair it
/// with — so `preset(.neoBrutalism, palette: .emerald)` and
/// `preset(.minimal, palette: .emerald)` share colours but nothing else.
public enum ThemePreset: String, Sendable, CaseIterable {
    /// Hairline shadows, small radii, quiet components.
    case minimal
    /// Generous radii, layered soft shadows, blurred dialog backdrops.
    case modern
    /// Extra-round corners, pill buttons, diffuse shadows.
    case soft
    /// Square corners, thick black borders, hard offset shadows, bold type.
    case neoBrutalism
}

extension SiteTheme {

    /// Build a complete theme from a preset and a colour palette.
    ///
    /// ```swift
    /// var theme: SiteTheme { .preset(.modern, palette: .indigo) }
    /// var theme: SiteTheme { .preset(.neoBrutalism, palette: .emerald) }
    /// ```
    ///
    /// Presets enable component styles (`theme.components`) — tweak or
    /// override the result like any other ``SiteTheme``.
    public static func preset(
        _ preset: ThemePreset,
        palette: ThemePalette = .violet
    ) -> SiteTheme {
        var theme = SiteTheme(
            colors: palette.light,
            darkColors: palette.dark
        )

        switch preset {
        case .minimal:
            theme.radii = ThemeRadii(sm: 2, md: 4, lg: 6, xl: 8, twoXL: 12, full: 9999)
            theme.shadows = ThemeShadows(
                sm:    "0 1px 1px oklch(0 0 0/0.03)",
                md:    "0 1px 2px oklch(0 0 0/0.05)",
                lg:    "0 2px 4px oklch(0 0 0/0.06)",
                xl:    "0 4px 8px oklch(0 0 0/0.06)",
                twoXL: "0 8px 16px oklch(0 0 0/0.08)",
                inner: "inset 0 1px 2px oklch(0 0 0/0.04)"
            )
            theme.components = ComponentTheme(
                button: .compact,
                link:   .plain,
                dialog: .minimal,
                input:  .minimal,
                badge:  .outline
            )

        case .modern:
            theme.radii = ThemeRadii(sm: 6, md: 10, lg: 14, xl: 20, twoXL: 28, full: 9999)
            theme.shadows = ThemeShadows(
                sm:    "0 1px 2px oklch(0 0 0/0.04),0 1px 3px oklch(0 0 0/0.06)",
                md:    "0 2px 4px oklch(0 0 0/0.04),0 4px 8px oklch(0 0 0/0.06)",
                lg:    "0 4px 8px oklch(0 0 0/0.05),0 10px 20px oklch(0 0 0/0.08)",
                xl:    "0 8px 16px oklch(0 0 0/0.06),0 20px 32px oklch(0 0 0/0.09)",
                twoXL: "0 12px 24px oklch(0 0 0/0.08),0 28px 48px oklch(0 0 0/0.12)",
                inner: "inset 0 2px 4px oklch(0 0 0/0.05)"
            )
            theme.components = ComponentTheme(
                button: ButtonTheme(radius: .lg),
                link:   .default,
                dialog: DialogTheme(backdropBlur: 6),
                input:  .default,
                badge:  .default
            )

        case .soft:
            theme.radii = ThemeRadii(sm: 8, md: 14, lg: 20, xl: 28, twoXL: 36, full: 9999)
            theme.shadows = ThemeShadows(
                sm:    "0 2px 8px oklch(0 0 0/0.05)",
                md:    "0 4px 16px oklch(0 0 0/0.06)",
                lg:    "0 8px 24px oklch(0 0 0/0.08)",
                xl:    "0 12px 32px oklch(0 0 0/0.09)",
                twoXL: "0 20px 48px oklch(0 0 0/0.12)",
                inner: "inset 0 2px 6px oklch(0 0 0/0.04)"
            )
            theme.components = ComponentTheme(
                button: .pill,
                link:   .default,
                dialog: DialogTheme(radius: .twoXL, backdropBlur: 10),
                input:  InputTheme(radius: .lg),
                badge:  .default
            )

        case .neoBrutalism:
            theme.radii = ThemeRadii(sm: 0, md: 0, lg: 0, xl: 0, twoXL: 0, full: 9999)
            theme.shadows = ThemeShadows(
                sm:    "2px 2px 0 0 oklch(0 0 0)",
                md:    "4px 4px 0 0 oklch(0 0 0)",
                lg:    "6px 6px 0 0 oklch(0 0 0)",
                xl:    "8px 8px 0 0 oklch(0 0 0)",
                twoXL: "12px 12px 0 0 oklch(0 0 0)",
                inner: "inset 2px 2px 0 0 oklch(0 0 0)"
            )
            theme.components = ComponentTheme(
                button: ButtonTheme(
                    radius: .sm,
                    fontWeight: 700,
                    overrides: [
                        "border": "2px solid oklch(0 0 0)",
                        "box-shadow": "var(--shadow-sm)",
                    ]
                ),
                link: LinkTheme(underline: .always),
                dialog: DialogTheme(
                    radius: .sm,
                    backdrop: "oklch(0 0 0/0.4)",
                    overrides: [
                        "border": "2px solid oklch(0 0 0)",
                        "box-shadow": "var(--shadow-2xl)",
                    ]
                ),
                input: InputTheme(
                    radius: .sm,
                    overrides: ["border": "2px solid oklch(0 0 0)"]
                ),
                badge: BadgeTheme(
                    border: "2px solid oklch(0 0 0)",
                    radius: .sm
                )
            )
        }

        return theme
    }
}
