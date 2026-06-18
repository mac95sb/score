/// An embedded video player for clips, demos, or background loops (`<video>`).
///
/// Use `Video` to embed a single video file. Provide a `poster` image so that
/// users see a meaningful frame before playback starts. The browser shows its
/// native player UI when `controls` is `true` (the default).
///
/// For decorative background videos (hero sections, motion graphics), set
/// `autoplay: true`, `loop: true`, and `muted: true`. Most browsers require
/// `muted` for autoplay to fire without a user gesture. Always provide a
/// meaningful static alternative (e.g. a poster image or adjacent text) for
/// users who cannot play video.
///
/// For accessibility, add closed-caption tracks via a `<track>` element using
/// the `.attribute(_:_:)` modifier or a surrounding HTML context.
///
/// - Parameters:
///   - src: The URL of the video file (MP4, WebM, OGV, etc.).
///   - poster: URL of a preview image shown before playback. Recommended for user-facing videos.
///   - autoplay: Start playing immediately when the page loads. Defaults to `false`.
///   - controls: Show the browser's native playback controls. Defaults to `true`.
///   - loop: Restart from the beginning when playback ends. Defaults to `false`.
///   - muted: Begin in a muted state. Required by most browsers for `autoplay`. Defaults to `false`.
///
/// ## Example
///
/// ```swift
/// // User-facing demo video with controls
/// Video(src: "/demo.mp4", poster: "/demo-poster.jpg")
///     .frame(width: .full)
///     .border(radius: .lg)
///
/// // Decorative looping hero background
/// ZStack {
///     Video(src: "/hero-bg.mp4", autoplay: true, loop: true, muted: true, controls: false)
///         .frame(width: .full, height: .px(600))
///     VStack { Heading(1) { "Build fast websites with Swift." } }
///         .position(.absolute)
///         .inset(bottom: 0)
/// }
/// ```
///
/// ## HTML output
///
/// ```html
/// <video src="/demo.mp4" poster="/demo-poster.jpg" controls></video>
/// ```
///
/// - SeeAlso: ``Audio``, ``Image``
public struct Video: View, _HTMLRenderable {
    let src: String
    let poster: String?
    let autoplay: Bool
    let controls: Bool
    let loop: Bool
    let muted: Bool

    public init(
        src: String,
        poster: String? = nil,
        autoplay: Bool = false,
        controls: Bool = true,
        loop: Bool = false,
        muted: Bool = false
    ) {
        self.src = src
        self.poster = poster
        self.autoplay = autoplay
        self.controls = controls
        self.loop = loop
        self.muted = muted
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = "src=\"\(attributeEscape(src))\""
        if let poster = poster { attrs += " poster=\"\(attributeEscape(poster))\"" }
        if autoplay { attrs += " autoplay" }
        if controls { attrs += " controls" }
        if loop { attrs += " loop" }
        if muted { attrs += " muted" }
        return "<video \(attrs)></video>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
