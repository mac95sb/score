extension View {
    /// Erase the static type, returning an `AnyView` suitable for use in
    /// `ContentTheme` closures and other contexts that work with `any View`.
    ///
    /// ```swift
    /// paragraph: { v in
    ///     v.erased().font(leading: .relaxed).margin(y: .rem(0.75))
    /// }
    /// ```
    public func erased() -> AnyView { AnyView(self) }
}

/// A type-erased wrapper around any `View`.
///
/// Stores render and CSS closures capturing the concrete view so the concrete
/// type does not need to be known at the call site.
public struct AnyView: View, _HTMLRenderable {
    private let _render: @Sendable (inout RenderContext) -> String
    private let _css: @Sendable (inout CSSCollectionContext) -> Void

    public init<V: View>(_ view: V) {
        if let r = view as? any _HTMLRenderable {
            _render = { ctx in r.renderHTML(context: &ctx) }
            _css = { ctx in r.collectCSS(context: &ctx) }
        } else {
            let b = view.body
            _render = { ctx in b._renderInto(&ctx) }
            _css = { ctx in b._collectCSSInto(&ctx) }
        }
    }

    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String { _render(&context) }
    public func collectCSS(context: inout CSSCollectionContext) { _css(&context) }
}
