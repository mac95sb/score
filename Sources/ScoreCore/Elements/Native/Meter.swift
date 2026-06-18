/// A scalar gauge representing a value within a known, bounded range (`<meter>`).
///
/// Use `Meter` for measurements that have both a minimum and a maximum, and
/// where the current value can be semantically good, suboptimal, or bad —
/// disk usage, battery level, skill ratings, or poll results. Browsers render
/// a native gauge bar and shade it green, yellow, or red based on how `value`
/// relates to the `low`, `high`, and `optimum` thresholds.
///
/// `Meter` is distinct from ``Progress``: use ``Progress`` for task completion
/// (where only a maximum and current value matter), and `Meter` for a scalar
/// measurement that has meaning across its full range.
///
/// - Parameters:
///   - value: The current measurement value.
///   - min: The lower bound of the range. Defaults to `0`.
///   - max: The upper bound of the range. Defaults to `1`.
///   - low: The threshold below which the value is considered "low". Optional.
///   - high: The threshold above which the value is considered "high". Optional.
///   - optimum: The optimal value within the range. Influences colour shading. Optional.
///
/// ## Example
///
/// ```swift
/// // Disk usage gauge — red when > 80 %
/// VStack(gap: 1) {
///     Text { "Storage used: 7.2 GB of 10 GB" }
///     Meter(value: 7.2, min: 0, max: 10, low: 3, high: 8, optimum: 2)
/// }
///
/// // Simple 0–1 fraction
/// Meter(value: 0.65)
/// ```
///
/// ## HTML output
///
/// ```html
/// <meter value="7.2" min="0" max="10" low="3" high="8" optimum="2"></meter>
/// ```
///
/// - SeeAlso: ``Progress``, ``NumberElement``
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
        if let low = low { attrs += " low=\"\(low)\"" }
        if let high = high { attrs += " high=\"\(high)\"" }
        if let opt = optimum { attrs += " optimum=\"\(opt)\"" }
        return "<meter \(attrs)></meter>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
