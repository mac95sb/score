import Foundation

/// Declares a state variable on a Score view.
///
/// On the server side `@State` provides a snapshot value for the current
/// render. The `projectedValue` (`$` binding) captures mutations but they
/// are not propagated back to the server — state changes in response to
/// user interaction require a client-side runtime (not yet available).
///
/// `stateMode: .localFirst` on `Application` is reserved for a future CRDT
/// runtime; it has no effect today.
///
/// ```swift
/// struct Counter: View {
///     @State var count: Int = 0
///
///     var body: some View {
///         VStack {
///             Heading(2) { "\(count)" }
///             Button(.primary) { "+" }.on(.click) { count += 1 }
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct State<Value: Sendable>: Sendable {
    private var _value: Value

    public init(wrappedValue: Value) {
        self._value = wrappedValue
    }

    public var wrappedValue: Value {
        get { _value }
        set { _value = newValue }
    }

    /// The binding — pass to child views using the `$` prefix.
    ///
    /// For server-side rendering this creates a snapshot binding; mutations
    /// are reflected in the next render cycle.
    public var projectedValue: Binding<Value> {
        Binding(
            get: { self._value },
            set: { _ in }  // server-side — no live mutation
        )
    }
}

// MARK: - StateMode

/// Controls whether non-Record `@State` values are persisted across navigations.
public enum StateMode: Sendable {
    /// All non-Record `@State` is ephemeral and resets on navigation. Default.
    case ephemeral
    /// Non-Record `Codable` `@State` is persisted via IndexedDB and synced with CRDT.
    case localFirst
}
