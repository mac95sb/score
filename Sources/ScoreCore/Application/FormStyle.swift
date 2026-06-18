import Foundation

/// Styling configuration for forms rendered via `FormView`.
///
/// Each property is a closure that wraps a view, letting you apply modifiers
/// or swap in a completely different layout for labels, inputs, and error messages.
///
/// ```swift
/// let myFormStyle = FormStyle(
///     fieldWrapper: { v in AnyView(v.padding(4)) },
///     label:        { v in AnyView(v.font(weight: .semibold)) }
/// )
/// ```
public struct FormStyle: Sendable {
    /// A closure that wraps any view (used for field wrappers, labels, etc.).
    public typealias FieldWrapperStyle = @Sendable (any View) -> any View
    /// A closure that wraps an input view given its current interaction state.
    public typealias InputStyle = @Sendable (InputState, any View) -> any View

    /// Wraps the entire field group (label + input + error message).
    public var fieldWrapper: FieldWrapperStyle
    /// Wraps the field label.
    public var label: FieldWrapperStyle
    /// Wraps the input element, receiving the current `InputState`.
    public var input: InputStyle
    /// Wraps the per-field error message.
    public var errorMessage: FieldWrapperStyle

    // MARK: - InputState

    /// The interaction state of a form input.
    public enum InputState: Sendable {
        case normal
        case focused
        case error
        case disabled
    }

    // MARK: - Default style

    /// A pass-through style that applies no additional styling.
    public static let `default` = FormStyle(
        fieldWrapper: { v in v },
        label: { v in v },
        input: { _, v in v },
        errorMessage: { v in v }
    )

    // MARK: - Init

    public init(
        fieldWrapper: @escaping FieldWrapperStyle = { v in v },
        label: @escaping FieldWrapperStyle = { v in v },
        input: @escaping InputStyle = { _, v in v },
        errorMessage: @escaping FieldWrapperStyle = { v in v }
    ) {
        self.fieldWrapper = fieldWrapper
        self.label = label
        self.input = input
        self.errorMessage = errorMessage
    }
}
