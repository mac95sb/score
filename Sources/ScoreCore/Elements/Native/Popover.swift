/// The anchor position of a ``Popover`` relative to its trigger element.
public enum PopoverAnchor: String, Sendable {
    case topStart    = "top-start"
    case top         = "top"
    case topEnd      = "top-end"
    case bottomStart = "bottom-start"
    case bottom      = "bottom"
    case bottomEnd   = "bottom-end"
    case leftStart   = "left-start"
    case left        = "left"
    case leftEnd     = "left-end"
    case rightStart  = "right-start"
    case right       = "right"
    case rightEnd    = "right-end"
}

/// A lightweight floating panel powered by the browser's native Popover API (`<div popover>`).
///
/// Use `Popover` for contextual UI that appears near a trigger element without
/// blocking the rest of the page — dropdown menus, tooltip details, action
/// sheets, or filter panels. Unlike ``Dialog``, a popover does not trap focus
/// and can be dismissed by clicking outside it (light dismiss). The browser
/// handles stacking, positioning in the top layer, and `Escape`-to-close.
///
/// Score's JS runtime reads the `data-popover-trigger` attribute and wires the
/// named ``Button``'s `popovertarget` so clicking the button toggles the panel.
/// The `anchor` parameter sets `data-anchor` which Score's CSS uses to position
/// the panel relative to its trigger via CSS Anchor Positioning (or a JS
/// fallback for older browsers).
///
/// - Parameters:
///   - id: The HTML `id` for this popover element. Auto-generated if omitted.
///   - triggeredBy: The `id` of the ``Button`` that opens this popover.
///   - anchor: Where to position the panel relative to its trigger. Defaults to `.bottomStart`.
///   - content: The child views rendered inside the floating panel.
///
/// ## Example
///
/// ```swift
/// Button(.secondary, id: "user-menu-btn") { "Account ▾" }
/// Popover(triggeredBy: "user-menu-btn", anchor: .bottomEnd) {
///     VStack(gap: 1) {
///         Link(to: "/settings") { "Settings" }
///         Link(to: "/billing")  { "Billing" }
///         Divider()
///         Button(.ghost) { "Sign out" }
///     }
///     .padding(2)
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <div popover data-popover-trigger="user-menu-btn" data-anchor="bottom-end">…</div>
/// ```
///
/// - SeeAlso: ``Dialog``, ``Button``, ``PopoverAnchor``
public struct Popover: View, _HTMLRenderable {
    let id: String?
    let triggeredBy: String?
    let anchor: PopoverAnchor
    let content: AnyView

    public init(
        id: String? = nil,
        triggeredBy: String? = nil,
        anchor: PopoverAnchor = .bottomStart,
        @ViewBuilder content: () -> some View
    ) {
        self.id = id
        self.triggeredBy = triggeredBy
        self.anchor = anchor
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = "popover"
        if let id = id { attrs += " id=\"\(attributeEscape(id))\"" }
        if let trigger = triggeredBy {
            attrs += " data-popover-trigger=\"\(attributeEscape(trigger))\""
        }
        attrs += " data-anchor=\"\(anchor.rawValue)\""
        return "<div \(attrs)>\(content.renderHTML(context: &context))</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
