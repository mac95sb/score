/// The scroll axis of a `ScrollView`.
public enum ScrollAxis: Sendable {
    case vertical
    case horizontal
    case both
}

/// A scrollable container.
///
/// ```swift
/// ScrollView {
///     ForEach(items) { item in ItemRow(item: item) }
/// }
/// ```
public struct ScrollView: View, _HTMLRenderable {
    let axis: ScrollAxis
    let content: AnyView

    public init(axis: ScrollAxis = .vertical, @ViewBuilder content: () -> some View) {
        self.axis = axis
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let overflow: String
        switch axis {
        case .vertical:   overflow = "overflow-y:auto"
        case .horizontal: overflow = "overflow-x:auto"
        case .both:       overflow = "overflow:auto"
        }
        return "<div style=\"\(overflow)\">\(content.renderHTML(context: &context))</div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
