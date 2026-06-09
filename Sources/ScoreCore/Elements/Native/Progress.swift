/// A progress bar element (`<progress>`).
///
/// Pass `value: nil` for an indeterminate (animated) progress bar.
///
/// ```swift
/// Progress(value: 0.7)          // 70 % of 1.0
/// Progress(value: 35, total: 100) // 35 %
/// Progress()                     // indeterminate
/// ```
public struct Progress: View, _HTMLRenderable {
    let value: Double?
    let total: Double

    public init(value: Double? = nil, total: Double = 1.0) {
        self.value = value
        self.total = total
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        if let value = value {
            return "<progress value=\"\(value)\" max=\"\(total)\"></progress>"
        }
        return "<progress></progress>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
