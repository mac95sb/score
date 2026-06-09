import Foundation

/// Marks a function as a Score action.
///
/// Actions are compiled to either client-side JavaScript or a server RPC depending
/// on what they capture. If the action captures server-only types (e.g. `db`, `cache`),
/// Score compiles it as a server action (RPC). Otherwise it becomes client-side JS.
///
/// ```swift
/// // Server action — saves to database
/// @Action func save() async throws {
///     try await db.update(post)
/// }
///
/// // Client action — toggles state without a network round-trip
/// @Action func toggle() {
///     isOpen.toggle()
/// }
/// ```
///
/// > Note: In v1, `@Action` is a property wrapper used for marking. The Score build
/// > system analyses captures at compile time using swift-syntax macros.
@propertyWrapper
public struct Action<F: Sendable>: Sendable {
    public let wrappedValue: F

    public init(wrappedValue: F) {
        self.wrappedValue = wrappedValue
    }
}
