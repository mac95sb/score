/// An inline code fragment (`<code>`).
///
/// Use `Code` to mark up a short piece of code or a technical term inline within
/// a sentence. For multi-line listings, use ``CodeBlock``.
///
/// Renders as `<code>`, which browsers style with a monospace font by default.
/// Apply `.font(family: .systemMono)` or a theme font to customise the typeface.
///
/// ## Example
///
/// ```swift
/// Text {
///     "Set the value with "
///     Code { "let x = 42" }
///     " before calling the function."
/// }
/// ```
///
/// - SeeAlso: ``CodeBlock``, ``Text``
public struct Code: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = extra.isEmpty ? "" : " style=\"\(extra)\""
        if let cls { attrs += " class=\"\(cls)\"" }
        let result = "<code\(attrs)>\(content.renderHTML(context: &context))</code>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
