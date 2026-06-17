// MARK: - InputTheme

/// Default styles for text-like ``Input`` controls (`input`, `select`, `textarea`).
///
/// Checkbox, radio, range, and hidden inputs are excluded — their native
/// rendering is left untouched.
public struct InputTheme: Sendable {
    public var radius: RadiusToken
    public var padding: String
    /// Any CSS color value for the resting border.
    public var borderColor: String
    /// Any CSS color value for the input background.
    public var background: String
    /// Any CSS color value for the focus outline.
    public var focusColor: String
    /// Declarations merged into the base rule.
    public var overrides: [String: String]

    /// Bordered fields on the surface colour.
    public static let `default` = InputTheme()
    /// Borderless fields on the secondary colour.
    public static let minimal = InputTheme(
        borderColor: "transparent",
        background: "var(--color-secondary)"
    )

    public init(
        radius: RadiusToken = .md,
        padding: String = "0.5rem 0.75rem",
        borderColor: String = "var(--color-muted)",
        background: String = "var(--color-surface)",
        focusColor: String = "var(--color-accent)",
        overrides: [String: String] = [:]
    ) {
        self.radius      = radius
        self.padding     = padding
        self.borderColor = borderColor
        self.background  = background
        self.focusColor  = focusColor
        self.overrides   = overrides
    }

    static let selector =
        ":where(input:not([type=\"checkbox\"]):not([type=\"radio\"]):not([type=\"range\"]):not([type=\"hidden\"]),select,textarea)"

    public func css() -> String {
        let base: [(String, String)] = [
            ("font-family", "inherit"),
            ("font-size", "1rem"),
            ("color", "var(--color-text)"),
            ("background", background),
            ("border", "1px solid \(cssValueSanitize(borderColor))"),
            ("border-radius", "var(--radius-\(radius.cssName))"),
            ("padding", padding),
        ]
        var out = "\(Self.selector){\(mergeDeclarations(base, overrides))}"
        out += ":where(input:focus-visible,select:focus-visible,textarea:focus-visible){outline:2px solid \(cssValueSanitize(focusColor));outline-offset:1px}"
        out += ":where(input:disabled,select:disabled,textarea:disabled){opacity:0.5;cursor:not-allowed}"
        return out
    }
}
