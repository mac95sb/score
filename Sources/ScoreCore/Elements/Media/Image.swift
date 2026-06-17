/// An image element with optional figure caption and photo credit (`<img>` or `<figure>`).
///
/// `Image` requires an `alt` parameter. A descriptive alt text is essential
/// for users who rely on screen readers and for search engine indexing. Use an
/// empty string (`alt: ""`) only for purely decorative images that convey no
/// information. When either `caption` or `credit` is provided, the image is
/// wrapped in `<figure><img><figcaption>…</figcaption></figure>`, which is the
/// correct semantic structure for captioned media.
///
/// Images are lazy-loaded by default (`loading: .lazy`). Set `.eager` for
/// above-the-fold images (hero, LCP candidates) so the browser fetches them
/// immediately without waiting for the lazy-load threshold.
///
/// - Parameters:
///   - src: The URL of the image file.
///   - alt: Alternative text describing the image. Required; use `""` for decorative images.
///   - caption: An optional human-readable caption rendered in `<figcaption>`.
///   - credit: An optional photo credit wrapped in `<cite>` inside the figcaption.
///   - width: The intrinsic pixel width. Providing both `width` and `height` prevents layout shift.
///   - height: The intrinsic pixel height.
///   - loading: The browser loading strategy. Defaults to `.lazy`.
///
/// ## Example
///
/// ```swift
/// // Simple image
/// Image("/avatar.jpg", alt: "Profile photo of Jane Smith")
///     .border(radius: .full)
///     .frame(width: .px(64), height: .px(64))
///
/// // Captioned figure with credit
/// Image(
///     "/conference.jpg",
///     alt: "Crowd gathered at WWDC 2025",
///     caption: "WWDC 2025 — San Jose Convention Center",
///     credit: "Apple Inc.",
///     width: 1280,
///     height: 720,
///     loading: .eager
/// )
/// ```
///
/// ## HTML output
///
/// ```html
/// <img src="/avatar.jpg" alt="Profile photo of Jane Smith" loading="lazy">
///
/// <figure>
///   <img src="/conference.jpg" alt="…" loading="eager" width="1280" height="720">
///   <figcaption>WWDC 2025 — San Jose Convention Center <cite>Apple Inc.</cite></figcaption>
/// </figure>
/// ```
///
/// - SeeAlso: ``Video``, ``Audio``
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
