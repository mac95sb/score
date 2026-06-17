/// An extended quotation from another source (`<blockquote>`).
///
/// Use `Blockquote` to attribute a quoted passage to an external source —
/// a book excerpt, a testimonial, a pull quote in an article, or a cited
/// remark. The browser renders block quotations with default indentation;
/// Score's modifier API lets you apply border, padding, and colour styling
/// to suit your design.
///
/// For short inline quotations embedded in a sentence, use the HTML `<q>`
/// element directly via a custom ``View`` or embed the quotation as a
/// string inside ``Text``.
///
/// ## Example
///
/// ```swift
/// Blockquote {
///     Text { "Programs must be written for people to read, and only incidentally for machines to execute." }
///         .font(size: .lg, style: .italic, leading: .relaxed)
///     Text { "— Harold Abelson" }
///         .font(size: .sm, color: .muted)
///         .margin(top: 3)
/// }
/// .border(color: .primary, width: 4, edge: .left)
/// .padding(left: 6)
/// .margin(y: 6)
/// ```
///
/// ## HTML output
///
/// ```html
/// <blockquote>…</blockquote>
/// ```
///
/// - SeeAlso: ``Text``, ``RichText``
public struct Blockquote: View, _HTMLRenderable {
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
        let result = "<blockquote\(attrs)>\(content.renderHTML(context: &context))</blockquote>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
