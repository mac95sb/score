// MARK: - Visual modifiers (transform, background, border, shadow, effect)

extension View {

    // MARK: Transform

    /// Translate the element on X and/or Y axes.
    public func translate(x: SpacingValue? = nil, y: SpacingValue? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, TranslateModifier> {
        modifier(TranslateModifier(x: x, y: y, condition: condition))
    }

    /// Scale the element uniformly.
    public func scale(_ uniform: Double, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, ScaleModifier> {
        modifier(ScaleModifier(uniform: uniform, condition: condition))
    }

    /// Scale the element with independent X and Y factors.
    public func scale(x: Double? = nil, y: Double? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, ScaleModifier> {
        modifier(ScaleModifier(x: x, y: y, condition: condition))
    }

    /// Rotate the element by the given number of degrees.
    public func rotate(_ degrees: Double, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, RotateModifier> {
        modifier(RotateModifier(degrees: degrees, condition: condition))
    }

    /// Skew the element.
    public func skew(x: Double? = nil, y: Double? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, SkewModifier> {
        modifier(SkewModifier(x: x, y: y, condition: condition))
    }

    /// Set the transform origin.
    public func transformOrigin(_ origin: TransformOrigin) -> ModifiedContent<Self, TransformOriginModifier> {
        modifier(TransformOriginModifier(origin: origin))
    }

    // MARK: Background

    /// Apply a background color.
    public func background(color: Color, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, BackgroundColorModifier> {
        modifier(BackgroundColorModifier(color: color, condition: condition))
    }

    /// Apply a gradient background.
    public func background(gradient: Gradient, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, BackgroundGradientModifier> {
        modifier(BackgroundGradientModifier(gradient: gradient, condition: condition))
    }

    /// Apply a background image with size and position.
    public func background(image: String, size: BackgroundSize = .cover, position: BackgroundPosition = .center) -> ModifiedContent<Self, BackgroundImageModifier> {
        modifier(BackgroundImageModifier(url: image, size: size, position: position))
    }

    /// Apply background clipping.
    public func background(clip: BackgroundClip) -> ModifiedContent<Self, BackgroundClipModifier> {
        modifier(BackgroundClipModifier(clip: clip))
    }

    // MARK: Border

    /// Apply a border stroke with optional color, width, edge, and style.
    public func border(
        color: Color? = nil,
        width: Double = 1,
        edge: Edge? = nil,
        style: BorderStyle = .solid,
        on condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, BorderModifier> {
        modifier(BorderModifier(color: color, width: width, edge: edge, style: style, condition: condition))
    }

    /// Apply a border radius using a semantic token.
    public func border(radius: RadiusToken, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, BorderModifier> {
        modifier(BorderModifier(radius: radius, condition: condition))
    }

    /// Apply a border radius as a raw pixel value.
    public func border(radius px: Double) -> ModifiedContent<Self, BorderModifier> {
        modifier(BorderModifier(radiusPx: px))
    }

    /// Apply border stroke and radius in one call.
    ///
    /// ```swift
    /// Card { ... }
    ///     .border(color: .muted.opacity(0.2), radius: .lg)
    /// ```
    public func border(
        color: Color? = nil,
        width: Double = 1,
        edge: Edge? = nil,
        style: BorderStyle = .solid,
        radius: RadiusToken,
        on condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, BorderModifier> {
        modifier(BorderModifier(color: color, width: width, edge: edge, style: style, radius: radius, condition: condition))
    }

    // MARK: Shadow

    /// Apply a box shadow using a semantic token.
    public func shadow(_ token: ShadowToken = .md, color: Color? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, ShadowModifier> {
        modifier(ShadowModifier(token: token, color: color, condition: condition))
    }

    /// Apply a custom box shadow string.
    public func shadow(_ custom: String, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, ShadowModifier> {
        modifier(ShadowModifier(customString: custom, condition: condition))
    }

    /// Apply a focus-ring style shadow.
    public func shadow(ring: Double, color: Color? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, ShadowModifier> {
        modifier(ShadowModifier(ring: ring, ringColor: color, condition: condition))
    }

    // MARK: Effect

    /// Set the element opacity (0–1).
    public func effect(opacity: Double, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(opacity: opacity, condition: condition))
    }

    /// Apply a CSS blur filter.
    public func effect(blur: SpacingValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(blur: blur, condition: condition))
    }

    /// Set the cursor style.
    public func effect(cursor: CursorValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(cursor: cursor, condition: condition))
    }

    /// Set the `object-fit` property.
    public func effect(objectFit: ObjectFit, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(objectFit: objectFit, condition: condition))
    }

    /// Set the `user-select` property.
    public func effect(userSelect: UserSelect, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(userSelect: userSelect, condition: condition))
    }

    /// Enable or disable pointer events.
    public func effect(pointerEvents: Bool, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(pointerEvents: pointerEvents, condition: condition))
    }

    /// Set the SVG `fill` color.
    public func effect(fill: Color, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(fill: fill, condition: condition))
    }

    /// Set `will-change` hint.
    public func effect(willChange: String) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(willChange: willChange))
    }

    /// Apply a mix-blend-mode.
    public func effect(blendMode: BlendMode, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(blendMode: blendMode, condition: condition))
    }

    /// Apply a grayscale filter.
    public func effect(grayscale: Bool, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(grayscale: grayscale, condition: condition))
    }

    /// Apply a brightness filter (1.0 = 100%).
    public func effect(brightness: Double, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(brightness: brightness, condition: condition))
    }

    /// Apply a saturate filter (1.0 = 100%).
    public func effect(saturate: Double, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(saturate: saturate, condition: condition))
    }

    /// Apply a backdrop blur filter.
    public func effect(backdropBlur: SpacingValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, EffectModifier> {
        modifier(EffectModifier(backdropBlur: backdropBlur, condition: condition))
    }

    /// Apply multiple visual effects in one call.
    ///
    /// Use this overload when you need two or more effect properties at once.
    /// Single-property calls (e.g. `.effect(opacity: 0.5)`) resolve to the
    /// more specific single-parameter overloads above.
    ///
    /// ```swift
    /// Image(src: url, alt: "Hero")
    ///     .effect(opacity: 0.8, objectFit: .cover)
    ///
    /// DisabledButton { "Submit" }
    ///     .effect(opacity: 0.4, cursor: .notAllowed, pointerEvents: false)
    /// ```
    public func effect(
        opacity: Double? = nil,
        blur: SpacingValue? = nil,
        saturate: Double? = nil,
        brightness: Double? = nil,
        grayscale: Bool? = nil,
        objectFit: ObjectFit? = nil,
        cursor: CursorValue? = nil,
        userSelect: UserSelect? = nil,
        pointerEvents: Bool? = nil,
        fill: Color? = nil,
        blendMode: BlendMode? = nil,
        backdropBlur: SpacingValue? = nil,
        on condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, EffectModifier> {
        modifier(
            EffectModifier(
                opacity: opacity, blur: blur, saturate: saturate,
                brightness: brightness, grayscale: grayscale,
                blendMode: blendMode, objectFit: objectFit,
                cursor: cursor, userSelect: userSelect,
                pointerEvents: pointerEvents, fill: fill,
                backdropBlur: backdropBlur, condition: condition
            ))
    }
}
