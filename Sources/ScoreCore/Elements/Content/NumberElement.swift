import Foundation

/// Controls how a `NumberElement` formats its numeric value.
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

/// Renders a numeric value as HTML text with optional formatting.
///
/// ```swift
/// NumberElement(3.14159, format: .decimal(places: 2))
/// NumberElement(9.99,    format: .currency(code: "USD"))
/// NumberElement(0.85,    format: .percent(places: 0))
/// ```
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
