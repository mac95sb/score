/// An inline subscript run rendered below the baseline (`<sub>`).
///
/// Use `Subscript` for typographically correct subscript text such as chemical
/// formulas (H₂O), mathematical variables (xₙ), footnote markers, or other
/// content that conventionally sits below the baseline. Browsers render
/// `<sub>` in a smaller font size lowered relative to surrounding text.
///
/// - Parameters:
///   - content: The child views to render as subscript text.
///
/// ## Example
///
/// ```swift
/// Text {
///     "Water is H"
///     Subscript { "2" }
///     "O."
/// }
///
/// Text {
///     "CO"
///     Subscript { "2" }
///     " emissions fell by 12% last year."
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <sub>2</sub>
/// ```
///
/// - SeeAlso: ``Superscript``, ``Text``
public struct Subscript: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<sub>\(content.renderHTML(context: &context))</sub>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
