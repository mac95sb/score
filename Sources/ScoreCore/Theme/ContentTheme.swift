import Foundation

// MARK: - ContentTheme

/// Styling configuration for markdown-rendered content.
///
/// Applied at three levels: app default → page override → per-RichText override.
public struct ContentTheme: Sendable {
    public typealias ElementStyle = @Sendable (any View) -> any View
    public typealias HeadingStyle = @Sendable (Int, any View) -> any View

    public var heading: HeadingStyle
    public var paragraph: ElementStyle
    public var code: ElementStyle
    public var codeBlock: @Sendable (String?, any View) -> any View
    public var blockquote: ElementStyle
    public var list: @Sendable (ListStyle, any View) -> any View
    public var listItem: ElementStyle
    public var table: ElementStyle
    public var link: ElementStyle
    public var image: ElementStyle
    public var divider: ElementStyle
    public var strong: ElementStyle
    public var emphasis: ElementStyle
    public var strikethrough: ElementStyle

    public static let `default` = ContentTheme(
        heading:      { _, v in v },
        paragraph:    { v in v },
        code:         { v in v },
        codeBlock:    { _, v in v },
        blockquote:   { v in v },
        list:         { _, v in v },
        listItem:     { v in v },
        table:        { v in v },
        link:         { v in v },
        image:        { v in v },
        divider:      { v in v },
        strong:       { v in v },
        emphasis:     { v in v },
        strikethrough: { v in v }
    )

    public init(
        heading:       @escaping HeadingStyle                              = { _, v in v },
        paragraph:     @escaping ElementStyle                              = { v in v },
        code:          @escaping ElementStyle                              = { v in v },
        codeBlock:     @escaping @Sendable (String?, any View) -> any View = { _, v in v },
        blockquote:    @escaping ElementStyle                              = { v in v },
        list:          @escaping @Sendable (ListStyle, any View) -> any View = { _, v in v },
        listItem:      @escaping ElementStyle                              = { v in v },
        table:         @escaping ElementStyle                              = { v in v },
        link:          @escaping ElementStyle                              = { v in v },
        image:         @escaping ElementStyle                              = { v in v },
        divider:       @escaping ElementStyle                              = { v in v },
        strong:        @escaping ElementStyle                              = { v in v },
        emphasis:      @escaping ElementStyle                              = { v in v },
        strikethrough: @escaping ElementStyle                              = { v in v }
    ) {
        self.heading       = heading
        self.paragraph     = paragraph
        self.code          = code
        self.codeBlock     = codeBlock
        self.blockquote    = blockquote
        self.list          = list
        self.listItem      = listItem
        self.table         = table
        self.link          = link
        self.image         = image
        self.divider       = divider
        self.strong        = strong
        self.emphasis      = emphasis
        self.strikethrough = strikethrough
    }
}
