import Foundation

// MARK: - _HTMLRenderable

/// Internal protocol implemented by primitive HTML elements.
///
/// Composite views are rendered by recursing through their `body`; primitive
/// elements implement this protocol directly and produce raw HTML strings.
public protocol _HTMLRenderable: Sendable {
    /// Produce an HTML string for this element.
    func renderHTML(context: inout RenderContext) -> String
    /// Collect CSS rules from this element into the given context.
    func collectCSS(context: inout CSSCollectionContext)
}

// MARK: - View rendering helpers

extension View {

    /// Render this view into the given context, returning an HTML string.
    ///
    /// If the view conforms to `_HTMLRenderable` the primitive path is taken
    /// directly; otherwise the renderer recurses through `body`.
    /// Public so downstream modules (`ScoreSSG`, `ScoreBuild`) can drive
    /// rendering; the underscore marks it as framework plumbing.
    @discardableResult
    public func _renderInto(_ context: inout RenderContext) -> String {
        if let primitive = self as? any _HTMLRenderable {
            return primitive.renderHTML(context: &context)
        }
        // Composite view — recurse through body, preserving component type name.
        let savedTypeName = context.componentTypeName
        context.depth += 1
        let html = body._renderInto(&context)
        context.depth -= 1
        context.componentTypeName = savedTypeName
        return html
    }

    /// Collect CSS from this view into the given context.
    func _collectCSSInto(_ context: inout CSSCollectionContext) {
        if let primitive = self as? any _HTMLRenderable {
            primitive.collectCSS(context: &context)
        } else {
            body._collectCSSInto(&context)
        }
    }
}

// MARK: - HTMLRenderer

/// The main HTML rendering engine.
///
/// Traverses a `View` tree and produces an HTML string.
/// CSS is collected separately via `CSSCollector`.
public struct HTMLRenderer {
    public init() {}

    // MARK: - Rendering

    /// Render a view to an HTML string.
    ///
    /// - Parameters:
    ///   - view: The view to render.
    ///   - componentTypeName: Explicit component type name used for CSS scoping.
    ///     Defaults to the Swift type name of `view`.
    public func render<V: View>(_ view: V, componentTypeName: String = "") -> String {
        var context = RenderContext()
        context.componentTypeName = componentTypeName.isEmpty
            ? String(describing: type(of: view))
            : componentTypeName
        return view._renderInto(&context)
    }

    /// Render a complete HTML page with a `DOCTYPE` declaration.
    ///
    /// - Parameters:
    ///   - view: The body content of the page.
    ///   - title: The page `<title>` string (HTML-escaped automatically).
    ///   - cssLinks: Paths or URLs for `<link rel="stylesheet">` tags.
    ///   - scriptSrcs: Paths or URLs for `<script type="module">` tags.
    public func renderPage<V: View>(
        _ view: V,
        title: String,
        cssLinks: [String] = [],
        scriptSrcs: [String] = []
    ) -> String {
        let bodyHTML = render(view)
        var head = "<meta charset=\"UTF-8\">"
        head += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        head += "<title>\(htmlEscape(title))</title>"
        for link in cssLinks {
            head += "<link rel=\"stylesheet\" href=\"\(attributeEscape(link))\">"
        }
        for src in scriptSrcs {
            head += "<script type=\"module\" src=\"\(attributeEscape(src))\"></script>"
        }
        return "<!DOCTYPE html><html><head>\(head)</head><body>\(bodyHTML)</body></html>"
    }
}

// MARK: - HTML escaping utilities

/// Escape a string for safe embedding in HTML text content.
public func htmlEscape(_ text: String) -> String {
    text
        .replacingOccurrences(of: "&",  with: "&amp;")
        .replacingOccurrences(of: "<",  with: "&lt;")
        .replacingOccurrences(of: ">",  with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'",  with: "&#39;")
}

/// Escape a string for safe embedding in an HTML attribute value.
public func attributeEscape(_ value: String) -> String {
    htmlEscape(value)
}
