/// The term (key) half of a term–description pair inside a ``DescriptionList`` (`<dt>`).
///
/// `Term` labels the concept being defined or described. Always follow it with
/// one or more ``Description`` elements inside a ``DescriptionList``. Browsers
/// render `<dt>` in bold by default. One `Term` may introduce multiple
/// ``Description`` siblings when a single concept has several values.
///
/// - Parameters:
///   - content: The child views that form the term text.
///
/// ## Example
///
/// ```swift
/// DescriptionList {
///     Term { "License" }
///     Description { "MIT" }
///
///     Term { "Platforms" }
///     Description { "macOS 14+" }
///     Description { "Linux (Swift 6+)" }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <dt>License</dt>
/// ```
///
/// - SeeAlso: ``Description``, ``DescriptionList``
public struct Term: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<dt>\(content.renderHTML(context: &context))</dt>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
