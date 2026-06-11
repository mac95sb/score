import Foundation

// The `Application` protocol lives in the umbrella `Score` module
// (Sources/Score/Application.swift) because its requirements span routing
// (`ScoreRouter`) and persistence (`ScoreData`), which `ScoreCore` cannot
// import. This file keeps the document shell type used by that protocol.

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
