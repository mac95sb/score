import Foundation

/// Declares a reactive data dependency fetched from a typed ``APIEndpoint``.
///
/// Score resolves `@Fetch` at render time:
/// - **Server-rendered pages** — Score awaits the endpoint response before
///   evaluating `body`, so `wrappedValue` is always populated by the time
///   view code runs.
/// - **Client-reactive pages** — Score generates a typed JavaScript fetch call
///   that re-populates the value and triggers a UI update in the browser.
///
/// The type parameters on ``APIEndpoint`` enforce a compile-time contract:
/// the property type must match `APIEndpoint.ResponseValue`. Mismatches are
/// compiler errors, not runtime surprises.
///
/// ```swift
/// struct BlogIndex: Page {
///     @Fetch(Posts.list) var posts: [Post]
///
///     var body: some View {
///         ForEach(posts) { post in ArticleCard(post: post) }
///     }
/// }
/// ```
@propertyWrapper
public struct Fetch<Body: Sendable, Value: Sendable>: Sendable {
    /// The endpoint this property is bound to.
    public let endpoint: APIEndpoint<Body, Value>

    private let _value: Value?

    /// The fetched value.
    ///
    /// Accessing this before Score's render pipeline has populated it (i.e.
    /// outside of a `body` evaluation) is a programming error.
    public var wrappedValue: Value {
        guard let v = _value else {
            fatalError(
                "@Fetch<\(Value.self)> wrappedValue accessed before Score populated it. "
                + "This is a framework bug — please file an issue."
            )
        }
        return v
    }

    public var projectedValue: Self { self }

    /// Declare a fetch dependency on the given endpoint.
    public init(_ endpoint: APIEndpoint<Body, Value>) {
        self.endpoint = endpoint
        self._value = nil
    }

    /// Score-internal initialiser: inject the resolved value into the wrapper.
    public init(_ endpoint: APIEndpoint<Body, Value>, value: Value) {
        self.endpoint = endpoint
        self._value = value
    }
}
