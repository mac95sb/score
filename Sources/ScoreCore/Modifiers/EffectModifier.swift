// MARK: - EffectModifier

/// A modifier that applies visual effect properties such as opacity, CSS filters,
/// blend modes, cursor, and pointer-events.
///
/// Use ``View/opacity(_:on:)``, ``View/blur(_:on:)``, ``View/cursor(_:)``, and
/// related methods rather than constructing `EffectModifier` directly.
///
/// ```swift
/// Image(src: heroURL, alt: "Hero")
///     .opacity(0.9)
///     .blur(.px(1), on: .hover)
///
/// DisabledButton { "Submit" }
///     .opacity(0.4)
///     .cursor(.notAllowed)
/// ```
///
/// - SeeAlso: ``View/opacity(_:on:)``, ``View/blur(_:on:)``, ``View/cursor(_:)``
public struct EffectModifier: ThemeAwareModifier {
    let opacity: Double?
    let blur: SpacingValue?
    let saturate: Double?
    let brightness: Double?
    let grayscale: Bool?
    let invert: Bool?
    let blendMode: BlendMode?
    let objectFit: ObjectFit?
    let objectPosition: BackgroundPosition?
    let cursor: CursorValue?
    let userSelect: UserSelect?
    let pointerEvents: Bool?
    let appearance: String?
    let fill: Color?
    let stroke: Color?
    let strokeWidth: SpacingValue?
    let scrollBehavior: String?
    let accentColor: Color?
    let caretColor: Color?
    let willChange: String?
    let backdropBlur: SpacingValue?
    let backdropBrightness: Double?
    let backdropSaturate: Double?
    let condition: ModifierCondition?

    public init(
        opacity: Double? = nil,
        blur: SpacingValue? = nil,
        saturate: Double? = nil,
        brightness: Double? = nil,
        grayscale: Bool? = nil,
        invert: Bool? = nil,
        blendMode: BlendMode? = nil,
        objectFit: ObjectFit? = nil,
        objectPosition: BackgroundPosition? = nil,
        cursor: CursorValue? = nil,
        userSelect: UserSelect? = nil,
        pointerEvents: Bool? = nil,
        appearance: String? = nil,
        fill: Color? = nil,
        stroke: Color? = nil,
        strokeWidth: SpacingValue? = nil,
        scrollBehavior: String? = nil,
        accentColor: Color? = nil,
        caretColor: Color? = nil,
        willChange: String? = nil,
        backdropBlur: SpacingValue? = nil,
        backdropBrightness: Double? = nil,
        backdropSaturate: Double? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.opacity = opacity; self.blur = blur; self.saturate = saturate
        self.brightness = brightness; self.grayscale = grayscale; self.invert = invert
        self.blendMode = blendMode; self.objectFit = objectFit; self.objectPosition = objectPosition
        self.cursor = cursor; self.userSelect = userSelect; self.pointerEvents = pointerEvents
        self.appearance = appearance; self.fill = fill; self.stroke = stroke
        self.strokeWidth = strokeWidth; self.scrollBehavior = scrollBehavior
        self.accentColor = accentColor; self.caretColor = caretColor; self.willChange = willChange
        self.backdropBlur = backdropBlur; self.backdropBrightness = backdropBrightness
        self.backdropSaturate = backdropSaturate; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []

        if let o = opacity     { result.append(ConditionedDeclaration("opacity",         o.cssStr,                  condition: condition)) }

        // Compose CSS filter from all filter properties
        var filters: [String] = []
        if let b = blur        { filters.append("blur(\(b.css))") }
        if let s = saturate    { filters.append("saturate(\(Int(s * 100))%)") }
        if let br = brightness { filters.append("brightness(\(Int(br * 100))%)") }
        if let g = grayscale, g { filters.append("grayscale(1)") }
        if let i = invert, i   { filters.append("invert(1)") }
        if !filters.isEmpty {
            result.append(ConditionedDeclaration("filter", filters.joined(separator: " "), condition: condition))
        }

        // Backdrop filters
        var backdropFilters: [String] = []
        if let bb = backdropBlur { backdropFilters.append("blur(\(bb.css))") }
        if let bbr = backdropBrightness { backdropFilters.append("brightness(\(Int(bbr * 100))%)") }
        if let bs = backdropSaturate { backdropFilters.append("saturate(\(Int(bs * 100))%)") }
        if !backdropFilters.isEmpty {
            result.append(ConditionedDeclaration("backdrop-filter", backdropFilters.joined(separator: " "), condition: condition))
            result.append(ConditionedDeclaration("-webkit-backdrop-filter", backdropFilters.joined(separator: " "), condition: condition))
        }

        if let bm = blendMode  { result.append(ConditionedDeclaration("mix-blend-mode",    bm.rawValue,          condition: condition)) }
        if let of = objectFit  { result.append(ConditionedDeclaration("object-fit",         of.rawValue,          condition: condition)) }
        if let op = objectPosition { result.append(ConditionedDeclaration("object-position", op.rawValue,         condition: condition)) }
        if let c = cursor      { result.append(ConditionedDeclaration("cursor",             c.rawValue,           condition: condition)) }
        if let us = userSelect { result.append(ConditionedDeclaration("user-select",        us.rawValue,          condition: condition)) }
        if let pe = pointerEvents {
            result.append(ConditionedDeclaration("pointer-events", pe ? "auto" : "none", condition: condition))
        }
        if let ap = appearance { result.append(ConditionedDeclaration("appearance",        ap,                   condition: condition)) }
        if let f = fill        { result.append(ConditionedDeclaration("fill",              f.cssValue,           condition: condition)) }
        if let s = stroke      { result.append(ConditionedDeclaration("stroke",            s.cssValue,           condition: condition)) }
        if let sw = strokeWidth { result.append(ConditionedDeclaration("stroke-width",     sw.css,               condition: condition)) }
        if let sb = scrollBehavior { result.append(ConditionedDeclaration("scroll-behavior", sb,                 condition: condition)) }
        if let ac = accentColor { result.append(ConditionedDeclaration("accent-color",     ac.cssValue,          condition: condition)) }
        if let cc = caretColor { result.append(ConditionedDeclaration("caret-color",       cc.cssValue,          condition: condition)) }
        if let wc = willChange { result.append(ConditionedDeclaration("will-change",       wc,                   condition: condition)) }

        return result
    }
}
