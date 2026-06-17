// MARK: - Animation modifiers

extension View {

    /// Apply a CSS animation.
    public func animate(
        _ animation: Animation,
        duration: AnimationDuration,
        easing: AnimationTiming = .easeOut,
        delay: AnimationDuration = 0.ms,
        iterations: AnimationIterations = .once,
        fill: String = "both"
    ) -> ModifiedContent<Self, AnimationModifier> {
        modifier(AnimationModifier(
            animationName: animation.css,
            duration: duration,
            easing: easing,
            delay: delay,
            iterations: iterations,
            fillMode: fill
        ))
    }

    /// Apply a CSS transition on a property.
    public func animate(
        _ transition: TransitionProperty,
        duration: AnimationDuration,
        easing: AnimationTiming = .easeInOut,
        delay: AnimationDuration = 0.ms
    ) -> ModifiedContent<Self, TransitionModifier> {
        modifier(TransitionModifier(property: transition, duration: duration, easing: easing, delay: delay))
    }

    /// Stagger-animate all direct children on entry with a CSS animation.
    ///
    /// The container receives `data-score-stagger` for runtime JS hookup; the CSS
    /// emits `& > * { animation: … }` inside a `prefers-reduced-motion` guard.
    ///
    /// ```swift
    /// List { ... }.animateChildren(.fadeIn, duration: 300.ms, stagger: 80.ms)
    /// ```
    public func animateChildren(
        _ animation: Animation,
        duration: AnimationDuration = 300.ms,
        stagger: AnimationDuration = 100.ms,
        easing: AnimationTiming = .easeOut
    ) -> AnimateChildrenView<Self> {
        AnimateChildrenView(
            animationName: animation.css,
            duration: duration,
            stagger: stagger,
            easing: easing,
            content: self
        )
    }

    /// Mark a view for scroll-triggered animation using an Intersection Observer.
    ///
    /// Adds `data-score-aos` and `data-score-aos-threshold` HTML attributes so the
    /// Score JS runtime can apply the animation when the element enters the viewport.
    ///
    /// ```swift
    /// Card().animateOnScroll(.fadeUp, threshold: 0.15)
    /// ```
    public func animateOnScroll(
        _ animation: Animation,
        threshold: Double = 0.1
    ) -> AnimateOnScrollView<Self> {
        AnimateOnScrollView(
            animationName: animation.css,
            threshold: threshold,
            content: self
        )
    }

    /// Apply a CSS `view-transition-name` for the View Transitions API.
    ///
    /// ```swift
    /// heroImage.viewTransition("hero-image")
    /// ```
    public func viewTransition(_ name: String) -> ModifiedContent<Self, ViewTransitionModifier> {
        modifier(ViewTransitionModifier(name: name))
    }
}
