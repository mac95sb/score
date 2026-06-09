/// Configuration for markdown content extensions parsed by `ContentStore`.
///
/// Pass a custom `ContentStoreConfig` to enable or disable individual markdown
/// extensions. Most extensions are opt-in to keep the parser fast by default.
public struct ContentStoreConfig: Sendable {
    /// Enable GitHub-style footnotes.
    public var footnotes: Bool
    /// Enable `==marked==` text highlighting.
    public var markedText: Bool
    /// Automatically build a table of contents from headings.
    public var tableOfContents: Bool
    /// Enable GitHub-style `- [ ]` task lists.
    public var taskLists: Bool
    /// Enable definition lists (`dl`/`dt`/`dd`).
    public var definitionLists: Bool
    /// Enable subscript (`~text~`).
    public var `subscript`: Bool
    /// Enable superscript (`^text^`).
    public var superscript: Bool

    public init(
        footnotes: Bool = false,
        markedText: Bool = false,
        tableOfContents: Bool = false,
        taskLists: Bool = true,
        definitionLists: Bool = false,
        subscript: Bool = false,
        superscript: Bool = false
    ) {
        self.footnotes = footnotes
        self.markedText = markedText
        self.tableOfContents = tableOfContents
        self.taskLists = taskLists
        self.definitionLists = definitionLists
        self.subscript = `subscript`
        self.superscript = superscript
    }

    /// The default configuration with task lists enabled and other extensions disabled.
    public static let `default` = ContentStoreConfig()
}
