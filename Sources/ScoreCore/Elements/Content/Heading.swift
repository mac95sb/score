/// A section heading, mapping to `<h1>` through `<h6>`.
///
/// Headings create the document outline that screen readers, search engines,
/// and browser reading modes rely on. Use a single `Heading(1)` per page for
/// the primary title, then nest `Heading(2)` through `Heading(6)` as section
/// and sub-section labels — **do not skip levels** (e.g. jumping from `h2`
/// directly to `h4`) as this breaks the logical outline.
///
/// The *visual* size of a heading is independent of its semantic level. Use
/// `.font(size:)` and `.font(weight:)` modifiers to adjust appearance without
/// changing the hierarchy.
///
/// - Parameters:
///   - level: The heading level, `1` (most important) through `6` (least).
///     Levels outside this range trigger a precondition failure at runtime.
///   - content: The heading text or inline views.
///
/// ## Example
///
/// ```swift
/// Heading(1) { "Getting Started" }
///     .font(size: .fiveXL, weight: .bold, wrap: .balance)
///
/// Heading(2) { "Installation" }
///     .font(size: .threeXL, weight: .semibold)
///     .margin(top: 8, bottom: 4)
///
/// // Visual size can differ from semantic level
/// Heading(3) { post.title }
///     .font(size: .twoXL, weight: .bold)
/// ```
///
/// ## HTML output
///
/// ```html
/// <h1>Getting Started</h1>
/// <h2>Installation</h2>
/// ```
///
/// - SeeAlso: ``Text``, ``Section``
public struct Heading: View, _HTMLRenderable {
    let level: Int
    let content: AnyView

    public init(_ level: Int, @ViewBuilder content: () -> some View) {
        precondition((1...6).contains(level), "Heading level must be 1–6")
        self.level = level
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = extra.isEmpty ? "" : " style=\"\(extra)\""
        if let cls { attrs += " class=\"\(cls)\"" }
        let result = "<h\(level)\(attrs)>\(content.renderHTML(context: &context))</h\(level)>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
