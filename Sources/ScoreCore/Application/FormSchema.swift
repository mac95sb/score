import Foundation

/// A type that describes a form's fields, validation rules, and rendering.
///
/// Declare fields with `@Field` and attach validators as arguments:
///
/// ```swift
/// struct ContactForm: FormSchema {
///     @Field var name: String = ""
///     @Field(.required, .email) var email: String = ""
///     @Field(.textarea, rows: 4) var message: String = ""
/// }
/// ```
public protocol FormSchema: Sendable {}

// MARK: - @Field property wrapper

/// Marks a property as a form field with optional validation rules and input type hint.
@propertyWrapper
public struct Field<Value: Sendable>: Sendable {
    public let wrappedValue: Value
    /// Validation rules applied when the form is submitted.
    public let validators: [FieldValidator]
    /// Optional override for the HTML input type (e.g. `.textarea`, `.password`).
    public let inputType: InputType?
    /// Number of rows for `textarea` inputs. Ignored for other input types.
    public let rows: Int?

    /// Bare field with no validators.
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.validators = []
        self.inputType = nil
        self.rows = nil
    }

    /// Field with one or more validators.
    public init(_ validators: FieldValidator..., wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.validators = validators
        self.inputType = nil
        self.rows = nil
    }

    /// Field with an explicit input type (and optional row count for textareas).
    public init(_ type: InputType, rows: Int? = nil, wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.validators = []
        self.inputType = type
        self.rows = rows
    }

    /// Field with an explicit input type and validators.
    public init(_ type: InputType, rows: Int? = nil, _ validators: FieldValidator..., wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.validators = validators
        self.inputType = type
        self.rows = rows
    }
}

// MARK: - FieldValidator

/// A validation rule applied to a form field when the form is submitted.
public enum FieldValidator: Sendable {
    /// The field must have a non-empty value.
    case required
    /// The value must be at least `n` characters long.
    case minLength(Int)
    /// The value must be at most `n` characters long.
    case maxLength(Int)
    /// The value must be a valid email address.
    case email
    /// The value must be a valid URL.
    case url
    /// The value must consist only of digits.
    case numeric
    /// The value must consist only of letters and digits.
    case alphanumeric
    /// The value must match the given regular expression pattern.
    case regex(String)
    /// The value must be one of the given strings.
    case oneOf([String])
    /// A boolean field that must be `true` (e.g. a terms-of-service checkbox).
    case mustBeTrue(error: String)
    /// The numeric value must be at least `min`.
    case min(Double)
    /// The numeric value must be at most `max`.
    case max(Double)
}

// MARK: - FormValidationResult

/// The result of validating a submitted form.
public enum FormValidationResult<F: FormSchema>: Sendable {
    /// Validation passed; the populated form value is attached.
    case success(F)
    /// Validation failed; a dictionary of field names to error message arrays is attached.
    case failure([String: [String]])
}
