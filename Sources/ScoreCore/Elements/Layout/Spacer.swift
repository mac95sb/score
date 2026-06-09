/// A flexible spacer that expands to fill available space inside a flex container.
public struct Spacer: View, _HTMLRenderable {
    public init() {}

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<div style=\"flex:1\"></div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
