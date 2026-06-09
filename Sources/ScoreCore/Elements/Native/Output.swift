/// The result of a calculation or user action (`<output>`).
///
/// ```swift
/// Output(for: "calculator") { "42" }
/// ```
public struct Output: View, _HTMLRenderable {
    let for_: String?
    let content: AnyView

    public init(for inputId: String? = nil, @ViewBuilder content: () -> some View) {
        self.for_ = inputId
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = ""
        if let f = for_ { attrs = " for=\"\(attributeEscape(f))\"" }
        return "<output\(attrs)>\(content.renderHTML(context: &context))</output>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
