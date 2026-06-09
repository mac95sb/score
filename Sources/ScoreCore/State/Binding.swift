/// A two-way reference to a value owned by a parent view.
///
/// Create a `Binding` from an `@State` variable using the `$` prefix:
/// ```swift
/// SearchInput(query: $query)
/// ```
@propertyWrapper
public struct Binding<Value: Sendable>: Sendable {
    private let _get: @Sendable () -> Value
    private let _set: @Sendable (Value) -> Void

    public init(get: @Sendable @escaping () -> Value, set: @Sendable @escaping (Value) -> Void) {
        self._get = get
        self._set = set
    }

    public var wrappedValue: Value {
        get { _get() }
        nonmutating set { _set(newValue) }
    }

    /// Access the binding itself via the `$` projection.
    public var projectedValue: Binding<Value> { self }

    /// Create a constant read-only binding. Useful for previews and testing.
    public static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }
}
