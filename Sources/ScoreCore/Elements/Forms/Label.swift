/// A form label element (`<label>`).
///
/// Associate a label with an input by passing the input's `id` to `for`.
///
/// ```swift
/// Label(for: "email") { "Email address" }
/// Input(type: .email, name: "email")
/// ```
public struct Label: View, _HTMLRenderable {
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
        return "<label\(attrs)>\(content.renderHTML(context: &context))</label>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
