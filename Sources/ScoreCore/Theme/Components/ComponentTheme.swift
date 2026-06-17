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
///     return theme
/// }
/// ```
///
/// The default value on ``SiteTheme`` is ``ComponentTheme/none``, which emits
/// no CSS at all — existing sites are unaffected until they opt in.
///
/// > Note: There is intentionally no raw `customCSS`/`customJS`/`customHTML`
/// > escape hatch while Score is being dogfooded pre-launch. Styling is
/// > expressed through the structured `overrides` dictionaries only.
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
        badge: BadgeTheme? = nil
    ) {
        self.button = button
        self.link   = link
        self.dialog = dialog
        self.input  = input
        self.badge  = badge
    }

    /// Emit the combined component CSS, or an empty string when nothing is enabled.
    public func css() -> String {
        var out = ""
        if let button { out += button.css() }
        if let link   { out += link.css() }
        if let dialog { out += dialog.css() }
        if let input  { out += input.css() }
        if let badge  { out += badge.css() }
        return out
    }
}

// MARK: - Declaration merging

/// Merge override declarations into an ordered list of base declarations.
///
/// Overrides replace base declarations with the same property in place;
/// properties not present in the base are appended in sorted order so the
/// output is deterministic. All properties and values are sanitised so a
/// value can never escape its declaration context (no raw-CSS injection).
func mergeDeclarations(_ base: [(String, String)], _ overrides: [String: String]) -> String {
    var pairs = base
    var remaining = overrides
    for index in pairs.indices {
        if let replacement = remaining.removeValue(forKey: pairs[index].0) {
            pairs[index].1 = replacement
        }
    }
    let extras = remaining.sorted { $0.key < $1.key }
    let all = pairs.map { ($0.0, $0.1) } + extras.map { ($0.key, $0.value) }
    return all
        .map { "\(cssPropertySanitize($0.0)):\(cssValueSanitize($0.1))" }
        .joined(separator: ";")
}

// MARK: - CSS sanitisation

/// Strip characters that would let a CSS value escape its declaration
/// (`{`, `}`, `;`). Part of the pre-launch "no customCSS" guarantee: theme
/// strings can only ever express a single declaration value.
func cssValueSanitize(_ value: String) -> String {
    value.filter { $0 != "{" && $0 != "}" && $0 != ";" }
}

/// Restrict a CSS property or custom-property name to identifier characters.
func cssPropertySanitize(_ name: String) -> String {
    name.filter { ($0.isLetter && $0.isASCII) || $0.isNumber || $0 == "-" || $0 == "_" }
}

/// Restrict a string that is interpolated into a CSS *selector* (e.g. a
/// `[data-theme="…"]` attribute value) to identifier characters, so it cannot
/// close the attribute/selector and inject new rules.
func cssIdentifierSanitize(_ name: String) -> String {
    cssPropertySanitize(name)
}
