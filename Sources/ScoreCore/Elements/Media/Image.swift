/// An image element (`<img>`).
///
/// When `caption` or `credit` is provided the image is wrapped in a
/// `<figure>` / `<figcaption>` structure.
///
/// ```swift
/// Image("/hero.jpg", alt: "A mountain landscape")
/// Image("/photo.jpg", alt: "Conference crowd", caption: "WWDC 2025", loading: .eager)
/// ```
public struct Image: View, _HTMLRenderable {

    /// Controls the browser's loading strategy for this image.
    public enum ImageLoading: String, Sendable {
        case lazy
        case eager
        case auto
    }

    let src: String
    let alt: String
    let caption: String?
    let credit: String?
    let width: Int?
    let height: Int?
    let loading: ImageLoading

    public init(
        _ src: String,
        alt: String,
        caption: String? = nil,
        credit: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        loading: ImageLoading = .lazy
    ) {
        self.src = src
        self.alt = alt
        self.caption = caption
        self.credit = credit
        self.width = width
        self.height = height
        self.loading = loading
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var imgAttrs = "src=\"\(attributeEscape(src))\" alt=\"\(attributeEscape(alt))\""
        if loading != .auto { imgAttrs += " loading=\"\(loading.rawValue)\"" }
        if let w = width    { imgAttrs += " width=\"\(w)\"" }
        if let h = height   { imgAttrs += " height=\"\(h)\"" }
        let img = "<img \(imgAttrs)>"

        if caption != nil || credit != nil {
            var figcap = "<figcaption>"
            if let caption = caption { figcap += htmlEscape(caption) }
            if let credit = credit   { figcap += " <cite>\(htmlEscape(credit))</cite>" }
            figcap += "</figcaption>"
            return "<figure>\(img)\(figcap)</figure>"
        }
        return img
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
