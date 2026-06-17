/// The primary content area of a document (`<main>`).
///
/// Use `Main` once per page to wrap the content that is unique to that
/// page — everything except site-wide headers, footers, and sidebars. The
/// element carries the `main` ARIA landmark role, giving screen reader
/// users a direct shortcut to skip navigation and jump straight to the
/// page content.
///
/// There must be at most one `Main` element in the rendered document.
/// Placing more than one breaks accessibility — both the visual hierarchy
/// and landmark navigation become ambiguous.
///
/// ## Example
///
/// ```swift
/// // In your page body:
/// var body: some View {
///     Main {
///         Section(id: "hero") {
///             Heading(1) { "Welcome" }
///             Text { "Start building." }
///         }
///         Section(id: "features") {
///             // …
///         }
///     }
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <main>…</main>
/// ```
///
/// - SeeAlso: ``Header``, ``Footer``, ``Nav``, ``Section``, ``Article``
public struct Main: View, _HTMLRenderable {
    let content: AnyView

    public init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let (extra, cls, savedStack, savedCond) = context.takeStyles()
        var attrs = extra.isEmpty ? "" : " style=\"\(extra)\""
        if let cls { attrs += " class=\"\(cls)\"" }
        let result = "<main\(attrs)>\(content.renderHTML(context: &context))</main>"
        context.modifierStack = savedStack
        context.conditionOverride = savedCond
        return result
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
