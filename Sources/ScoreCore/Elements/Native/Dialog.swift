/// A native modal or non-modal dialog powered by the HTML `<dialog>` element.
///
/// `Dialog` uses the browser's built-in `<dialog>` API which provides focus
/// trapping, an accessible modal role, `Escape`-to-close keyboard handling, and
/// a native `::backdrop` pseudo-element for the overlay. Score attaches the
/// `data-score-dialog` attribute so its JS runtime can wire `showModal()` and
/// `close()` to the bound state.
///
/// Pass `modal: false` to use `show()` instead of `showModal()` for a
/// non-blocking, non-trapping dialog (e.g. a notification panel).
///
/// - Parameters:
///   - isOpen: A `StateBinding<Bool>` that controls whether the dialog is open.
///   - modal: When `true` (default), the dialog is opened with `showModal()`,
///     which traps focus and adds an inert overlay behind it. Set to `false` for
///     a non-modal dialog.
///   - content: The child views rendered inside the dialog.
///
/// ## Example
///
/// ```swift
/// @State var showConfirm = false
///
/// Button(.destructive) { "Delete account" }
///     .onClick { showConfirm = true }
///
/// Dialog(isOpen: $showConfirm) {
///     VStack(gap: 4) {
///         Heading(2) { "Delete account?" }
///         Text { "This action cannot be undone." }
///         HStack(gap: 2) {
///             Button(.secondary) { "Cancel" }
///             Button(.destructive, type: .submit) { "Delete" }
///         }
///     }
///     .padding(6)
/// }
/// .border(radius: .xl)
/// .shadow(.twoXL)
/// ```
///
/// ## HTML output
///
/// ```html
/// <dialog data-score-dialog>…</dialog>
/// ```
///
/// - SeeAlso: ``Popover``, ``Button``
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
