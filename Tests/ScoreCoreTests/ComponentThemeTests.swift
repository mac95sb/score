import Testing
@testable import ScoreCore

@Suite("ComponentTheme")
struct ComponentThemeTests {

    @Test("none emits no CSS")
    func noneIsEmpty() {
        #expect(ComponentTheme.none.css().isEmpty)
    }

    @Test("SiteTheme defaults to no component CSS")
    func siteThemeDefault() {
        #expect(SiteTheme.default.components.css().isEmpty)
    }

    @Test("default theme styles every button variant")
    func buttonVariants() {
        let css = ComponentTheme.default.css()
        for variant in ["primary", "secondary", "ghost", "destructive", "outline", "icon"] {
            #expect(css.contains("button[data-variant=\"\(variant)\"]"))
        }
    }

    @Test("button styles reference theme color tokens")
    func buttonUsesTokens() {
        let css = ButtonTheme.default.css()
        #expect(css.contains("background:var(--color-primary)"))
        #expect(css.contains("background:var(--color-destructive)"))
        #expect(css.contains("border-radius:var(--radius-md)"))
    }

    @Test("pill button preset uses the full radius token")
    func pillButton() {
        #expect(ButtonTheme.pill.css().contains("border-radius:var(--radius-full)"))
    }

    @Test("base overrides replace generated declarations in place")
    func baseOverrides() {
        var theme = ButtonTheme.default
        theme.overrides["padding"] = "2rem"
        let css = theme.css()
        #expect(css.contains("padding:2rem"))
        #expect(!css.contains("padding:0.5rem 1rem"))
    }

    @Test("variant overrides merge into the variant rule")
    func variantOverrides() {
        var theme = ButtonTheme.default
        theme.variantOverrides[.primary] = [
            "background": "var(--color-accent)",
            "text-transform": "uppercase",
        ]
        let css = theme.css()
        #expect(css.contains(":where(button[data-variant=\"primary\"]){background:var(--color-accent)"))
        #expect(css.contains("text-transform:uppercase"))
    }

    @Test("link theme controls underline behaviour")
    func linkUnderline() {
        #expect(LinkTheme.default.css().contains(":where(a:hover){text-decoration:underline}"))
        #expect(LinkTheme.underlined.css().contains("text-decoration:underline"))

        let plain = LinkTheme.plain.css()
        #expect(plain.contains("color:inherit"))
        #expect(!plain.contains(":where(a:hover){text-decoration:underline}"))
    }

    @Test("dialog theme styles the element and backdrop")
    func dialogCSS() {
        let css = DialogTheme.default.css()
        #expect(css.contains(":where(dialog[data-score-dialog]){"))
        #expect(css.contains(":where(dialog[data-score-dialog])::backdrop{"))
        #expect(css.contains("border-radius:var(--radius-xl)"))
    }

    @Test("dialog backdrop blur is emitted when set")
    func dialogBlur() {
        var theme = DialogTheme.default
        theme.backdropBlur = 4
        #expect(theme.css().contains("backdrop-filter:blur(4px)"))
        #expect(!DialogTheme.default.css().contains("backdrop-filter"))
    }

    @Test("input theme excludes checkbox and radio controls")
    func inputSelector() {
        let css = InputTheme.default.css()
        #expect(css.contains("input:not([type=\"checkbox\"])"))
        #expect(css.contains("select"))
        #expect(css.contains("textarea"))
    }

    @Test("badge theme targets the badge class")
    func badgeCSS() {
        let css = BadgeTheme.default.css()
        #expect(css.contains(":where(.badge){"))
        #expect(css.contains("border-radius:var(--radius-full)"))
        #expect(BadgeTheme.outline.css().contains("border:1px solid var(--color-muted)"))
    }

    @Test("only enabled components emit CSS")
    func partialTheme() {
        let theme = ComponentTheme(link: .default)
        let css = theme.css()
        #expect(css.contains(":where(a){"))
        #expect(!css.contains("button[data-variant]"))
        #expect(!css.contains(".badge"))
    }

    @Test("every rule is zero-specificity so user modifiers always win")
    func zeroSpecificity() {
        // Modifier CSS is class-based (specificity 0,1,0). Component theme
        // rules must stay below that, which :where() guarantees (0,0,0) —
        // apart from the ::backdrop pseudo-element, which modifiers can't
        // target anyway.
        let css = ComponentTheme.default.css()
        for rule in css.split(separator: "}").filter({ $0.contains("{") }) {
            let selector = rule.split(separator: "{")[0]
            #expect(
                selector.hasPrefix(":where(") || selector.contains(")::backdrop"),
                "non-:where selector: \(selector)"
            )
        }
    }

    @Test("override values cannot escape their declaration")
    func overrideSanitization() {
        var theme = ButtonTheme.default
        theme.overrides["padding"] = "0}body{display:none}"
        theme.overrides["color;background"] = "red"
        let css = theme.css()
        #expect(!css.contains("body{display:none}"))
        #expect(css.contains("padding:0bodydisplay:none"))
        #expect(css.contains("colorbackground:red"))
    }

}
