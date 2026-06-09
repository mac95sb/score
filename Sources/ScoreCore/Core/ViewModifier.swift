/// A modifier that can be applied to a `View` to change its appearance or behaviour.
///
/// Modifiers accumulate in a chain; the CSS collector reads the full chain when
/// generating style rules for a component.
public protocol ViewModifier: Sendable {
    /// The CSS declarations this modifier contributes to the rendered element.
    func cssDeclarations() -> [CSSDeclaration]

    /// An optional CSS condition (pseudo-class or media query) that gates these
    /// declarations.  Returns `nil` for unconditional declarations.
    func cssCondition() -> CSSCondition?
}

// Default implementations so conformers only need to provide what is relevant.
extension ViewModifier {
    public func cssDeclarations() -> [CSSDeclaration] { [] }
    public func cssCondition() -> CSSCondition? { nil }
}
