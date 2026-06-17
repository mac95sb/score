/// An embedded audio player for music, podcasts, or sound clips (`<audio>`).
///
/// Use `Audio` to embed a single audio file. The browser renders its native
/// playback UI when `controls` is `true` (the default). For ambient or
/// background audio (e.g. a looping soundscape) set `autoplay: true`,
/// `loop: true`, and `muted: true` — note that most browsers require `muted`
/// for autoplay to work without user interaction.
///
/// For accessibility, provide a visible label or description adjacent to the
/// player so users who cannot hear the audio have context. The `<audio>`
/// element has no built-in `alt` attribute.
///
/// - Parameters:
///   - src: The URL of the audio file (MP3, OGG, WAV, etc.).
///   - controls: Show the browser's native playback controls. Defaults to `true`.
///   - autoplay: Start playing as soon as the browser can. Defaults to `false`.
///   - loop: Restart from the beginning when playback ends. Defaults to `false`.
///   - muted: Begin in a muted state. Required by most browsers for `autoplay`. Defaults to `false`.
///
/// ## Example
///
/// ```swift
/// // Podcast episode with controls
/// VStack(gap: 2) {
///     Text { "Episode 42: Swift on the Server" }
///     Audio(src: "/episodes/42.mp3")
/// }
///
/// // Looping background ambient audio (requires muted for autoplay)
/// Audio(src: "/ambient.mp3", autoplay: true, loop: true, muted: true)
/// ```
///
/// ## HTML output
///
/// ```html
/// <audio src="/episodes/42.mp3" controls></audio>
/// ```
///
/// - SeeAlso: ``Video``, ``Image``
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
