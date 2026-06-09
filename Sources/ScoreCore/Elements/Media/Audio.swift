/// An audio embed element (`<audio>`).
///
/// ```swift
/// Audio(src: "/podcast-ep1.mp3")
/// Audio(src: "/track.ogg", controls: false)
/// ```
public struct Audio: View, _HTMLRenderable {
    let src: String
    let controls: Bool
    let autoplay: Bool
    let loop: Bool
    let muted: Bool

    public init(
        src: String,
        controls: Bool = true,
        autoplay: Bool = false,
        loop: Bool = false,
        muted: Bool = false
    ) {
        self.src = src
        self.controls = controls
        self.autoplay = autoplay
        self.loop = loop
        self.muted = muted
    }

    public typealias Body = Never
    public var body: Never { fatalError() }

    public func renderHTML(context: inout RenderContext) -> String {
        var attrs = "src=\"\(attributeEscape(src))\""
        if controls { attrs += " controls" }
        if autoplay { attrs += " autoplay" }
        if loop     { attrs += " loop" }
        if muted    { attrs += " muted" }
        return "<audio \(attrs)></audio>"
    }

    public func collectCSS(context: inout CSSCollectionContext) {}
}
