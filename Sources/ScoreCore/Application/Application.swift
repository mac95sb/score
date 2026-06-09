import Foundation

/// The entry point for a Score application.
///
/// Conform your `@main` struct to `Application` and configure application-wide
/// settings via computed properties. Score uses the `metadata`, `theme`, and
/// `routes` properties to wire up the full site — HTML rendering, CSS generation,
/// routing, and static-site export.
///
/// ```swift
/// @main
/// struct MySite: Application {
///     var metadata: SiteMetadata {
///         SiteMetadata(siteName: "My Site", baseURL: "https://mysite.com")
///     }
///     var theme: SiteTheme { .default }
/// }
/// ```
public protocol Application: View {
    /// Site-wide metadata used for `<title>`, `<meta>`, Open Graph, and social cards.
    var metadata: SiteMetadata { get }

    /// The visual design system — colours, fonts, spacing, shadows, and radii.
    var theme: SiteTheme { get }

    /// Whether to inject Score's base CSS reset. Default: `true`.
    var includeBaseReset: Bool { get }

    /// Controls persistence of non-Record `@State` variables. Default: `.ephemeral`.
    var stateMode: StateMode { get }

    /// The global HTML document shell. Override to add custom `<head>` elements.
    var globalView: HtmlDocument { get }

    /// The URL prefix applied to all API route groups. Default: `.v1`.
    var apiPrefix: APIPrefix { get }
}

// MARK: - Default implementations

extension Application {
    public var includeBaseReset: Bool { true }
    public var stateMode: StateMode { .ephemeral }
    public var apiPrefix: APIPrefix { .v1 }

    public var globalView: HtmlDocument {
        HtmlDocument { EmptyView() }
    }

    /// Default body is empty — apps normally expose their content via routes.
    public var body: some View { EmptyView() }
}

// MARK: - HtmlDocument

/// A minimal HTML document wrapper used as the global view shell.
///
/// Score injects the `<head>` content and route body automatically; this
/// type exists so applications can customise the outer document shape.
public struct HtmlDocument: View, _HTMLRenderable {
    let bodyContent: AnyView

    public init<Content: View>(@ViewBuilder content: () -> Content) {
        self.bodyContent = AnyView(content())
    }

    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError("HtmlDocument is primitive") }

    public func renderHTML(context: inout RenderContext) -> String {
        let inner = bodyContent.renderHTML(context: &context)
        return "<!DOCTYPE html><html><head></head><body>\(inner)</body></html>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        bodyContent.collectCSS(context: &context)
    }
}
