import Foundation

// MARK: - ConditionedDeclaration

/// A CSS property–value pair with an optional condition (hover, dark, breakpoint, etc.).
public struct ConditionedDeclaration: Sendable {
    public let property: String
    public let value: String
    public let condition: ModifierCondition?

    public init(_ property: String, _ value: String, condition: ModifierCondition? = nil) {
        self.property  = property
        self.value     = value
        self.condition = condition
    }
}

// MARK: - ModifierCondition

/// A condition that gates when CSS declarations are applied.
public enum ModifierCondition: Sendable, Hashable {
    // State variants (pseudo-classes)
    case hover
    case focus           // :focus-visible
    case active
    case visited
    case disabled
    case checked
    case required
    case invalid
    case valid
    case empty
    case first
    case last
    case odd
    case even
    case backdrop
    // Media queries
    case dark            // prefers-color-scheme: dark
    case print
    case motion          // prefers-reduced-motion: no-preference
    case portrait
    case landscape
    // Responsive breakpoints
    case phone
    case tablet
    case desktop
    case wide
    case ultrawide
    // Combined state + breakpoint
    indirect case combined(state: ModifierCondition, breakpoint: ModifierCondition)

    // MARK: CSS pseudo-class

    /// CSS pseudo-class or pseudo-element selector string.
    public var pseudoClass: String? {
        switch self {
        case .hover:     return ":hover"
        case .focus:     return ":focus-visible"
        case .active:    return ":active"
        case .visited:   return ":visited"
        case .disabled:  return ":disabled"
        case .checked:   return ":checked"
        case .required:  return ":required"
        case .invalid:   return ":invalid"
        case .valid:     return ":valid"
        case .empty:     return ":empty"
        case .first:     return ":first-child"
        case .last:      return ":last-child"
        case .odd:       return ":nth-child(odd)"
        case .even:      return ":nth-child(even)"
        case .backdrop:  return "::backdrop"
        default:         return nil
        }
    }

    // MARK: CSS media query

    /// CSS media query condition string (without `@media`).
    public func mediaQuery(theme: SiteTheme) -> String? {
        switch self {
        case .dark:       return "(prefers-color-scheme:dark)"
        case .print:      return "print"
        case .motion:     return "(prefers-reduced-motion:no-preference)"
        case .portrait:   return "(orientation:portrait)"
        case .landscape:  return "(orientation:landscape)"
        case .phone:      return "(min-width:\(theme.breakpoints.phone)px)"
        case .tablet:     return "(min-width:\(theme.breakpoints.tablet)px)"
        case .desktop:    return "(min-width:\(theme.breakpoints.desktop)px)"
        case .wide:       return "(min-width:\(theme.breakpoints.wide)px)"
        case .ultrawide:  return "(min-width:\(theme.breakpoints.ultrawide)px)"
        default:          return nil
        }
    }

    // MARK: CSSCondition bridge

    /// Convert this `ModifierCondition` into the existing `CSSCondition` type used
    /// by the rendering infrastructure.
    public func cssCondition(theme: SiteTheme) -> CSSCondition? {
        switch self {
        case .combined(let state, let bp):
            guard let media = bp.mediaQuery(theme: theme),
                  let pseudo = state.pseudoClass else { return nil }
            return .combined(pseudo: pseudo, media: media)
        default:
            if let pseudo = pseudoClass {
                return .pseudoClass(pseudo)
            }
            if let media = mediaQuery(theme: theme) {
                return .mediaQuery(media)
            }
            return nil
        }
    }
}

// MARK: - ThemeAwareModifier protocol

/// A modifier that uses the site theme to produce CSS declarations.
///
/// All new Score modifiers conform to both `ViewModifier` (the existing
/// infrastructure protocol) and `ThemeAwareModifier` (which carries the
/// richer `ConditionedDeclaration` API described in the PRD).
///
/// The `ViewModifier` conformance is provided automatically via the
/// extension below using the default theme; the real CSS is generated
/// per-theme during the build phase via `declarations(theme:)`.
public protocol ThemeAwareModifier: ViewModifier {
    /// Generate CSS declarations for this modifier given the active theme.
    func declarations(theme: SiteTheme) -> [ConditionedDeclaration]
}

extension ThemeAwareModifier {
    // MARK: ViewModifier default implementation

    /// Satisfy the existing `ViewModifier` protocol using the default theme.
    public func cssDeclarations() -> [CSSDeclaration] {
        declarations(theme: .default).map {
            CSSDeclaration($0.property, $0.value)
        }
    }

    /// Return the first condition found, converted via the default theme.
    public func cssCondition() -> CSSCondition? {
        declarations(theme: .default).compactMap {
            $0.condition?.cssCondition(theme: .default)
        }.first
    }
}
