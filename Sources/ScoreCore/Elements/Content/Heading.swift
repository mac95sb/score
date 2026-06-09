/// A section heading, mapping to `<h1>` through `<h6>`.
///
/// ```swift
/// Heading(1) { "Welcome to Score" }
///     .font(size: .fourXL)
///     .font(weight: .bold)
///     .font(wrap: .balance)
/// ```
public struct Heading: View, _HTMLRenderable {
    let level: Int
    let content: AnyView

    public init(_ level: Int, @ViewBuilder content: () -> some View) {
        precondition((1...6).contains(level), "Heading level must be 1–6")
        self.level = level
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<h\(level)>\(content.renderHTML(context: &context))</h\(level)>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
