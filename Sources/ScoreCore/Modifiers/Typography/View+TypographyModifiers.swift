// MARK: - Typography modifiers (font)

extension View {

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

    /// Set multiple typography properties in one call.
    ///
    /// Use this overload when you need two or more font properties at once.
    /// Single-property calls (e.g. `.font(size: .lg)`) resolve to the more
    /// specific single-parameter overloads above.
    ///
    /// ```swift
    /// Heading(1) { "Title" }
    ///     .font(size: .fourXL, weight: .bold, wrap: .balance)
    /// Text { "Subtitle" }
    ///     .font(size: .xl, color: .muted)
    /// ```
    public func font(
        size: FontSize? = nil,
        weight: FontWeight? = nil,
        color: Color? = nil,
        family: FontFamily? = nil,
        style: FontStyle? = nil,
        align: TextAlign? = nil,
        leading: LineHeight? = nil,
        tracking: LetterSpacing? = nil,
        wrap: TextWrap? = nil,
        decoration: TextDecoration? = nil,
        transform: TextTransform? = nil,
        smoothing: FontSmoothing? = nil,
        on condition: ModifierCondition? = nil
    ) -> ModifiedContent<Self, FontModifier> {
        modifier(FontModifier(
            size: size, weight: weight, family: family, color: color,
            leading: leading, tracking: tracking, align: align, transform: transform,
            decoration: decoration, style: style, wrap: wrap, smoothing: smoothing,
            condition: condition
        ))
    }
}
