/// A video embed element (`<video>`).
///
/// ```swift
/// Video(src: "/demo.mp4", poster: "/poster.jpg", controls: true)
/// Video(src: "/bg-loop.mp4", autoplay: true, loop: true, muted: true)
/// ```
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
        if autoplay  { attrs += " autoplay" }
        if controls  { attrs += " controls" }
        if loop      { attrs += " loop" }
        if muted     { attrs += " muted" }
        return "<video \(attrs)></video>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
