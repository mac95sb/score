// MARK: - FontModifier

/// A modifier that applies CSS typography properties to an element.
///
/// Create instances through the ``View/font(size:at:)`` family of methods rather
/// than constructing `FontModifier` directly. Multiple `.font()` calls on the
/// same view accumulate — each call sets only the properties it specifies.
///
/// ```swift
/// Heading(1) { "Title" }
///     .font(size: .fourXL)
///     .font(weight: .bold)
///     .font(wrap: .balance)
///
/// Text { "Body copy" }
///     .font(size: .lg)
///     .font(leading: .relaxed)
///     .font(color: .muted)
/// ```
///
/// - SeeAlso: ``View/font(size:at:)``, ``FontSize``, ``FontWeight``, ``LineHeight``
public struct FontModifier: ThemeAwareModifier {
    let size: FontSize?
    let weight: FontWeight?
    let family: FontFamily?
    let color: Color?
    let leading: LineHeight?
    let tracking: LetterSpacing?
    let align: TextAlign?
    let transform: TextTransform?
    let decoration: TextDecoration?
    let decorationColor: Color?
    let decorationStyle: DecorationStyle?
    let style: FontStyle?
    let variant: FontVariant?
    let wrap: TextWrap?
    let lineClamp: Int?
    let truncate: Bool?
    let whitespace: WhiteSpace?
    let wordBreak: WordBreak?
    let hyphens: String?
    let numeric: String?
    let smoothing: FontSmoothing?
    let rendering: String?
    let condition: ModifierCondition?

    public init(
        size: FontSize? = nil,
        weight: FontWeight? = nil,
        family: FontFamily? = nil,
        color: Color? = nil,
        leading: LineHeight? = nil,
        tracking: LetterSpacing? = nil,
        align: TextAlign? = nil,
        transform: TextTransform? = nil,
        decoration: TextDecoration? = nil,
        decorationColor: Color? = nil,
        decorationStyle: DecorationStyle? = nil,
        style: FontStyle? = nil,
        variant: FontVariant? = nil,
        wrap: TextWrap? = nil,
        lineClamp: Int? = nil,
        truncate: Bool? = nil,
        whitespace: WhiteSpace? = nil,
        wordBreak: WordBreak? = nil,
        hyphens: String? = nil,
        numeric: String? = nil,
        smoothing: FontSmoothing? = nil,
        rendering: String? = nil,
        condition: ModifierCondition? = nil
    ) {
        self.size = size; self.weight = weight; self.family = family
        self.color = color; self.leading = leading; self.tracking = tracking
        self.align = align; self.transform = transform; self.decoration = decoration
        self.decorationColor = decorationColor; self.decorationStyle = decorationStyle
        self.style = style; self.variant = variant; self.wrap = wrap
        self.lineClamp = lineClamp; self.truncate = truncate
        self.whitespace = whitespace; self.wordBreak = wordBreak
        self.hyphens = hyphens; self.numeric = numeric; self.smoothing = smoothing
        self.rendering = rendering; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = []

        if let s = size        { result.append(ConditionedDeclaration("font-size",          s.css,              condition: condition)) }
        if let w = weight      { result.append(ConditionedDeclaration("font-weight",         w.css,              condition: condition)) }
        if let f = family      { result.append(ConditionedDeclaration("font-family",         f.css,              condition: condition)) }
        if let c = color       { result.append(ConditionedDeclaration("color",               c.cssValue,         condition: condition)) }
        if let l = leading     { result.append(ConditionedDeclaration("line-height",         l.css,              condition: condition)) }
        if let t = tracking    { result.append(ConditionedDeclaration("letter-spacing",      t.css,              condition: condition)) }
        if let a = align       { result.append(ConditionedDeclaration("text-align",          a.rawValue,         condition: condition)) }
        if let t = transform   { result.append(ConditionedDeclaration("text-transform",      t.rawValue,         condition: condition)) }
        if let d = decoration  { result.append(ConditionedDeclaration("text-decoration",     d.rawValue,         condition: condition)) }
        if let dc = decorationColor { result.append(ConditionedDeclaration("text-decoration-color", dc.cssValue, condition: condition)) }
        if let ds = decorationStyle { result.append(ConditionedDeclaration("text-decoration-style", ds.rawValue, condition: condition)) }
        if let s = style       { result.append(ConditionedDeclaration("font-style",          s.rawValue,         condition: condition)) }
        if let v = variant     { result.append(ConditionedDeclaration("font-variant",        v.rawValue,         condition: condition)) }
        if let w = wrap        { result.append(ConditionedDeclaration("text-wrap",           w.rawValue,         condition: condition)) }

        // Line clamp: multi-line ellipsis truncation
        if let lc = lineClamp {
            result.append(ConditionedDeclaration("display",              "-webkit-box",       condition: condition))
            result.append(ConditionedDeclaration("-webkit-line-clamp",   "\(lc)",             condition: condition))
            result.append(ConditionedDeclaration("-webkit-box-orient",   "vertical",          condition: condition))
            result.append(ConditionedDeclaration("overflow",             "hidden",            condition: condition))
        }

        // Single-line truncation
        if let t = truncate, t {
            result.append(ConditionedDeclaration("overflow",      "hidden",    condition: condition))
            result.append(ConditionedDeclaration("text-overflow", "ellipsis",  condition: condition))
            result.append(ConditionedDeclaration("white-space",   "nowrap",    condition: condition))
        }

        if let ws = whitespace { result.append(ConditionedDeclaration("white-space",          ws.rawValue,        condition: condition)) }
        if let wb = wordBreak  { result.append(ConditionedDeclaration("word-break",           wb.rawValue,        condition: condition)) }
        if let h = hyphens     { result.append(ConditionedDeclaration("hyphens",              h,                  condition: condition)) }
        if let n = numeric     { result.append(ConditionedDeclaration("font-variant-numeric",  n,                  condition: condition)) }

        if let sm = smoothing {
            switch sm {
            case .auto:
                result.append(ConditionedDeclaration("-webkit-font-smoothing", "auto",      condition: condition))
                result.append(ConditionedDeclaration("moz-osx-font-smoothing", "auto",      condition: condition))
            case .antialiased:
                result.append(ConditionedDeclaration("-webkit-font-smoothing", "antialiased",   condition: condition))
                result.append(ConditionedDeclaration("moz-osx-font-smoothing", "grayscale",     condition: condition))
            case .subpixel:
                result.append(ConditionedDeclaration("-webkit-font-smoothing", "subpixel-antialiased", condition: condition))
                result.append(ConditionedDeclaration("moz-osx-font-smoothing", "auto",                condition: condition))
            }
        }

        if let r = rendering   { result.append(ConditionedDeclaration("text-rendering",       r,                  condition: condition)) }

        return result
    }
}
