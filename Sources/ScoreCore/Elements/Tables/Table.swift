/// A table element (`<table>`).
///
/// ```swift
/// Table(caption: "Monthly Sales") {
///     TableHeader {
///         TableRow {
///             TableCell(.header) { "Month" }
///             TableCell(.header) { "Revenue" }
///         }
///     }
///     TableBody {
///         TableRow {
///             TableCell { "January" }
///             TableCell { "$10,000" }
///         }
///     }
/// }
/// ```
public struct Table: View, _HTMLRenderable {
    let caption: String?
    let content: AnyView

    public init(caption: String? = nil, @ViewBuilder content: () -> some View) {
        self.caption = caption
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var inner = ""
        if let caption = caption {
            inner += "<caption>\(htmlEscape(caption))</caption>"
        }
        inner += content.renderHTML(context: &context)
        return "<table>\(inner)</table>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
