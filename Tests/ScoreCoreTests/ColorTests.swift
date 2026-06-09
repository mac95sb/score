import Testing
@testable import ScoreCore

@Suite("Color")
struct ColorTests {
    @Test("creates color from hex string")
    func hexColor() throws {
        let red = Color(hex: "#ff0000")
        // OKLCh L should be non-zero for red
        #expect(red.l > 0)
        #expect(red.alpha == 1.0)
    }

    @Test("creates color from RGB components")
    func rgbColor() throws {
        let white = Color(rgb: 1.0, 1.0, 1.0)
        #expect(white.l > 0.99)  // near maximum lightness

        let black = Color(rgb: 0.0, 0.0, 0.0)
        #expect(black.l < 0.01)  // near zero lightness
    }

    @Test("creates color from OKLCh directly")
    func oklchColor() throws {
        let c = Color(oklch: 0.5, 0.1, 180.0)
        #expect(c.l == 0.5)
        #expect(c.c == 0.1)
        #expect(c.h == 180.0)
    }

    @Test("opacity modifier returns correct alpha")
    func opacityModifier() throws {
        let c = Color(oklch: 0.5, 0.1, 0.0).opacity(0.5)
        #expect(c.alpha == 0.5)
    }

    @Test("mix blends two colors")
    func mixColors() throws {
        let c1 = Color(oklch: 0.2, 0.0, 0.0)
        let c2 = Color(oklch: 0.8, 0.0, 0.0)
        let mixed = c1.mix(with: c2, weight: 0.5)
        #expect(mixed.l > 0.4)
        #expect(mixed.l < 0.6)
    }

    @Test("cssValue for opaque color omits alpha")
    func cssValueOpaque() throws {
        let c = Color(oklch: 0.5, 0.1, 120.0)
        let css = c.cssValue
        #expect(css.hasPrefix("oklch("))
        #expect(!css.contains(" / "))
    }

    @Test("cssValue for transparent color includes alpha")
    func cssValueTransparent() throws {
        let c = Color(oklch: 0.5, 0.1, 120.0).opacity(0.5)
        let css = c.cssValue
        #expect(css.contains(" / "))
    }

    @Test("palette returns colors for slate family")
    func paletteSlate() throws {
        let s50 = Color.slate(50)
        let s950 = Color.slate(950)
        // Lighter shades have higher L values
        #expect(s50.l > s950.l)
    }

    @Test("semantic aliases are non-nil")
    func semanticAliases() throws {
        // These should not crash and should return valid colors
        _ = Color.primary
        _ = Color.accent
        _ = Color.text
        _ = Color.surface
        _ = Color.destructive
    }

    @Test("white and black constants")
    func whiteAndBlack() throws {
        #expect(Color.white.l > 0.99)
        #expect(Color.black.l < 0.01)
    }
}
