import Foundation

// MARK: - ComponentTheme

/// Opt-in default styling for Score's built-in interactive elements.
///
/// `ComponentTheme` lives on ``SiteTheme`` and mirrors how ``ContentTheme``
/// styles markdown content: instead of shipping a separate components plugin,
/// you enable default styles per component type directly in your theme and
/// override individual CSS declarations in place.
///
/// Every generated rule references the theme's CSS custom properties
/// (`--color-primary`, `--radius-md`, …), so component styles automatically
/// follow your ``ThemeColors``, ``ThemeRadii``, and dark-mode palettes.
///
/// ```swift
/// var theme: SiteTheme {
///     var theme = SiteTheme.default
///     // Turn on default styles for every supported component…
///     theme.components = .default
///     // …or pick and choose, with variations and overrides:
///     theme.components.button = .pill
///     theme.components.button?.variantOverrides[.primary] = [
///         "text-transform": "uppercase"
///     ]
///     theme.components.customCSS = "dialog::backdrop{backdrop-filter:blur(2px)}"
///     return theme
/// }
/// ```
///
/// The default value on ``SiteTheme`` is ``ComponentTheme/none``, which emits
/// no CSS at all — existing sites are unaffected until they opt in.
public struct ComponentTheme: Sendable {
    /// Styles for ``Button`` (`button[data-variant]`). `nil` emits nothing.
    public var button: ButtonTheme?
    /// Styles for ``Link`` and ``NavLink`` (`a`). `nil` emits nothing.
    public var link: LinkTheme?
    /// Styles for ``Dialog`` (`dialog[data-score-dialog]`). `nil` emits nothing.
    public var dialog: DialogTheme?
    /// Styles for ``Input`` text-like controls. `nil` emits nothing.
    public var input: InputTheme?
    /// Styles for ``Badge`` (`.badge`). `nil` emits nothing.
    public var badge: BadgeTheme?
    /// Raw CSS appended after all generated component styles.
    ///
    /// Because it is emitted last, equal-specificity selectors here win over
    /// the generated defaults — use it as the final escape hatch.
    public var customCSS: String

    /// No component styling. The default on ``SiteTheme``.
    public static let none = ComponentTheme()

    /// Default styles for every supported component.
    public static let `default` = ComponentTheme(
        button: .default,
        link:   .default,
        dialog: .default,
        input:  .default,
        badge:  .default
    )

    public init(
        button: ButtonTheme? = nil,
        link: LinkTheme? = nil,
        dialog: DialogTheme? = nil,
        input: InputTheme? = nil,
        badge: BadgeTheme? = nil,
        customCSS: String = ""
    ) {
        self.button    = button
        self.link      = link
        self.dialog    = dialog
        self.input     = input
        self.badge     = badge
        self.customCSS = customCSS
    }

    /// Emit the combined component CSS, or an empty string when nothing is enabled.
    public func css() -> String {
        var out = ""
        if let button { out += button.css() }
        if let link   { out += link.css() }
        if let dialog { out += dialog.css() }
        if let input  { out += input.css() }
        if let badge  { out += badge.css() }
        out += customCSS
        return out
    }
}

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
            case .small:  return "0.375rem 0.75rem"
            case .medium: return "0.5rem 1rem"
            case .large:  return "0.75rem 1.5rem"
            }
        }

        var fontSize: String {
            switch self {
            case .small:  return "0.875rem"
            case .medium: return "1rem"
            case .large:  return "1.125rem"
            }
        }
    }

    public var size: Size
    public var radius: RadiusToken
    public var fontWeight: Int
    /// CSS declarations merged into the shared `button[data-variant]` rule.
    /// Keys replace generated declarations of the same property; new keys append.
    public var overrides: [String: String]
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
        variantOverrides: [ButtonVariant: [String: String]] = [:]
    ) {
        self.size             = size
        self.radius           = radius
        self.fontWeight       = fontWeight
        self.overrides        = overrides
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

        var out = "button[data-variant]{\(mergeDeclarations(base, overrides))}"
        out += "button[data-variant]:disabled{opacity:0.5;cursor:not-allowed}"
        out += "button[data-variant]:focus-visible{outline:2px solid var(--color-accent);outline-offset:2px}"
        out += "button[data-variant]:hover:not(:disabled){filter:brightness(0.95)}"

        let variants: [(ButtonVariant, [(String, String)])] = [
            (.primary, [
                ("background", "var(--color-primary)"),
                ("color", "var(--color-surface)"),
            ]),
            (.secondary, [
                ("background", "var(--color-secondary)"),
                ("color", "var(--color-text)"),
            ]),
            (.ghost, [
                ("background", "transparent"),
                ("color", "var(--color-text)"),
            ]),
            (.destructive, [
                ("background", "var(--color-destructive)"),
                ("color", "var(--color-surface)"),
            ]),
            (.outline, [
                ("background", "transparent"),
                ("color", "var(--color-text)"),
                ("border-color", "var(--color-muted)"),
            ]),
            (.icon, [
                ("background", "transparent"),
                ("color", "var(--color-text)"),
                ("padding", "0.5rem"),
            ]),
        ]

        for (variant, declarations) in variants {
            let merged = mergeDeclarations(declarations, variantOverrides[variant] ?? [:])
            out += "button[data-variant=\"\(variant.rawValue)\"]{\(merged)}"
        }
        out += "button[data-variant=\"ghost\"]:hover:not(:disabled){background:var(--color-secondary)}"
        return out
    }
}

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
        self.color     = color
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
        var out = "a{\(mergeDeclarations(base, overrides))}"
        if underline == .hover {
            out += "a:hover{text-decoration:underline}"
        }
        out += "a[data-navlink][data-active=\"true\"]{color:var(--color-primary);font-weight:600}"
        return out
    }
}

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
        var out = "dialog[data-score-dialog]{\(mergeDeclarations(base, overrides))}"
        var backdropDecls = "background:\(backdrop)"
        if let blur = backdropBlur {
            backdropDecls += ";backdrop-filter:blur(\(blur.cssStr)px)"
        }
        out += "dialog[data-score-dialog]::backdrop{\(backdropDecls)}"
        return out
    }
}

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
        "input:not([type=\"checkbox\"]):not([type=\"radio\"]):not([type=\"range\"]):not([type=\"hidden\"]),select,textarea"

    public func css() -> String {
        let base: [(String, String)] = [
            ("font-family", "inherit"),
            ("font-size", "1rem"),
            ("color", "var(--color-text)"),
            ("background", background),
            ("border", "1px solid \(borderColor)"),
            ("border-radius", "var(--radius-\(radius.cssName))"),
            ("padding", padding),
        ]
        var out = "\(Self.selector){\(mergeDeclarations(base, overrides))}"
        out += "input:focus-visible,select:focus-visible,textarea:focus-visible{outline:2px solid \(focusColor);outline-offset:1px}"
        out += "input:disabled,select:disabled,textarea:disabled{opacity:0.5;cursor:not-allowed}"
        return out
    }
}

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
        return ".badge{\(mergeDeclarations(base, overrides))}"
    }
}

// MARK: - Declaration merging

/// Merge override declarations into an ordered list of base declarations.
///
/// Overrides replace base declarations with the same property in place;
/// properties not present in the base are appended in sorted order so the
/// output is deterministic.
func mergeDeclarations(_ base: [(String, String)], _ overrides: [String: String]) -> String {
    var pairs = base
    var remaining = overrides
    for index in pairs.indices {
        if let replacement = remaining.removeValue(forKey: pairs[index].0) {
            pairs[index].1 = replacement
        }
    }
    let extras = remaining.sorted { $0.key < $1.key }
    let all = pairs.map { "\($0.0):\($0.1)" } + extras.map { "\($0.key):\($0.value)" }
    return all.joined(separator: ";")
}
