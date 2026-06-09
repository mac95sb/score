/// A vertical stack — convenience wrapper for `Stack` with `flex-direction:column`.
public struct VStack: View, _HTMLRenderable {
    let content: AnyView
    let id: String?

    public init(id: String? = nil, @ViewBuilder content: () -> some View) {
        self.id = id
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = " style=\"display:flex;flex-direction:column\""
        if let id = id { attrs = " id=\"\(attributeEscape(id))\"\(attrs)" }
        return "<div\(attrs)>\(content.renderHTML(context: &context))</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
