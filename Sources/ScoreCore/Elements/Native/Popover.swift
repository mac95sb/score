/// The anchor position of a `Popover` relative to its trigger element.
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

/// A native Popover API element (`<div popover>`).
///
/// ```swift
/// Button(.secondary, id: "options-trigger") { "Options" }
/// Popover(triggeredBy: "options-trigger", anchor: .bottomStart) {
///     VStack {
///         Button(.ghost) { "Edit" }
///         Button(.ghost) { "Delete" }
///     }
/// }
/// ```
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
