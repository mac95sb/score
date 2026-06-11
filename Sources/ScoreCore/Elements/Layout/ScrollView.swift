/// The scroll axis of a `ScrollView`.
public enum ScrollAxis: Sendable {
    case x
    case y
    case both
}

/// A scrollable container.
///
/// Scrolls in both directions by default. Restrict to one axis with `axis:`:
///
/// ```swift
/// ScrollView { … }               // x and y (default)
/// ScrollView(axis: .x) { … }    // horizontal only
/// ScrollView(axis: .y) { … }    // vertical only
/// ```
public struct ScrollView: View, _HTMLRenderable {
    let axis: ScrollAxis
    let content: AnyView

    public init(axis: ScrollAxis = .both, @ViewBuilder content: () -> some View) {
        self.axis = axis
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let overflow: String
        switch axis {
        case .y:    overflow = "overflow-y:auto"
        case .x:    overflow = "overflow-x:auto"
        case .both: overflow = "overflow:auto"
        }
        return "<div style=\"\(overflow)\">\(content.renderHTML(context: &context))</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
