/// A disclosure widget element (`<details>`).
///
/// Use `Summary` as the first child to provide the visible heading.
/// Set `isOpen: true` to render the details as expanded.
/// The optional `group` parameter maps to the `name` attribute, which browsers
/// use to limit open items to one per group (accordion behaviour).
///
/// ```swift
/// Details {
///     Summary { "What is Score?" }
///     Text { "Score is a Swift web framework." }
/// }
///
/// Details(isOpen: true, group: "faq") {
///     Summary { "Is it free?" }
///     Text { "Yes." }
/// }
/// ```
public struct Details: View, _HTMLRenderable {
    let isOpen: Bool
    let group: String?
    let content: AnyView

    public init(isOpen: Bool = false, group: String? = nil, @ViewBuilder content: () -> some View) {
        self.isOpen = isOpen
        self.group = group
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = ""
        if isOpen { attrs += " open" }
        if let group = group { attrs += " name=\"\(attributeEscape(group))\"" }
        return "<details\(attrs)>\(content.renderHTML(context: &context))</details>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
