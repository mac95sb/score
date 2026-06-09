import Foundation

/// Renders a `<time>` element with a machine-readable `datetime` attribute.
///
/// ```swift
/// TimeElement(post.publishedAt)
/// ```
public struct TimeElement: View, _HTMLRenderable {
    let date: Date

    public init(_ date: Date) {
        self.date = date
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        let iso = ISO8601DateFormatter().string(from: date)
        let display = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        return "<time datetime=\"\(attributeEscape(iso))\">\(htmlEscape(display))</time>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
