// MARK: - Conditional modifiers (on, at)

extension View {

    /// Apply modifiers only under the given state condition (e.g. `.hover`, `.focus`).
    ///
    /// The closure receives `self` so callers can chain additional modifiers conditionally:
    /// ```swift
    /// Button { "Click" }.on(.hover) { $0.background(color: .violet(700)) }
    /// ```
    public func on(_ condition: ModifierCondition, @ViewBuilder content: (Self) -> some View) -> some View {
        ConditionGroupView(condition: condition, content: content(self))
    }

    /// Apply modifiers at the given responsive breakpoint.
    ///
    /// ```swift
    /// Card().at(.tablet) { $0.frame(width: .full) }
    /// ```
    public func at(_ breakpoint: ModifierCondition, @ViewBuilder content: (Self) -> some View) -> some View {
        ConditionGroupView(condition: breakpoint, content: content(self))
    }
}

