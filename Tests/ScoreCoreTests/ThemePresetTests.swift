import Testing
@testable import ScoreCore

@Suite("ThemePalette")
struct ThemePaletteTests {

    @Test("palettes pair light and dark colours from the scales")
    func paletteStructure() {
        let palette = ThemePalette.indigo
        #expect(palette.light.primary.cssValue == Color.indigo(600).cssValue)
        #expect(palette.dark.primary.cssValue == Color.indigo(400).cssValue)
        #expect(palette.light.surface.cssValue == Color.white.cssValue)
        #expect(palette.dark.surface.cssValue == Color.slate(950).cssValue)
    }

    @Test("custom palettes build from any scale functions")
    func customPalette() {
        let palette = ThemePalette(primary: Color.purple, accent: Color.lime, neutral: Color.zinc)
        #expect(palette.light.primary.cssValue == Color.purple(600).cssValue)
        #expect(palette.light.secondary.cssValue == Color.zinc(100).cssValue)
        #expect(palette.dark.accent.cssValue == Color.lime(400).cssValue)
    }
}

@Suite("ThemePreset")
struct ThemePresetTests {

    @Test("presets inherit the palette and set dark colours")
    func inheritsPalette() {
        let theme = SiteTheme.preset(.modern, palette: .emerald)
        #expect(theme.colors.primary.cssValue == Color.emerald(600).cssValue)
        #expect(theme.darkColors?.primary.cssValue == Color.emerald(400).cssValue)
    }

    @Test("every preset enables component styles")
    func enablesComponents() {
        for preset in ThemePreset.allCases {
            let theme = SiteTheme.preset(preset)
            #expect(!theme.components.css().isEmpty, "\(preset) emits no component CSS")
        }
    }

    @Test("minimal preset uses quiet components and small radii")
    func minimal() {
        let theme = SiteTheme.preset(.minimal)
        #expect(theme.radii.md == 4)
        #expect(theme.components.input != nil)
        let css = theme.components.css()
        #expect(!css.contains(":where(a:hover){text-decoration:underline}"))  // .plain links
    }

    @Test("soft preset uses pill buttons")
    func soft() {
        let theme = SiteTheme.preset(.soft)
        #expect(theme.components.button?.radius == .full)
    }

    @Test("neo-brutalism preset uses square corners, hard shadows, thick borders")
    func neoBrutalism() {
        let theme = SiteTheme.preset(.neoBrutalism, palette: .rose)
        #expect(theme.radii.md == 0)
        #expect(theme.shadows.md == "4px 4px 0 0 oklch(0 0 0)")
        let css = theme.components.css()
        #expect(css.contains("border:2px solid oklch(0 0 0)"))
        #expect(css.contains("font-weight:700"))
        // Palette still applies.
        #expect(theme.colors.primary.cssValue == Color.rose(600).cssValue)
    }

    @Test("preset themes can still be customised afterwards")
    func customisable() {
        var theme = SiteTheme.preset(.modern, palette: .blue)
        theme.components.button?.variantOverrides[.primary] = ["text-transform": "uppercase"]
        #expect(theme.components.css().contains("text-transform:uppercase"))
    }
}
