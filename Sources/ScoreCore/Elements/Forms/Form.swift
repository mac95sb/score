/// The HTTP method used when submitting a ``Form``.
public enum FormMethod: String, Sendable {
    case get
    case post
}

/// An HTML form container that groups inputs and submits data to a server (`<form>`).
///
/// Use `Form` as the top-level container whenever you need to collect user
/// input and post it to a URL. The `action` is the submission endpoint and
/// `method` controls whether data is sent as query parameters (`.get`) or a
/// request body (`.post`). Omitting `action` submits to the current URL.
///
/// Place ``Input``, ``Label``, ``Fieldset``, ``Button``, and other form
/// elements as children. Always pair each ``Input`` with a visible ``Label``
/// (or use `aria-label`) so that assistive technologies can identify controls.
///
/// - Parameters:
///   - action: The URL that receives the form submission. `nil` submits to the current URL.
///   - method: The HTTP method (`.get` or `.post`). Defaults to `.post`.
///   - content: The child form controls.
///
/// ## Example
///
/// ```swift
/// Form(action: "/login", method: .post) {
///     VStack(gap: 4) {
///         Label(for: "email") { "Email" }
///         Input(type: .email, name: "email", placeholder: "you@example.com", required: true)
///         Label(for: "password") { "Password" }
///         Input(type: .password, name: "password", required: true)
///         Button(.primary, type: .submit) { "Log in" }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <form method="post" action="/login">…</form>
/// ```
///
/// - SeeAlso: ``Input``, ``Label``, ``Fieldset``, ``Button``
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
