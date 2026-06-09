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
        context.pushModifier(modifier)
        base._collectCSSInto(&context)
        context.popModifier()
    }
}

// MARK: - View extension

extension View {
    /// Applies a modifier to this view, returning a `ModifiedContent` wrapping both.
    public func modifier<M: ViewModifier>(_ modifier: M) -> ModifiedContent<Self, M> {
        ModifiedContent(base: self, modifier: modifier)
    }
}
