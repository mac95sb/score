import Foundation

/// A flexible container that renders as a `<div>`.
///
/// Use `.flex()` to control direction, alignment, and spacing.
/// `HStack` and `VStack` are convenience wrappers.
///
/// ```swift
/// Stack {
///     Text { "Item 1" }
///     Text { "Item 2" }
/// }
/// .flex(direction: .horizontal, gap: 4)
/// ```
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
        var attrs = ""
        if let id = id { attrs += " id=\"\(attributeEscape(id))\"" }
        let inner = content.renderHTML(context: &context)
        return "<div\(attrs)>\(inner)</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
