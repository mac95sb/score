// MARK: - AnimationModifier

/// Applies a CSS animation to an element.
///
/// The animation is automatically gated with `@media (prefers-reduced-motion: no-preference)`
/// to respect user accessibility preferences.
public struct AnimationModifier: ThemeAwareModifier {
    let animationName: String
    let duration: AnimationDuration
    let easing: AnimationTiming
    let delay: AnimationDuration
    let iterations: AnimationIterations
    let fillMode: String

    public init(
        animationName: String,
        duration: AnimationDuration,
        easing: AnimationTiming = .easeOut,
        delay: AnimationDuration = 0.ms,
        iterations: AnimationIterations = .once,
        fillMode: String = "both"
    ) {
        self.animationName = animationName
        self.duration = duration
        self.easing = easing
        self.delay = delay
        self.iterations = iterations
        self.fillMode = fillMode
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        let value = [
            animationName,
            duration.css,
            easing.css,
            delay.css,
            iterations.css,
            fillMode,
        ].joined(separator: " ")
        return [ConditionedDeclaration("animation", value, condition: .motion)]
    }
}

// MARK: - ViewTransitionModifier

/// Applies a CSS `view-transition-name` to an element for View Transitions API support.
public struct ViewTransitionModifier: ViewModifier {
    let name: String
    public init(name: String) { self.name = name }
    public func cssDeclarations() -> [CSSDeclaration] {
        [CSSDeclaration("view-transition-name", name)]
    }
    public func cssCondition() -> CSSCondition? { nil }
}

// MARK: - TransitionModifier

/// Applies a CSS transition to an element, optionally gated by a condition.
public struct TransitionModifier: ThemeAwareModifier {
    let property: TransitionProperty
    let duration: AnimationDuration
    let easing: AnimationTiming
    let delay: AnimationDuration
    let condition: ModifierCondition?

    public init(
        property: TransitionProperty,
        duration: AnimationDuration,
        easing: AnimationTiming = .easeInOut,
        delay: AnimationDuration = 0.ms,
        condition: ModifierCondition? = nil
    ) {
        self.property = property
        self.duration = duration
        self.easing = easing
        self.delay = delay
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        let value: String
        if delay.ms == 0 {
            value = "\(property.css) \(duration.css) \(easing.css)"
        } else {
            value = "\(property.css) \(duration.css) \(easing.css) \(delay.css)"
        }
        return [ConditionedDeclaration("transition", value, condition: condition)]
    }
}
