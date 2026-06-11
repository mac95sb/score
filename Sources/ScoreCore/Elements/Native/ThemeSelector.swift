// MARK: - ThemeSelector

/// A dropdown that switches the active theme or colour palette at runtime.
///
/// `ThemeSelector` writes a `data-theme` attribute on `<html>` when the user
/// picks an option. Your `SiteTheme.customThemes` dictionary must register
/// matching keys so the CSS variables are emitted.
///
/// ```swift
/// // Palette picker — pre-built dev-theme presets
/// ThemeSelector(palette: [
///     .init("Default",      themeKey: ""),
///     .init("Rosé Pine",    themeKey: "rose-pine"),
///     .init("Tokyo Night",  themeKey: "tokyo-night"),
///     .init("One Dark",     themeKey: "one-dark"),
/// ])
///
/// // Theme picker — custom named themes on SiteTheme
/// ThemeSelector(themes: [
///     .init("Default", themeKey: ""),
///     .init("Dark",    themeKey: "dark"),
/// ])
/// ```
///
/// Wire up `customThemes` in your ``Application``:
///
/// ```swift
/// var theme: SiteTheme {
///     SiteTheme(
///         customThemes: [
///             "rose-pine":   .rosePine,
///             "tokyo-night": .tokyoNight,
///             "one-dark":    .oneDark,
///         ]
///     )
/// }
/// ```
public struct ThemeSelector: View, _HTMLRenderable {

    /// A single option in the selector.
    public struct Option: Sendable {
        /// Display label shown in the dropdown.
        public let label: String
        /// The value written to `data-theme` on `<html>`. Empty string → removes attribute.
        public let themeKey: String

        public init(_ label: String, themeKey: String) {
            self.label    = label
            self.themeKey = themeKey
        }
    }

    public enum Mode: Sendable {
        /// Sets `data-theme` on `<html>` — matches `SiteTheme.customThemes` keys.
        case theme
        /// Sets `data-palette` on `<html>` — for palette-only overrides separate from full themes.
        case palette
    }

    let options: [Option]
    let mode: Mode
    let id: String
    let label: String?

    /// Create a theme selector.
    ///
    /// - Parameters:
    ///   - options: Ordered list of options. Use an empty `themeKey` for the default theme.
    ///   - mode: Whether the selector controls named themes (`.theme`) or palettes (`.palette`).
    ///   - label: Optional visible label rendered before the dropdown.
    ///   - id: HTML `id` attribute of the `<select>` element.
    public init(
        _ options: [Option],
        mode: Mode = .theme,
        label: String? = nil,
        id: String = "score-theme-selector"
    ) {
        self.options = options
        self.mode    = mode
        self.label   = label
        self.id      = id
    }

    /// Convenience: palette mode.
    public init(
        palette options: [Option],
        label: String? = nil,
        id: String = "score-theme-selector"
    ) {
        self.init(options, mode: .palette, label: label, id: id)
    }

    /// Convenience: theme mode.
    public init(
        themes options: [Option],
        label: String? = nil,
        id: String = "score-theme-selector"
    ) {
        self.init(options, mode: .theme, label: label, id: id)
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let attr = mode == .theme ? "data-theme" : "data-palette"
        var html = ""

        if let label {
            html += "<label for=\"\(htmlEscape(id))\">\(htmlEscape(label))</label>"
        }

        html += "<select id=\"\(htmlEscape(id))\" onchange=\""
        // Inline handler: set or remove the attribute on <html>
        html += "var v=this.value;"
        html += "if(v){document.documentElement.setAttribute('\(attr)',v);}"
        html += "else{document.documentElement.removeAttribute('\(attr)');}"
        // Persist across page navigations via localStorage
        html += "localStorage.setItem('score-\(attr)',v);"
        html += "\">"

        for option in options {
            let escaped = htmlEscape(option.themeKey)
            let labelEsc = htmlEscape(option.label)
            html += "<option value=\"\(escaped)\">\(labelEsc)</option>"
        }

        html += "</select>"

        // Restore on page load
        let restoreScript =
            "<script>(function(){" +
            "var v=localStorage.getItem('score-\(attr)');" +
            "if(v){document.documentElement.setAttribute('\(attr)',v);" +
            "var s=document.getElementById('\(htmlEscape(id))');" +
            "if(s)s.value=v;}" +
            "})();</script>"

        return html + restoreScript
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
