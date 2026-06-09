import Foundation

/// Declares a reactive state variable on a Score view.
///
/// Score infers whether state is UI-only (ephemeral) or persistent based on
/// the type: plain `Codable` types are persistent only when `stateMode: .localFirst`
/// is set on `Application`. Primitive types (Bool, Int, String) are always UI state.
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
