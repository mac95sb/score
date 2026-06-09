// MARK: - FrameModifier

public struct FrameModifier: ThemeAwareModifier {
    let width: SpacingValue?
    let minWidth: SpacingValue?
    let maxWidth: SpacingValue?
    let height: SpacingValue?
    let minHeight: SpacingValue?
    let maxHeight: SpacingValue?
    let aspectRatio: Double?
    let condition: ModifierCondition?

    public init(
        width: SpacingValue? = nil,
        minWidth: SpacingValue? = nil,
        maxWidth: SpacingValue? = nil,
        height: SpacingValue? = nil,
        minHeight: SpacingValue? = nil,
        maxHeight: SpacingValue? = nil,
        aspectRatio: Double? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.width = width; self.minWidth = minWidth; self.maxWidth = maxWidth
        self.height = height; self.minHeight = minHeight; self.maxHeight = maxHeight
        self.aspectRatio = aspectRatio; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []
        if let w  = width     { result.append(ConditionedDeclaration("width",      w.css,          condition: condition)) }
        if let mw = minWidth  { result.append(ConditionedDeclaration("min-width",  mw.css,         condition: condition)) }
        if let xw = maxWidth  { result.append(ConditionedDeclaration("max-width",  xw.css,         condition: condition)) }
        if let h  = height    { result.append(ConditionedDeclaration("height",     h.cssHeight,    condition: condition)) }
        if let mh = minHeight { result.append(ConditionedDeclaration("min-height", mh.cssHeight,   condition: condition)) }
        if let xh = maxHeight { result.append(ConditionedDeclaration("max-height", xh.cssHeight,   condition: condition)) }
        if let ar = aspectRatio {
            // Express as "w / h" — for a simple ratio we approximate as integer pairs when clean
            let arStr: String
            if ar == 1.0 {
                arStr = "1 / 1"
            } else if ar == 16.0 / 9.0 {
                arStr = "16 / 9"
            } else if ar == 4.0 / 3.0 {
                arStr = "4 / 3"
            } else if ar == 3.0 / 2.0 {
                arStr = "3 / 2"
            } else if ar == 21.0 / 9.0 {
                arStr = "21 / 9"
            } else {
                arStr = ar.cssStr
            }
            result.append(ConditionedDeclaration("aspect-ratio", arStr, condition: condition))
        }
        return result
    }
}
