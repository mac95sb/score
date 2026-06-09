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
        content._renderInto(&context)
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        let saved = context.groupConditionOverride
        context.groupConditionOverride = condition
        content._collectCSSInto(&context)
        context.groupConditionOverride = saved
    }
}

// MARK: - View extension

extension View {
    /// Applies a modifier to this view, returning a `ModifiedContent` wrapping both.
    public func modifier<M: ViewModifier>(_ modifier: M) -> ModifiedContent<Self, M> {
        ModifiedContent(base: self, modifier: modifier)
    }
}
