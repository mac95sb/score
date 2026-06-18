// MARK: - LinkTheme

/// Default styles for anchors rendered by ``Link`` and ``NavLink``.
public struct LinkTheme: Sendable {
    /// When the underline is shown.
    public enum Underline: String, Sendable {
        case always, hover, never
    }

    /// Any CSS color value. Defaults to the accent theme token.
    public var color: String
    public var underline: Underline
    /// Declarations merged into the base `a` rule.
    public var overrides: [String: String]

    /// Accent-coloured links that underline on hover.
    public static let `default` = LinkTheme()
    /// Always-underlined links.
    public static let underlined = LinkTheme(underline: .always)
    /// Links that inherit the surrounding text colour with no underline.
    public static let plain = LinkTheme(color: "inherit", underline: .never)

    public init(
        color: String = "var(--color-accent)",
        underline: Underline = .hover,
        overrides: [String: String] = [:]
    ) {
        self.color = color
        self.underline = underline
        self.overrides = overrides
    }

    public func css() -> String {
        let base: [(String, String)] = [
            ("color", color),
            ("text-decoration", underline == .always ? "underline" : "none"),
            ("text-underline-offset", "0.2em"),
            ("transition", "color .15s ease"),
        ]
        var out = ":where(a){\(mergeDeclarations(base, overrides))}"
        if underline == .hover {
            out += ":where(a:hover){text-decoration:underline}"
        }
        out += ":where(a[data-navlink][data-active=\"true\"]){color:var(--color-primary);font-weight:600}"
        return out
    }
}
