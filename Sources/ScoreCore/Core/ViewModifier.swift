/// A type that modifies a ``View``'s CSS output.
///
/// Conformers contribute ``CSSDeclaration``s to the component's scoped CSS block.
/// The declarations are emitted inside the component's class selector, optionally
/// gated by a ``CSSCondition`` (pseudo-class, media query, or combined).
///
/// ## Implementing a Custom Modifier
///
/// ```swift
/// struct ContrastModifier: ViewModifier {
///     func cssDeclarations() -> [CSSDeclaration] {
///         [CSSDeclaration("color-scheme", "only light")]
///     }
/// }
///
/// extension View {
///     func highContrast() -> ModifiedContent<Self, ContrastModifier> {
///         modifier(ContrastModifier())
///     }
/// }
/// ```
///
/// For modifiers that only apply under a specific condition (hover, dark mode,
/// breakpoint), return a non-nil ``CSSCondition`` from ``cssCondition()``:
///
/// ```swift
/// struct HoverColorModifier: ViewModifier {
///     let color: Color
///     func cssDeclarations() -> [CSSDeclaration] {
///         [CSSDeclaration("color", color.cssValue)]
///     }
///     func cssCondition() -> CSSCondition? { .pseudoClass(":hover") }
/// }
/// ```
///
/// > Note: Prefer the built-in ``View/on(_:_:)`` closure form over creating a
/// > custom modifier for simple conditional overrides.
///
/// - SeeAlso: ``ThemeAwareModifier``, ``CSSCondition``, ``ModifiedContent``
public protocol ViewModifier: Sendable {
    /// The CSS declarations this modifier contributes to the rendered element.
    func cssDeclarations() -> [CSSDeclaration]

    /// An optional CSS condition that gates these declarations.
    ///
    /// Return `nil` for unconditional declarations. Return a ``CSSCondition``
    /// to nest the declarations inside a pseudo-class selector (`:hover`,
    /// `:focus-visible`) or media query block.
    func cssCondition() -> CSSCondition?
}

// Default implementations so conformers only need to provide what is relevant.
extension ViewModifier {
    public func cssDeclarations() -> [CSSDeclaration] { [] }
    public func cssCondition() -> CSSCondition? { nil }
}
