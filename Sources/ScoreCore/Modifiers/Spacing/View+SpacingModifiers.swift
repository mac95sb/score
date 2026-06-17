// MARK: - Spacing modifiers (padding, margin, frame)

extension View {

    // MARK: Padding

    /// Apply equal padding on all sides.
    public func padding(_ all: SpacingValue, on condition: ModifierCondition? = nil) -> ModifiedContent<Self, PaddingModifier> {
        modifier(PaddingModifier(all: all, condition: condition))
    }

    /// Apply equal padding on all sides at a responsive breakpoint.
    public func padding(_ all: SpacingValue, at condition: ModifierCondition) -> ModifiedContent<Self, PaddingModifier> {
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

    /// Apply equal margin on all sides at a responsive breakpoint.
    public func margin(_ all: SpacingValue, at condition: ModifierCondition) -> ModifiedContent<Self, MarginModifier> {
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
}
