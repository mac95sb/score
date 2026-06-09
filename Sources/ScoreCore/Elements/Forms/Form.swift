/// The HTTP method used when submitting a `Form`.
public enum FormMethod: String, Sendable {
    case get
    case post
}

/// An HTML form element (`<form>`).
///
/// ```swift
/// Form(action: "/login", method: .post) {
///     Input(type: .email, name: "email", placeholder: "you@example.com")
///     Input(type: .password, name: "password")
///     Button(.submit, type: .submit) { "Log in" }
/// }
/// ```
public struct Form: View, _HTMLRenderable {
    let action: String?
    let method: FormMethod
    let content: AnyView

    public init(
        action: String? = nil,
        method: FormMethod = .post,
        @ViewBuilder content: () -> some View
    ) {
        self.action = action
        self.method = method
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = "method=\"\(method.rawValue)\""
        if let action = action { attrs += " action=\"\(attributeEscape(action))\"" }
        return "<form \(attrs)>\(content.renderHTML(context: &context))</form>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
