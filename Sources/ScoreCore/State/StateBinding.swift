/// A reference to a state value owned by a parent view.
///
/// Used to wire native browser elements (e.g. `Dialog`, `Popover`) to
/// Score's reactive system. The framework generates the appropriate JS
/// bindings at build time.
///
/// ```swift
/// @State private var showDialog = false
///
/// Button(.primary) { "Open" }
/// Dialog(isOpen: $showDialog) {
///     Text { "Hello from the dialog." }
/// }
/// ```
public struct StateBinding<Value: Sendable>: Sendable {
    let get: @Sendable () -> Value
    let set: @Sendable (Value) -> Void

    public init(get: @Sendable @escaping () -> Value, set: @Sendable @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }

    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
}
