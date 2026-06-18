// MARK: - ButtonTheme

/// Default styles for ``Button``, with one rule per ``ButtonVariant``.
///
/// Rules are scoped to `button[data-variant]`, so hand-written `<button>`
/// markup is never affected.
public struct ButtonTheme: Sendable {
    /// Control sizing applied to every variant.
    public enum Size: String, Sendable {
        case small, medium, large

        var padding: String {
            switch self {
            case .small: return "0.375rem 0.75rem"
            case .medium: return "0.5rem 1rem"
            case .large: return "0.75rem 1.5rem"
            }
        }

        var fontSize: String {
            switch self {
            case .small: return "0.875rem"
            case .medium: return "1rem"
            case .large: return "1.125rem"
            }
        }
    }

    public var size: Size
    public var radius: RadiusToken
    public var fontWeight: Int
    /// CSS declarations merged into the shared `button[data-variant]` rule.
    /// Keys replace generated declarations of the same property; new keys append.
    public var overrides: [String: String]
    /// CSS declarations merged into the `:hover:not(:disabled)` rule.
    /// Keys replace generated declarations; `"filter": "none"` disables the default brightness dim.
    public var hoverOverrides: [String: String]
    /// Per-variant CSS declarations merged into that variant's rule.
    public var variantOverrides: [ButtonVariant: [String: String]]

    /// Filled buttons with medium radius — the standard look.
    public static let `default` = ButtonTheme()
    /// Fully rounded, capsule-shaped buttons.
    public static let pill = ButtonTheme(radius: .full)
    /// Small, lightly rounded buttons for dense UIs.
    public static let compact = ButtonTheme(size: .small, radius: .sm)

    public init(
        size: Size = .medium,
        radius: RadiusToken = .md,
        fontWeight: Int = 500,
        overrides: [String: String] = [:],
        hoverOverrides: [String: String] = [:],
        variantOverrides: [ButtonVariant: [String: String]] = [:]
    ) {
        self.size = size
        self.radius = radius
        self.fontWeight = fontWeight
        self.overrides = overrides
        self.hoverOverrides = hoverOverrides
        self.variantOverrides = variantOverrides
    }

    public func css() -> String {
        let base: [(String, String)] = [
            ("display", "inline-flex"),
            ("align-items", "center"),
            ("justify-content", "center"),
            ("gap", "0.5em"),
            ("font-family", "inherit"),
            ("font-size", size.fontSize),
            ("font-weight", "\(fontWeight)"),
            ("line-height", "1.25"),
            ("padding", size.padding),
            ("border", "1px solid transparent"),
            ("border-radius", "var(--radius-\(radius.cssName))"),
            ("cursor", "pointer"),
            ("text-decoration", "none"),
            ("transition", "background-color .15s ease,color .15s ease,border-color .15s ease,opacity .15s ease,filter .15s ease"),
        ]

        let hoverBase: [(String, String)] = [("filter", "brightness(0.95)")]
        var out = ":where(button[data-variant]){\(mergeDeclarations(base, overrides))}"
        out += ":where(button[data-variant]:disabled){opacity:0.5;cursor:not-allowed}"
        out += ":where(button[data-variant]:focus-visible){outline:2px solid var(--color-accent);outline-offset:2px}"
        out += ":where(button[data-variant]:hover:not(:disabled)){\(mergeDeclarations(hoverBase, hoverOverrides))}"

        let variants: [(ButtonVariant, [(String, String)])] = [
            (
                .primary,
                [
                    ("background", "var(--color-primary)"),
                    ("color", "var(--color-surface)"),
                ]
            ),
            (
                .secondary,
                [
                    ("background", "var(--color-secondary)"),
                    ("color", "var(--color-text)"),
                ]
            ),
            (
                .ghost,
                [
                    ("background", "transparent"),
                    ("color", "var(--color-text)"),
                ]
            ),
            (
                .destructive,
                [
                    ("background", "var(--color-destructive)"),
                    ("color", "var(--color-surface)"),
                ]
            ),
            (
                .outline,
                [
                    ("background", "transparent"),
                    ("color", "var(--color-text)"),
                    ("border-color", "var(--color-muted)"),
                ]
            ),
            (
                .icon,
                [
                    ("background", "transparent"),
                    ("color", "var(--color-text)"),
                    ("padding", "0.5rem"),
                ]
            ),
        ]

        for (variant, declarations) in variants {
            let merged = mergeDeclarations(declarations, variantOverrides[variant] ?? [:])
            out += ":where(button[data-variant=\"\(variant.rawValue)\"]){\(merged)}"
        }
        out += ":where(button[data-variant=\"ghost\"]:hover:not(:disabled)){background:var(--color-secondary)}"
        return out
    }
}
