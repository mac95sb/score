/// An inline superscript run rendered above the baseline (`<sup>`).
///
/// Use `Superscript` for typographically correct superscript text such as
/// ordinal suffixes (1ˢᵗ, 2ⁿᵈ), footnote references¹, mathematical exponents
/// (x²), or trademark symbols. Browsers render `<sup>` in a smaller font size
/// raised relative to the surrounding text baseline.
///
/// - Parameters:
///   - content: The child views to render as superscript text.
///
/// ## Example
///
/// ```swift
/// Text {
///     "E = mc"
///     Superscript { "2" }
/// }
///
/// Text {
///     "See footnote"
///     Superscript { "1" }
///     " for details."
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <sup>2</sup>
/// ```
///
/// - SeeAlso: ``Subscript``, ``Text``
public struct Superscript: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<sup>\(content.renderHTML(context: &context))</sup>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
