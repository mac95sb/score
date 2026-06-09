import Foundation

// MARK: - Padding

extension View {

    // MARK: Padding

    /// Apply equal padding on all sides.
    public func padding(_ all: SpacingValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, PaddingModifier> {
        modifier(PaddingModifier(all: all, condition: condition))
    }

    /// Apply vertical and horizontal padding.
    public func padding(_ vertical: SpacingValue, _ horizontal: SpacingValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, PaddingModifier> {
        modifier(PaddingModifier(x: horizontal, y: vertical, condition: condition))
    }

    /// Apply axis-specific padding.
    public func padding(x: SpacingValue? = nil, y: SpacingValue? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, PaddingModifier> {
        modifier(PaddingModifier(x: x, y: y, condition: condition))
    }

    /// Apply per-edge padding.
    public func padding(
        top: SpacingValue? = nil,
        right: SpacingValue? = nil,
        bottom: SpacingValue? = nil,
        left: SpacingValue? = nil
    ) -> ModifiedContent<Self, PaddingModifier> {
        modifier(PaddingModifier(top: top, right: right, bottom: bottom, left: left))
    }

    // MARK: Margin

    /// Apply equal margin on all sides.
    public func margin(_ all: SpacingValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, MarginModifier> {
        modifier(MarginModifier(all: all, condition: condition))
    }

    /// Apply axis-specific margin.
    public func margin(x: SpacingValue? = nil, y: SpacingValue? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, MarginModifier> {
        modifier(MarginModifier(x: x, y: y, condition: condition))
    }

    /// Apply per-edge margin.
    public func margin(
        top: SpacingValue? = nil,
        right: SpacingValue? = nil,
        bottom: SpacingValue? = nil,
        left: SpacingValue? = nil
    ) -> ModifiedContent<Self, MarginModifier> {
        modifier(MarginModifier(top: top, right: right, bottom: bottom, left: left))
    }

    // MARK: Frame

    /// Constrain the width and/or height.
    public func frame(width: SpacingValue? = nil, height: SpacingValue? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, FrameModifier> {
        modifier(FrameModifier(width: width, height: height, condition: condition))
    }

    /// Constrain min/max dimensions.
    public func frame(
        minWidth: SpacingValue? = nil,
        maxWidth: SpacingValue? = nil,
        minHeight: SpacingValue? = nil,
        maxHeight: SpacingValue? = nil,
        on condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, FrameModifier> {
        modifier(FrameModifier(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight, condition: condition))
    }

    /// Apply an aspect ratio.
    public func frame(aspectRatio: Double) -> ModifiedContent<Self, FrameModifier> {
        modifier(FrameModifier(aspectRatio: aspectRatio))
    }

    // MARK: Flex

    /// Apply flex layout properties.
    public func flex(
        direction: FlexDirection? = nil,
        wrap: FlexWrap? = nil,
        align: FlexAlignment? = nil,
        justify: FlexAlignment? = nil,
        gap: SpacingValue? = nil,
        columnGap: SpacingValue? = nil,
        rowGap: SpacingValue? = nil,
        grow: Int? = nil,
        shrink: Int? = nil,
        basis: SpacingValue? = nil,
        alignSelf: FlexAlignment? = nil,
        order: FlexOrder? = nil,
        placeItems: String? = nil,
        at condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, FlexModifier> {
        modifier(FlexModifier(
            direction: direction, wrap: wrap, align: align, justify: justify,
            gap: gap, columnGap: columnGap, rowGap: rowGap,
            grow: grow, shrink: shrink, basis: basis,
            alignSelf: alignSelf, order: order, placeItems: placeItems,
            condition: condition
        ))
    }

    // MARK: Grid modifier

    /// Apply grid layout properties.
    public func grid(
        columns: Int? = nil,
        rows: String? = nil,
        gap: SpacingValue? = nil,
        columnGap: SpacingValue? = nil,
        rowGap: SpacingValue? = nil,
        span: Int? = nil,
        rowSpan: Int? = nil,
        spanFull: Bool? = nil,
        area: String? = nil,
        autoFlow: GridAutoFlow? = nil,
        placeItems: String? = nil,
        alignSelf: String? = nil,
        justifySelf: String? = nil,
        at condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, GridModifier> {
        modifier(GridModifier(
            columns: columns, rows: rows, gap: gap,
            columnGap: columnGap, rowGap: rowGap,
            span: span, rowSpan: rowSpan, spanFull: spanFull,
            area: area, autoFlow: autoFlow, placeItems: placeItems,
            alignSelf: alignSelf, justifySelf: justifySelf,
            condition: condition
        ))
    }

    // MARK: Position

    /// Apply CSS positioning.
    public func position(
        _ type: PositionType? = nil,
        top: SpacingValue? = nil,
        right: SpacingValue? = nil,
        bottom: SpacingValue? = nil,
        left: SpacingValue? = nil,
        inset: SpacingValue? = nil,
        zIndex: Int? = nil
    ) -> ModifiedContent<Self, PositionModifier> {
        modifier(PositionModifier(
            type: type, top: top, right: right, bottom: bottom,
            left: left, inset: inset, zIndex: zIndex
        ))
    }

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

    // MARK: Overflow

    /// Set overflow on both axes.
    public func overflow(_ value: OverflowValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, OverflowModifier> {
        modifier(OverflowModifier(both: value, condition: condition))
    }

    /// Set overflow independently on X and Y axes.
    public func overflow(x: OverflowValue? = nil, y: OverflowValue? = nil, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, OverflowModifier> {
        modifier(OverflowModifier(x: x, y: y, condition: condition))
    }

    // MARK: Display

    /// Set the CSS `display` property.
    public func display(_ value: DisplayValue, at condition: ModifierCondition? = nil) -> ModifiedContent<Self, DisplayModifier> {
        modifier(DisplayModifier(value, condition: condition))
    }

    /// Toggle CSS visibility.
    public func visibility(_ hidden: Bool, at condition: ModifierCondition? = nil) -> ModifiedContent<Self, VisibilityModifier> {
        modifier(VisibilityModifier(hidden: hidden, condition: condition))
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

    /// Apply a border with optional color, width, edge, and style.
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
    public func border(radius: RadiusToken, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, BorderRadiusModifier> {
        modifier(BorderRadiusModifier(radius: radius, condition: condition))
    }

    /// Apply a border radius as a raw pixel value.
    public func border(radius px: Double) -> ModifiedContent<Self, BorderRadiusModifier> {
        modifier(BorderRadiusModifier(radiusPx: px))
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

    // MARK: Font

    /// Set font size.
    public func font(size: FontSize, at condition: ModifierCondition? = nil) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(size: size, condition: condition))
    }

    /// Set font weight.
    public func font(weight: FontWeight, at condition: ModifierCondition? = nil) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(weight: weight, condition: condition))
    }

    /// Set text color.
    public func font(color: Color, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(color: color, condition: condition))
    }

    /// Set font family.
    public func font(family: FontFamily) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(family: family))
    }

    /// Set line height (leading).
    public func font(leading: LineHeight) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(leading: leading))
    }

    /// Set letter spacing (tracking).
    public func font(tracking: LetterSpacing) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(tracking: tracking))
    }

    /// Set text alignment.
    public func font(align: TextAlign) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(align: align))
    }

    /// Set text transform.
    public func font(transform: TextTransform) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(transform: transform))
    }

    /// Set text decoration.
    public func font(decoration: TextDecoration) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(decoration: decoration))
    }

    /// Set font style.
    public func font(style: FontStyle) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(style: style))
    }

    /// Set text wrap.
    public func font(wrap: TextWrap) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(wrap: wrap))
    }

    /// Clamp text to a fixed number of lines.
    public func font(lineClamp: Int) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(lineClamp: lineClamp))
    }

    /// Truncate text to a single line with an ellipsis.
    public func font(truncate: Bool) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(truncate: truncate))
    }

    /// Set font smoothing.
    public func font(smoothing: FontSmoothing) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(smoothing: smoothing))
    }

    // MARK: Animation

    /// Apply a CSS animation.
    public func animate(
        _ animation: Animation,
        duration: AnimationDuration,
        easing: AnimationTiming = .easeOut,
        delay: AnimationDuration = 0.ms,
        iterations: AnimationIterations = .once,
        fill: String = "both"
    ) -> ModifiedContent<Self, AnimationModifier> {
        modifier(AnimationModifier(
            animationName: animation.css,
            duration: duration,
            easing: easing,
            delay: delay,
            iterations: iterations,
            fillMode: fill
        ))
    }

    /// Apply a CSS transition on a property.
    public func animate(
        _ transition: TransitionProperty,
        duration: AnimationDuration,
        easing: AnimationTiming = .easeInOut,
        delay: AnimationDuration = 0.ms
    ) -> ModifiedContent<Self, TransitionModifier> {
        modifier(TransitionModifier(property: transition, duration: duration, easing: easing, delay: delay))
    }

    // MARK: - Conditional variant helpers

    /// Apply modifiers only under the given state condition (e.g. `.hover`, `.focus`).
    ///
    /// The closure receives `self` so callers can chain additional modifiers conditionally:
    /// ```swift
    /// Button { "Click" }.on(.hover) { $0.background(color: .violet(700)) }
    /// ```
    public func on(_ condition: ModifierCondition, @ViewBuilder content: (Self) -> some View) -> some View {
        ConditionGroupView(condition: condition, content: content(self))
    }

    /// Apply modifiers at the given responsive breakpoint.
    ///
    /// ```swift
    /// Card().at(.tablet) { $0.frame(width: .full) }
    /// ```
    public func at(_ breakpoint: ModifierCondition, @ViewBuilder content: (Self) -> some View) -> some View {
        ConditionGroupView(condition: breakpoint, content: content(self))
    }
}

// MARK: - ConditionalModifier

/// A modifier that wraps another modifier with a condition, used for `.on(_:)` variants.
public struct ConditionalModifier<Wrapped: ThemeAwareModifier>: ThemeAwareModifier {
    let wrapped: Wrapped
    let overrideCondition: ModifierCondition

    public init(_ wrapped: Wrapped, condition: ModifierCondition) {
        self.wrapped = wrapped; self.overrideCondition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        wrapped.declarations(theme: theme).map {
            ConditionedDeclaration($0.property, $0.value, condition: overrideCondition)
        }
    }
}
