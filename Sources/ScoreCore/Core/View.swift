import Foundation

/// The fundamental building block of Score's view hierarchy.
///
/// Conform types to `View` to describe web content and layout using Swift.
/// Score renders the view tree to HTML, CSS, and JavaScript — nothing Swift
/// runs in the browser.
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
///     }
/// }
/// ```
public protocol View: Sendable {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

extension Swift.Never: View {
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError("unreachable") }
}

// MARK: - String literal support

extension String: @retroactive View {
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
