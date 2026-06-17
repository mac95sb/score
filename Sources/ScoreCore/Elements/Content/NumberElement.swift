import Foundation

/// Controls how a ``NumberElement`` formats its numeric value for display.
public enum NumberFormat: Sendable {
    case decimal(places: Int)
    case currency(code: String)
    case percent(places: Int)
    case scientific

    /// Decimal with zero decimal places.
    public static let integer: NumberFormat = .decimal(places: 0)
    /// US dollar currency.
    public static let usd: NumberFormat = .currency(code: "USD")

    func format(_ value: Double) -> String {
        switch self {
        case .decimal(let places):
            return String(format: "%.\(places)f", value)
        case .percent(let places):
            return String(format: "%.\(places)f%%", value * 100)
        case .scientific:
            return String(format: "%e", value)
        case .currency(let code):
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.currencyCode = code
            return f.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }
}

/// Renders a numeric value as formatted HTML text.
///
/// Use `NumberElement` when you want locale-aware or precision-controlled
/// number rendering — decimal rounding, currency symbols, percentages, or
/// scientific notation — without writing the formatting logic yourself.
/// When no `format` is provided, the number's default `description` is used.
///
/// The formatted string is HTML-escaped before output, so it is safe to use
/// with any numeric value.
///
/// - Parameters:
///   - value: Any `Numeric & CustomStringConvertible` value (`Int`, `Double`, `Float`, etc.).
///   - format: How to format the number. Pass `nil` to use the value's default description.
///
/// ## Example
///
/// ```swift
/// HStack {
///     Text { "Price:" }
///     NumberElement(product.price, format: .currency(code: "USD"))
/// }
///
/// NumberElement(0.732, format: .percent(places: 1))   // "73.2%"
/// NumberElement(6.022e23, format: .scientific)         // "6.022000e+23"
/// NumberElement(1_000_000, format: .decimal(places: 0)) // "1000000"
/// ```
///
/// ## HTML output
///
/// ```html
/// $9.99
/// ```
///
/// - SeeAlso: ``DateElement``, ``TimeElement``, ``Text``
public struct NumberElement: View, _HTMLRenderable {
    let valueString: String

    public init<N: Numeric & CustomStringConvertible>(_ value: N, format: NumberFormat? = nil) {
        if let fmt = format {
            // Attempt to coerce to Double for formatting; fall back to description.
            let d: Double
            if let asDouble = value as? Double {
                d = asDouble
            } else if let asFloat = value as? Float {
                d = Double(asFloat)
            } else if let asInt = value as? Int {
                d = Double(asInt)
            } else {
                valueString = value.description
                return
            }
            valueString = fmt.format(d)
        } else {
            valueString = value.description
        }
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        htmlEscape(valueString)
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
