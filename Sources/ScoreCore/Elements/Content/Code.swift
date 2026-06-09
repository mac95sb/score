/// An inline code element (`<code>`).
///
/// For multi-line code blocks, use `CodeBlock` instead.
public struct Code: View, _HTMLRenderable {
    let value: String

    public init(_ value: String) {
        self.value = value
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<code>\(htmlEscape(value))</code>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
