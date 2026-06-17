/// A greedy flex spacer that pushes siblings apart inside a flex container (`<div style="flex:1">`).
///
/// `Spacer` renders an invisible `<div>` with `flex: 1`, which causes it to
/// consume all remaining free space along the main axis of its flex parent.
/// Use it inside ``HStack`` or ``VStack`` to push content to opposite ends —
/// for example, a logo on the left and navigation links on the right of a
/// header, or a "cancel" and "confirm" pair at the bottom of a card.
///
/// ## Example
///
/// ```swift
/// // Push title to the left, buttons to the right
/// HStack {
///     Text { "My App" }
///     Spacer()
///     Link(to: "/login") { "Log in" }
///     Button(.primary) { "Sign up" }
/// }
/// .padding(x: 6, y: 4)
///
/// // Push action to the bottom of a card
/// VStack {
///     Heading(3) { "Pro plan" }
///     Text { "Unlimited projects and priority support." }
///     Spacer()
///     Button(.primary) { "Upgrade" }
/// }
/// .padding(6)
/// .frame(height: .px(240))
/// ```
///
/// ## HTML output
///
/// ```html
/// <div style="flex:1"></div>
/// ```
///
/// - SeeAlso: ``HStack``, ``VStack``, ``Divider``
public struct Spacer: View, _HTMLRenderable {
    public init() {}

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        "<div style=\"flex:1\"></div>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
