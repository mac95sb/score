import Foundation

/// A semantic time element with a machine-readable `datetime` attribute (`<time>`).
///
/// Use `TimeElement` whenever you display a date or time that has semantic
/// significance — publication dates, event times, deadlines, or timestamps.
/// The element renders its ISO 8601 datetime in the `datetime` attribute
/// (which search engines, calendar apps, and assistive technologies can parse)
/// and a localised, human-readable string as the visible text.
///
/// For pure display formatting without semantic markup, use ``DateElement``
/// instead. For arbitrary time strings outside of a full `Date` value, write
/// a raw `<time>` string using ``Text`` with a `datetime` attribute set via
/// `.attribute(_:_:)`.
///
/// - Parameters:
///   - date: The `Date` value to display and encode.
///
/// ## Example
///
/// ```swift
/// Article {
///     Heading(1) { post.title }
///     HStack {
///         Text { "Published on" }
///         TimeElement(post.publishedAt)
///     }
///     .font(size: .sm, color: .muted)
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <time datetime="2026-01-15T00:00:00Z">Jan 15, 2026</time>
/// ```
///
/// - SeeAlso: ``DateElement``, ``NumberElement``, ``Article``
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
