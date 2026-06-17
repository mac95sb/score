/// A container that layers its children on top of one another using CSS positioning (`<div>`).
///
/// `ZStack` renders a `position: relative` wrapper `<div>`. Children that need
/// to physically overlay one another should use `.position(.absolute)` along
/// with `.inset()` or `.offset()` modifiers to place them within the stack.
/// The first child in the closure sits at the bottom of the visual stack; later
/// children appear above earlier ones in z-order.
///
/// Common uses: image overlays, badge indicators on icons, text over a hero
/// background, or tooltip/popover anchors.
///
/// - Parameters:
///   - content: The child views to layer. Add `.position(.absolute)` on
///     children that should overlay the base layer.
///
/// ## Example
///
/// ```swift
/// ZStack {
///     Image("/hero.jpg", alt: "Mountain landscape")
///         .frame(width: .full, height: .px(400))
///
///     VStack {
///         Heading(1) { "Explore the peaks" }
///         Button(.primary) { "Book now" }
///     }
///     .position(.absolute)
///     .inset(bottom: 0)
///     .padding(8)
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <div style="position:relative">…</div>
/// ```
///
/// - SeeAlso: ``Stack``, ``HStack``, ``VStack``
public struct ZStack: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var style = "position:relative"
        if !extra.isEmpty { style += ";\(extra)" }
        var zAttrs = " style=\"\(style)\""
        if let cls { zAttrs += " class=\"\(cls)\"" }
        let result = "<div\(zAttrs)>\(content.renderHTML(context: &context))</div>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
