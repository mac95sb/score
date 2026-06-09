/// A view that represents one of two possible content types based on a condition.
///
/// Produced by `ViewBuilder.buildEither(first:)` and `ViewBuilder.buildEither(second:)`.
public struct _ConditionalView<TrueContent: View, FalseContent: View>: View, _HTMLRenderable {
    enum Storage: Sendable {
        case first(TrueContent)
        case second(FalseContent)
    }
    let storage: Storage
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        switch storage {
        case .first(let v): return v._renderInto(&context)
        case .second(let v): return v._renderInto(&context)
        }
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        switch storage {
        case .first(let v): v._collectCSSInto(&context)
        case .second(let v): v._collectCSSInto(&context)
        }
    }
}

/// A view that renders its content only when it is non-nil.
///
/// Produced by `ViewBuilder.buildOptional(_:)`.
public struct _OptionalView<Content: View>: View, _HTMLRenderable {
    let content: Content?
    init(_ content: Content?) { self.content = content }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        content.map { $0._renderInto(&context) } ?? ""
    }

    public func collectCSS(context: inout CSSCollectionContext) {
        content?._collectCSSInto(&context)
    }
}
