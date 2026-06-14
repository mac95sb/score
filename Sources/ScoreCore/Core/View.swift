import Foundation

/// The fundamental building block of Score's view hierarchy.
///
/// Conform any struct to `View` to create a reusable component. Score renders
/// the view tree to HTML, CSS, and JavaScript at build time (static) or
/// request time (server-rendered). Nothing Swift runs in the browser.
///
/// ```swift
/// struct ArticleCard: View {
///     let post: Post
///     var body: some View {
///         VStack {
///             Heading(3) { post.title }
///             Text { post.excerpt }.font(color: .muted)
///         }
///         .padding(6)
///         .border(radius: .lg)
///         .on(.hover) { $0.shadow(.md).translate(y: .px(-2)) }
///     }
/// }
/// ```
///
/// ## Conforming to View
///
/// Declare a `body` property that returns `some View`:
///
/// ```swift
/// struct MyComponent: View {
///     let title: String
///     var body: some View {
///         Heading(2) { title }.font(weight: .semibold)
///     }
/// }
/// ```
///
/// ## String Literals as Views
///
/// `String` conforms to `View` — pass string literals directly inside any
/// ``ViewBuilder`` closure without a wrapping element:
///
/// ```swift
/// Heading(1) { "Hello World" }
/// Text { "Welcome, \(user.name)" }
/// ```
///
/// ## CSS Scoping
///
/// Score derives a CSS class from the Swift type name using kebab-case.
/// `ArticleCard` → `.article-card`. Every modifier call on the view nests
/// inside that class block in the generated CSS. Child components (separate
/// `View` structs) are their own scope.
///
/// - SeeAlso: ``Page``, ``ViewModifier``, ``ModifiedContent``
public protocol View: Sendable {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

extension Swift.Never: View {
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError("unreachable") }
}

// MARK: - String literal support

extension String: View {
    public typealias Body = _StringView
    public var body: _StringView { _StringView(text: self) }
}

/// Internal view wrapping a string literal.
public struct _StringView: View, _HTMLRenderable {
    let text: String
    public init(text: String) { self.text = text }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        htmlEscape(text)
    }
    public func collectCSS(context: inout CSSCollectionContext) {}
}
