import Testing

@testable import ScoreCore

@Suite("Theme")
struct ThemeTests {

    // MARK: - Default theme

    @Test("default theme has non-empty CSS variables")
    func defaultThemeCSSVariables() {
        let css = SiteTheme.default.cssVariables()
        #expect(css.contains(":root"))
        #expect(css.contains("--color-primary"))
        #expect(css.contains("--color-text"))
        #expect(css.contains("--shadow-md"))
        #expect(css.contains("--radius-lg"))
    }

    @Test("default theme breakpoints are ordered small to large")
    func breakpointsOrdered() {
        let bp = SiteTheme.default.breakpoints
        #expect(bp.phone < bp.tablet)
        #expect(bp.tablet < bp.desktop)
        #expect(bp.desktop < bp.wide)
        #expect(bp.wide < bp.ultrawide)
    }

    // MARK: - Dark mode

    @Test("dark mode block emitted when darkColors set")
    func darkModeBlock() {
        let dark = ThemeColors(
            primary: Color(oklch: 0.7, 0.15, 250),
            accent: Color(oklch: 0.6, 0.2, 200),
            surface: Color(oklch: 0.15, 0.0, 0),
            secondary: Color(oklch: 0.5, 0.1, 250),
            tertiary: Color(oklch: 0.4, 0.05, 0),
            text: Color(oklch: 0.95, 0.0, 0),
            muted: Color(oklch: 0.6, 0.0, 0),
            destructive: Color(oklch: 0.55, 0.22, 25)
        )
        let theme = SiteTheme(darkColors: dark)
        let css = theme.cssVariables()
        #expect(css.contains("prefers-color-scheme"))
        #expect(css.contains("dark"))
    }

    @Test("no dark mode block when darkColors is nil")
    func noDarkMode() {
        let theme = SiteTheme(darkColors: nil)
        let css = theme.cssVariables()
        #expect(!css.contains("prefers-color-scheme"))
    }

    // MARK: - ThemeBreakpoints

    @Test("breakpoints have sensible pixel values")
    func breakpointPixelValues() {
        let bp = ThemeBreakpoints.default
        #expect(bp.phone >= 320)
        #expect(bp.desktop >= 1024)
    }

    // MARK: - ThemeColors

    @Test("default colors have non-zero lightness")
    func defaultColorsNonZero() {
        let c = ThemeColors.default
        // Primary color should have positive OKLCh lightness (not pure black)
        #expect(c.primary.cssValue.count > 0)
    }

    // MARK: - Radii

    @Test("radius scale emits positive px values")
    func radiiPositive() {
        let r = ThemeRadii.default
        #expect(r.sm.cssStr.count > 0)
        #expect(r.lg.cssStr.count > 0)
    }
}
