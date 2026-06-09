/// An abbreviation rendered as `<abbr title="...">`.
///
/// ```swift
/// Abbreviation("HTML", title: "HyperText Markup Language")
/// ```
public struct Abbreviation: View, _HTMLRenderable {
    let text: String
    let title: String

    public init(_ text: String, title: String) {
        self.text = text
        self.title = title
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<abbr title=\"\(attributeEscape(title))\">\(htmlEscape(text))</abbr>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
