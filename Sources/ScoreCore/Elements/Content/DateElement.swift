import Foundation

/// Controls how a `DateElement` formats its date value.
public enum DateFormat: Sendable {
    /// "Jan 15, 2026"
    case short
    /// "January 15, 2026"
    case long
    /// "3 days ago" (falls back to medium date for older dates)
    case relative
    /// "2026-01-15"
    case iso
    /// Any `DateFormatter` format string, e.g. `"dd/MM/yyyy"`.
    case custom(String)

    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch self {
        case .short:
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        case .long:
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter.string(from: date)
        case .iso:
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        case .relative:
            let interval = Date().timeIntervalSince(date)
            if interval < 60 { return "just now" }
            if interval < 3600 { return "\(Int(interval / 60)) minutes ago" }
            if interval < 86400 { return "\(Int(interval / 3600)) hours ago" }
            if interval < 604800 { return "\(Int(interval / 86400)) days ago" }
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        case .custom(let fmt):
            formatter.dateFormat = fmt
            return formatter.string(from: date)
        }
    }
}

/// Renders a `Date` as HTML text.
///
/// ```swift
/// DateElement(post.publishedAt, format: .long)
/// DateElement(post.publishedAt, format: .relative)
/// ```
public struct DateElement: View, _HTMLRenderable {
    let date: Date
    let format: DateFormat

    public init(_ date: Date, format: DateFormat = .short) {
        self.date = date
        self.format = format
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        htmlEscape(format.format(date))
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
