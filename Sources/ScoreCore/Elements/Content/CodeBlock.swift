/// Supported programming / markup languages for `CodeBlock`.
public enum CodeLanguage: String, Sendable, CaseIterable {
    case swift
    case js
    case ts
    case html
    case css
    case json
    case markdown
    case bash
    case python
    case sql
    case rust
    case go
    case yaml
    case toml
    case diff
    case text
}

/// A fenced code block with optional syntax highlighting.
///
/// ```swift
/// CodeBlock(language: .swift) {
///     """
///     let x = 42
///     print(x)
///     """
/// }
/// ```
public struct CodeBlock: View, _HTMLRenderable {
    let language: CodeLanguage?
    let syntaxTheme: (any SyntaxTheme)?
    let content: String

    /// String-literal initialiser.
    public init(language: CodeLanguage? = nil, syntaxTheme: (any SyntaxTheme)? = nil, _ content: String) {
        self.language = language
        self.syntaxTheme = syntaxTheme
        self.content = content
    }

    /// `@ViewBuilder` initialiser — renders child views to a string at init time.
    public init(language: CodeLanguage? = nil, syntaxTheme: (any SyntaxTheme)? = nil, @ViewBuilder content: () -> some View) {
        self.language = language
        self.syntaxTheme = syntaxTheme
        var ctx = RenderContext()
        self.content = content()._renderInto(&ctx)
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var langAttr = ""
        if let lang = language {
            langAttr = " class=\"language-\(lang.rawValue)\""
        }
        return "<pre><code\(langAttr)>\(htmlEscape(content))</code></pre>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
