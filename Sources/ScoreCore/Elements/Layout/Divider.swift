/// The orientation of a `Divider`.
public enum DividerOrientation: String, Sendable {
    case horizontal
    case vertical
}

/// A horizontal or vertical dividing line.
///
/// Horizontal dividers render as `<hr>`. Vertical dividers render as a
/// thin `<div>` that stretches to fill the cross-axis of a flex container.
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
