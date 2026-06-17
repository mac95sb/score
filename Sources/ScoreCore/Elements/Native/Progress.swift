/// A task-completion progress bar (`<progress>`).
///
/// Use `Progress` to communicate how far along a task is — file upload,
/// multi-step onboarding, build pipeline, or download. When `value` is
/// provided the bar is determinate and browsers render a filled proportion of
/// the total. When `value` is `nil` the bar is indeterminate, showing an
/// animated looping indicator that conveys activity without a known end point.
///
/// For scalar measurements within a bounded range (battery, disk usage, skill
/// level), use ``Meter`` instead; `<meter>` carries richer semantic meaning
/// about whether the value is good, acceptable, or bad.
///
/// - Parameters:
///   - value: The current progress amount. Pass `nil` for an indeterminate bar. Defaults to `nil`.
///   - total: The maximum value representing 100 % completion. Defaults to `1.0`.
///
/// ## Example
///
/// ```swift
/// // Determinate: 3 of 5 steps done
/// VStack(gap: 1) {
///     Text { "Step 3 of 5" }
///     Progress(value: 3, total: 5)
/// }
///
/// // Indeterminate: upload in progress
/// VStack(gap: 1) {
///     Text { "Uploading…" }
///     Progress()
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <progress value="3" max="5"></progress>
/// <progress></progress>
/// ```
///
/// - SeeAlso: ``Meter``
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
