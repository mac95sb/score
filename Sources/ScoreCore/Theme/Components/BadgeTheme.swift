// MARK: - BadgeTheme

/// Default styles for ``Badge`` (`.badge`).
public struct BadgeTheme: Sendable {
    /// Any CSS color value for the badge background.
    public var background: String
    /// Any CSS color value for the badge text.
    public var color: String
    /// Any CSS border value (e.g. `"1px solid var(--color-muted)"`).
    public var border: String
    public var radius: RadiusToken
    /// Declarations merged into the `.badge` rule.
    public var overrides: [String: String]

    /// A filled pill on the secondary colour.
    public static let `default` = BadgeTheme()
    /// A transparent pill with a muted outline.
    public static let outline = BadgeTheme(
        background: "transparent",
        border: "1px solid var(--color-muted)"
    )

    public init(
        background: String = "var(--color-secondary)",
        color: String = "var(--color-text)",
        border: String = "none",
        radius: RadiusToken = .full,
        overrides: [String: String] = [:]
    ) {
        self.background = background
        self.color      = color
        self.border     = border
        self.radius     = radius
        self.overrides  = overrides
    }

    public func css() -> String {
        let base: [(String, String)] = [
            ("display", "inline-flex"),
            ("align-items", "center"),
            ("gap", "0.25em"),
            ("padding", "0.125rem 0.625rem"),
            ("font-size", "0.75rem"),
            ("font-weight", "500"),
            ("line-height", "1.4"),
            ("background", background),
            ("color", color),
            ("border", border),
            ("border-radius", "var(--radius-\(radius.cssName))"),
        ]
        return ":where(.badge){\(mergeDeclarations(base, overrides))}"
    }
}
