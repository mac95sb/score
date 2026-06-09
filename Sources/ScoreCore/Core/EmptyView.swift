/// A view that renders nothing.
public struct EmptyView: View, _HTMLRenderable {
    public init() {}
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String { "" }
    public func collectCSS(context: inout CSSCollectionContext) {}
}
