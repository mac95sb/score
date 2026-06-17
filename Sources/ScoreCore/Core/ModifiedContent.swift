/// A view combined with a modifier — the return type of all `.modifier()`, `.padding()`,
/// and similar calls.
///
/// The modifier is pushed onto the context stack before the base view is rendered,
/// and popped afterwards. This allows the CSS collector to see the full chain of
/// modifiers that applies to each element.
public struct ModifiedContent<Base: View, Modifier: ViewModifier>: View, _HTMLRenderable {
    public let base: Base
    public let modifier: Modifier

    public init(base: Base, modifier: Modifier) {
        self.base = base
        self.modifier = modifier
    }

    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        context.pushModifier(modifier)
        let html = base._renderInto(&context)
        context.popModifier()
        return html
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        if let themeAware = modifier as? any ThemeAwareModifier {
            // Use per-declaration conditions from ThemeAwareModifier for accurate conditional CSS.
            let condDecls = themeAware.declarations(theme: .default)
            let overrideCondition = context.groupConditionOverride
            for decl in condDecls {
                let effectiveCondition = decl.condition ?? overrideCondition
                context.record(
                    CSSDeclaration(decl.property, decl.value),
                    condition: effectiveCondition?.cssCondition(theme: .default)
                )
            }
        } else {
            let decls = modifier.cssDeclarations()
            if !decls.isEmpty {
                let explicit = modifier.cssCondition()
                let effective = explicit ?? context.groupConditionOverride?.cssCondition(theme: .default)
                context.record(decls, condition: effective)
            }
        }
        base._collectCSSInto(&context)
    }
}

// MARK: - ConditionGroupView

/// Wraps a view and applies a condition to all modifier CSS collected within it.
///
/// Created by `.at(_:content:)` and `.on(_:content:)` group helpers.
public struct ConditionGroupView<Content: View>: View, _HTMLRenderable {
    let condition: ModifierCondition
    let content: Content

    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let saved = context.conditionOverride
        context.conditionOverride = condition
        let result = content._renderInto(&context)
        context.conditionOverride = saved
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        let saved = context.groupConditionOverride
        context.groupConditionOverride = condition
        content._collectCSSInto(&context)
        context.groupConditionOverride = saved
    }
}

// MARK: - AnimateChildrenView

/// Wraps a view and stagger-animates its direct children.
///
/// Created by `.animateChildren(_:duration:stagger:easing:)`.
public struct AnimateChildrenView<Content: View>: View, _HTMLRenderable {
    let animationName: String
    let duration: AnimationDuration
    let stagger: AnimationDuration
    let easing: AnimationTiming
    let content: Content

    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let inner = content._renderInto(&context)
        return "<div data-score-stagger=\"\(stagger.css)\">\(inner)</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        let animValue = "\(animationName) \(duration.css) \(easing.css) both"
        let condition = CSSCondition.combined(
            pseudo: " > *",
            media: "(prefers-reduced-motion: no-preference)"
        )
        context.record(CSSDeclaration("animation", animValue), condition: condition)
        content._collectCSSInto(&context)
    }
}

// MARK: - AnimateOnScrollView

/// Wraps a view and marks it for scroll-triggered animation via an Intersection Observer.
///
/// Created by `.animateOnScroll(_:threshold:)`.
public struct AnimateOnScrollView<Content: View>: View, _HTMLRenderable {
    let animationName: String
    let threshold: Double
    let content: Content

    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let inner = content._renderInto(&context)
        return "<div data-score-aos=\"\(attributeEscape(animationName))\" data-score-aos-threshold=\"\(threshold)\">\(inner)</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content._collectCSSInto(&context)
    }
}

// MARK: - View extension

extension View {
    /// Applies a modifier to this view, returning a `ModifiedContent` wrapping both.
    public func modifier<M: ViewModifier>(_ modifier: M) -> ModifiedContent<Self, M> {
        ModifiedContent(base: self, modifier: modifier)
    }
}
