/// The network connectivity state of the client.
///
/// Available when `stateMode: .localFirst` is set on `Application`.
/// Score uses a heartbeat to `/__score/ping` rather than `navigator.onLine`
/// for more reliable detection.
public enum ConnectivityState: String, Sendable, CaseIterable {
    case online
    case offline
    case reconnecting
}

/// Exposes the current network connectivity state inside a view.
///
/// Only meaningful when `stateMode: .localFirst` is configured.
///
/// ```swift
/// struct OfflineBanner: View {
///     @Connectivity var connectivity: ConnectivityState
///
///     var body: some View {
///         if connectivity == .offline {
///             Text { "You are offline — changes will sync when reconnected." }
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct Connectivity: Sendable {
    public var wrappedValue: ConnectivityState

    /// Initialise with an assumed connectivity state (default: `.online`).
    ///
    /// The actual value is injected at runtime by the Score client runtime.
    public init(wrappedValue: ConnectivityState = .online) {
        self.wrappedValue = wrappedValue
    }
}
