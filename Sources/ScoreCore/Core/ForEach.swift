/// A view produced by `ViewBuilder.buildArray(_:)` — a flat array of same-type views.
public struct _ArrayView<Content: View>: View, _HTMLRenderable {
    let elements: [Content]
    init(_ elements: [Content]) { self.elements = elements }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        elements.map { $0._renderInto(&context) }.joined()
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        elements.forEach { $0._collectCSSInto(&context) }
    }
}

/// Dynamic list of views produced from a data collection.
///
/// ```swift
/// ForEach(posts) { post in
///     ArticleCard(post: post)
/// }
/// ```
public struct ForEach<Data: RandomAccessCollection, Content: View>: View, _HTMLRenderable
where Data: Sendable, Data.Element: Sendable {
    let data: Data
    let content: @Sendable (Data.Element) -> Content

    public init(
        _ data: Data,
        @ViewBuilder content: @Sendable @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.content = content
    }

    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        data.map { content($0)._renderInto(&context) }.joined()
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        for element in data { content(element)._collectCSSInto(&context) }
    }
}
