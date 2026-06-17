/// The programming or markup language used for syntax-highlighting a ``CodeBlock``.
///
/// Pass one of these cases to `CodeBlock(language:)` to attach a
/// `language-*` CSS class that syntax-highlighting libraries such as
/// Highlight.js or Prism can target.
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

/// A multi-line, fenced code block with optional language annotation (`<pre><code>`).
///
/// Use `CodeBlock` for displaying source code, terminal output, configuration
/// snippets, or any verbatim content that requires a monospace font and
/// preserved whitespace. The element renders as `<pre><code>` which browsers
/// display in a monospace font and preserve newlines and spaces exactly.
/// Specifying a `language` adds a `language-*` CSS class that syntax-highlighting
/// libraries (Highlight.js, Prism, etc.) use to colourize tokens automatically.
///
/// Content is HTML-escaped before rendering, so you can safely pass untrusted
/// source code strings.
///
/// - Parameters:
///   - language: The source language used for a `language-*` CSS class. `nil` omits the class.
///   - syntaxTheme: An optional ``SyntaxTheme`` for server-side highlighting.
///   - content: The source code string, or a `@ViewBuilder` closure whose
///     rendered text becomes the code content.
///
/// ## Example
///
/// ```swift
/// CodeBlock(language: .swift) {
///     """
///     struct Greeting: View {
///         var body: some View {
///             Text { "Hello, world!" }
///         }
///     }
///     """
/// }
/// .margin(y: 4)
///
/// CodeBlock(language: .bash, "npm install && npm run build")
/// ```
///
/// ## HTML output
///
/// ```html
/// <pre><code class="language-swift">…</code></pre>
/// ```
///
/// - SeeAlso: ``Code``, ``RichText``, ``CodeLanguage``
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
