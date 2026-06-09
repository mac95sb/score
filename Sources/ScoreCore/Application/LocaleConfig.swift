import Foundation

/// Locale and internationalisation configuration for a Score application.
///
/// Configure on your `Application` conformance to enable multi-locale support.
public struct LocaleConfig: Sendable {
    /// The default locale used when no other locale can be detected.
    public let `default`: Locale
    /// All supported locales. Must contain at least the `default`.
    public let supported: [Locale]
    /// Ordered list of detection strategies tried before falling back to the default.
    public let detection: [LocaleDetectionStrategy]

    public init(
        `default`: Locale,
        supported: [Locale],
        detection: [LocaleDetectionStrategy] = [.acceptLanguageHeader]
    ) {
        self.default = `default`
        self.supported = supported
        self.detection = detection
    }
}

// MARK: - LocaleDetectionStrategy

/// How Score detects the user's preferred locale.
public enum LocaleDetectionStrategy: Sendable, Hashable {
    /// Detect locale from a URL path prefix, e.g. `/en/`, `/es/`.
    case urlPrefix
    /// Detect locale from the `Accept-Language` HTTP request header.
    case acceptLanguageHeader
    /// Detect locale from a cookie with the given name.
    case cookie(String)
}

// MARK: - Sendable conformance

extension Locale: @retroactive @unchecked Sendable {}
