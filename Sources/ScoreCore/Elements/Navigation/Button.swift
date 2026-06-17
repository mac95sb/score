/// The visual style variant for a ``Button``, rendered via `data-variant` for CSS targeting.
public enum ButtonVariant: String, Sendable {
    case primary
    case secondary
    case ghost
    case destructive
    case icon
    case outline
}

/// The HTML `type` attribute for a ``Button``, controlling form submission behaviour.
public enum ButtonType: String, Sendable {
    case button
    case submit
    case reset
}

/// An interactive button element that triggers actions or submits forms (`<button>`).
///
/// Use `Button` for any clickable action that does not navigate to a new URL.
/// For navigation, use ``Link`` or ``NavLink`` instead — using a `<button>` for
/// navigation is an accessibility antipattern.
///
/// The `variant` controls the visual style via a `data-variant` attribute:
/// - `.primary` — the main call-to-action; use sparingly per page.
/// - `.secondary` — a less prominent alternative action.
/// - `.ghost` — minimal chrome, suitable for icon buttons or inline actions.
/// - `.outline` — a bordered, unfilled button.
/// - `.destructive` — signals an irreversible action (delete, remove).
/// - `.icon` — square proportions for icon-only buttons; pair with an `aria-label`.
///
/// Set `type: .submit` inside a ``Form`` to submit it. Set `type: .reset` to
/// clear all form fields. The default `type: .button` prevents accidental form
/// submission.
///
/// - Parameters:
///   - variant: The visual style. Defaults to `.primary`.
///   - type: The HTML button type. Defaults to `.button`.
///   - id: An optional HTML `id` attribute (useful for Popover trigger wiring).
///   - disabled: When `true`, the button is inert and greyed out. Defaults to `false`.
///   - content: The button's visible label or icon content.
///
/// ## Example
///
/// ```swift
/// // Call-to-action
/// Button(.primary) { "Get started" }
///
/// // Danger confirmation
/// Button(.destructive) { "Delete account" }
///
/// // Form submission
/// Form(action: "/subscribe", method: .post) {
///     Input(type: .email, name: "email", placeholder: "you@example.com")
///     Button(.primary, type: .submit) { "Subscribe" }
/// }
///
/// // Icon button with accessible label
/// Button(.icon) { "🔍" }
///     .attribute("aria-label", "Search")
/// ```
///
/// ## HTML output
///
/// ```html
/// <button type="button" data-variant="primary">Get started</button>
/// ```
///
/// - SeeAlso: ``Link``, ``NavLink``, ``Form``, ``ButtonVariant``
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
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = "type=\"\(type.rawValue)\" data-variant=\"\(variant.rawValue)\""
        if let id = id { attrs += " id=\"\(attributeEscape(id))\"" }
        if disabled { attrs += " disabled" }
        if !extra.isEmpty { attrs += " style=\"\(extra)\"" }
        if let cls { attrs += " class=\"\(cls)\"" }
        let result = "<button \(attrs)>\(content.renderHTML(context: &context))</button>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
