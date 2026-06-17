/// The description (value) half of a term–description pair inside a ``DescriptionList`` (`<dd>`).
///
/// `Description` always follows one or more ``Term`` elements inside a
/// ``DescriptionList``. Together they form semantically paired key–value entries
/// that assistive technologies can navigate and announce as a group. A single
/// `Term` may be followed by multiple `Description` elements when one key maps
/// to several values.
///
/// - Parameters:
///   - content: The child views that form the description text or content.
///
/// ## Example
///
/// ```swift
/// DescriptionList {
///     Term { "Framework" }
///     Description { "Score" }
///
///     Term { "Language" }
///     Description { "Swift" }
///     Description { "HTML/CSS (output)" }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <dd>Score</dd>
/// ```
///
/// - SeeAlso: ``Term``, ``DescriptionList``
public struct Description: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<dd>\(content.renderHTML(context: &context))</dd>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
