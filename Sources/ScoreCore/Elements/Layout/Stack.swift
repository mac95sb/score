import Foundation

/// A generic block container that renders as a `<div>`.
///
/// `Stack` is the foundational layout primitive. Use it when you need a
/// container without a pre-set flex direction, or when you want full control
/// over layout via modifiers. For the common horizontal and vertical cases,
/// prefer ``HStack`` and ``VStack`` for clarity.
///
/// Apply `.flex()` modifiers to control direction, alignment, wrapping, and
/// gap; apply `.grid()` to switch to a CSS grid context. ``Stack`` also
/// accepts the full range of spacing, border, background, and positioning
/// modifiers.
///
/// - Parameters:
///   - id: An optional HTML `id` attribute for anchor links or JavaScript targeting.
///   - content: The child views placed inside the container.
///
/// ## Example
///
/// ```swift
/// Stack {
///     Text { "Item 1" }
///     Text { "Item 2" }
///     Text { "Item 3" }
/// }
/// .flex(direction: .horizontal, wrap: .wrap, gap: 4)
/// .padding(6)
/// .border(radius: .lg)
/// .background(color: .secondary)
/// ```
///
/// ## HTML output
///
/// ```html
/// <div style="…">…</div>
/// ```
///
/// - SeeAlso: ``HStack``, ``VStack``, ``ZStack``, ``Grid``
public struct Stack: View, _HTMLRenderable {
    let content: AnyView
    let id: String?

    public init(id: String? = nil, @ViewBuilder content: () -> some View) {
        self.id = id
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = ""
        if let id = id { attrs += " id=\"\(attributeEscape(id))\"" }
        if !extra.isEmpty { attrs += " style=\"\(extra)\"" }
        if let cls { attrs += " class=\"\(cls)\"" }
        let inner = content.renderHTML(context: &context)
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return "<div\(attrs)>\(inner)</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
