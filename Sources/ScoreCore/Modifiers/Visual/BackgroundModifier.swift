// MARK: - BackgroundColorModifier

/// A modifier that sets the CSS `background-color` of an element.
///
/// Use ``View/background(color:on:)`` rather than constructing this type directly.
///
/// ```swift
/// Card { ... }
///     .background(color: .surface)
///     .background(color: .primary(50), on: .dark)
/// ```
///
/// - SeeAlso: ``View/background(color:on:)``, ``BackgroundGradientModifier``
public struct BackgroundColorModifier: ThemeAwareModifier {
    let color: Color
    let condition: ModifierCondition?

    public init(color: Color, condition: ModifierCondition? = nil) {
        self.color = color; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("background-color", color.cssValue, condition: condition)]
    }
}

// MARK: - BackgroundGradientModifier

public struct BackgroundGradientModifier: ThemeAwareModifier {
    let gradient: Gradient
    let condition: ModifierCondition?

    public init(gradient: Gradient, condition: ModifierCondition? = nil) {
        self.gradient = gradient; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("background", gradient.css, condition: condition)]
    }
}

// MARK: - BackgroundImageModifier

public struct BackgroundImageModifier: ThemeAwareModifier {
    let url: String
    let size: BackgroundSize
    let position: BackgroundPosition
    let condition: ModifierCondition?

    public init(url: String, size: BackgroundSize = .cover, position: BackgroundPosition = .center, condition: ModifierCondition? = nil) {
        self.url = url; self.size = size; self.position = position; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [
            ConditionedDeclaration("background-image",    "url(\(url))",       condition: condition),
            ConditionedDeclaration("background-size",     size.css,            condition: condition),
            ConditionedDeclaration("background-position", position.rawValue,   condition: condition)
        ]
    }
}

// MARK: - BackgroundClipModifier

public struct BackgroundClipModifier: ThemeAwareModifier {
    let clip: BackgroundClip
    let condition: ModifierCondition?

    public init(clip: BackgroundClip, condition: ModifierCondition? = nil) {
        self.clip = clip; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        var result: [ConditionedDeclaration] = [
            ConditionedDeclaration("background-clip", clip.rawValue, condition: condition)
        ]
        // Text clip requires -webkit- prefix for broader browser support
        if clip == .text {
            result.insert(ConditionedDeclaration("-webkit-background-clip", "text", condition: condition), at: 0)
        }
        return result
    }
}

// MARK: - BackgroundAttachmentModifier

public struct BackgroundAttachmentModifier: ThemeAwareModifier {
    public enum Attachment: String, Sendable { case scroll, fixed, local }
    let attachment: Attachment
    let condition: ModifierCondition?

    public init(attachment: Attachment, condition: ModifierCondition? = nil) {
        self.attachment = attachment; self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("background-attachment", attachment.rawValue, condition: condition)]
    }
}
