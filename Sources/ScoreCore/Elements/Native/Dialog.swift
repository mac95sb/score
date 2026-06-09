/// A native dialog element (`<dialog>`).
///
/// Score wires `showModal()` and `close()` via JS bindings when `isOpen` is
/// a `StateBinding`. The element renders as a `<dialog>` tag with a
/// `data-score-dialog` attribute that the runtime uses to attach behaviour.
///
/// ```swift
/// Dialog(isOpen: $isOpen) {
///     VStack { Text { "Are you sure?" } }
///         .padding(6)
/// }
/// .border(radius: .xl)
/// .shadow(.twoXL)
/// ```
public struct Dialog: View, _HTMLRenderable {
    let content: AnyView
    let modal: Bool

    public init(
        isOpen: StateBinding<Bool>? = nil,
        modal: Bool = true,
        @ViewBuilder content: () -> some View
    ) {
        self.content = AnyView(content())
        self.modal = modal
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<dialog data-score-dialog>\(content.renderHTML(context: &context))</dialog>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content.collectCSS(context: &context)
    }
}
