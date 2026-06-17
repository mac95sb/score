/// The orientation of a ``Divider``.
public enum DividerOrientation: String, Sendable {
    case horizontal
    case vertical
}

/// A thin dividing line that separates content sections (`<hr>` or inline `<div>`).
///
/// Horizontal dividers render as the semantic `<hr>` element, which browsers
/// display as a full-width rule and screen readers announce as a thematic break.
/// Vertical dividers render as a `1px`-wide `<div>` that stretches to fill the
/// cross-axis of its flex parent — use them inside an ``HStack`` to separate
/// adjacent columns. Apply colour modifiers (`.font(color:)`) to change the
/// divider's colour since it inherits `currentColor`.
///
/// - Parameters:
///   - orientation: `.horizontal` (default) for an `<hr>`, `.vertical` for a thin flex separator.
///
/// ## Example
///
/// ```swift
/// VStack(gap: 6) {
///     Text { "Section one" }
///     Divider()
///     Text { "Section two" }
/// }
///
/// HStack(gap: 4) {
///     Link(to: "/terms") { "Terms" }
///     Divider(orientation: .vertical)
///     Link(to: "/privacy") { "Privacy" }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <hr>
/// <div style="width:1px;background:currentColor;align-self:stretch"></div>
/// ```
///
/// - SeeAlso: ``Spacer``, ``HStack``, ``VStack``
public struct Divider: View, _HTMLRenderable {
    let orientation: DividerOrientation

    public init(orientation: DividerOrientation = .horizontal) {
        self.orientation = orientation
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        if orientation == .vertical {
            return "<div style=\"width:1px;background:currentColor;align-self:stretch\"></div>"
        }
        return "<hr>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
