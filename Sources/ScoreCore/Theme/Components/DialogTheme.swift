// MARK: - DialogTheme

/// Default styles for ``Dialog`` (`dialog[data-score-dialog]`) and its backdrop.
public struct DialogTheme: Sendable {
    public var radius: RadiusToken
    public var padding: String
    public var maxWidth: String
    /// Any CSS color value used for `::backdrop`.
    public var backdrop: String
    /// Optional backdrop blur in pixels.
    public var backdropBlur: Double?
    /// Declarations merged into the `dialog[data-score-dialog]` rule.
    public var overrides: [String: String]

    /// An elevated card with a dimmed backdrop.
    public static let `default` = DialogTheme()
    /// A flatter sheet with a lighter backdrop.
    public static let minimal = DialogTheme(
        radius: .md,
        padding: "1rem",
        backdrop: "oklch(0 0 0/0.35)"
    )

    public init(
        radius: RadiusToken = .xl,
        padding: String = "1.5rem",
        maxWidth: String = "32rem",
        backdrop: String = "oklch(0 0 0/0.5)",
        backdropBlur: Double? = nil,
        overrides: [String: String] = [:]
    ) {
        self.radius       = radius
        self.padding      = padding
        self.maxWidth     = maxWidth
        self.backdrop     = backdrop
        self.backdropBlur = backdropBlur
        self.overrides    = overrides
    }

    public func css() -> String {
        let base: [(String, String)] = [
            ("background", "var(--color-surface)"),
            ("color", "var(--color-text)"),
            ("border", "none"),
            ("border-radius", "var(--radius-\(radius.cssName))"),
            ("box-shadow", "var(--shadow-2xl)"),
            ("padding", padding),
            ("max-width", maxWidth),
            ("width", "calc(100% - 2rem)"),
        ]
        var out = ":where(dialog[data-score-dialog]){\(mergeDeclarations(base, overrides))}"
        var backdropDecls = "background:\(cssValueSanitize(backdrop))"
        if let blur = backdropBlur {
            backdropDecls += ";backdrop-filter:blur(\(blur.cssStr)px)"
        }
        out += ":where(dialog[data-score-dialog])::backdrop{\(backdropDecls)}"
        return out
    }
}
