/// A scalar measurement within a known range (`<meter>`).
///
/// ```swift
/// Meter(value: 0.7)
/// Meter(value: 6, min: 0, max: 10, low: 3, high: 8, optimum: 9)
/// ```
public struct Meter: View, _HTMLRenderable {
    let value: Double
    let min: Double
    let max: Double
    let low: Double?
    let high: Double?
    let optimum: Double?

    public init(
        value: Double,
        min: Double = 0,
        max: Double = 1,
        low: Double? = nil,
        high: Double? = nil,
        optimum: Double? = nil
    ) {
        self.value = value
        self.min = min
        self.max = max
        self.low = low
        self.high = high
        self.optimum = optimum
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = "value=\"\(value)\" min=\"\(min)\" max=\"\(max)\""
        if let low = low     { attrs += " low=\"\(low)\"" }
        if let high = high   { attrs += " high=\"\(high)\"" }
        if let opt = optimum { attrs += " optimum=\"\(opt)\"" }
        return "<meter \(attrs)></meter>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
