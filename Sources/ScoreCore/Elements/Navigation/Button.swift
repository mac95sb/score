/// Visual variants for a `Button`.
public enum ButtonVariant: String, Sendable {
    case primary
    case secondary
    case ghost
    case destructive
    case icon
    case outline
}

/// The HTML `type` attribute for a `Button`.
public enum ButtonType: String, Sendable {
    case button
    case submit
    case reset
}

/// An interactive button element (`<button>`).
///
/// ```swift
/// Button(.primary) { "Get Started" }
/// Button(.destructive, disabled: true) { "Delete" }
/// Button(.submit, type: .submit) { "Save changes" }
/// ```
public struct Button: View, _HTMLRenderable {
    let variant: ButtonVariant
    let type: ButtonType
    let id: String?
    let disabled: Bool
    let content: AnyView

    public init(
        _ variant: ButtonVariant = .primary,
        type: ButtonType = .button,
        id: String? = nil,
        disabled: Bool = false,
        @ViewBuilder content: () -> some View
    ) {
        self.variant = variant
        self.type = type
        self.id = id
        self.disabled = disabled
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = "type=\"\(type.rawValue)\" data-variant=\"\(variant.rawValue)\""
        if let id = id { attrs += " id=\"\(attributeEscape(id))\"" }
        if disabled { attrs += " disabled" }
        return "<button \(attrs)>\(content.renderHTML(context: &context))</button>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
