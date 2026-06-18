// MARK: - TranslateModifier

/// A modifier that applies a CSS `translateX`/`translateY` transform.
///
/// Use ``View/translate(x:y:on:)`` rather than constructing `TranslateModifier` directly.
///
/// ```swift
/// Card { ... }
///     .on(.hover) { $0.translate(y: .px(-4)) }
///     .animate(.transform, duration: 150.ms)
/// ```
///
/// - SeeAlso: ``View/translate(x:y:on:)``, ``ScaleModifier``, ``RotateModifier``
public struct TranslateModifier: ThemeAwareModifier {
    let x: SpacingValue?
    let y: SpacingValue?
    let condition: ModifierCondition?

    public init(x: SpacingValue? = nil, y: SpacingValue? = nil, condition: ModifierCondition? = nil) {
        self.x = x
        self.y = y
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        let value: String
        switch (x, y) {
        case (let x?, let y?):
            value = "translate(\(x.css),\(y.css))"
        case (let x?, nil):
            value = "translateX(\(x.css))"
        case (nil, let y?):
            value = "translateY(\(y.css))"
        case (nil, nil):
            return []
        }
        return [ConditionedDeclaration("transform", value, condition: condition)]
    }
}

// MARK: - ScaleModifier

/// A modifier that applies a CSS `scale` or `scaleX`/`scaleY` transform.
///
/// Use ``View/scale(_:on:)`` and ``View/scale(x:y:on:)`` rather than constructing
/// `ScaleModifier` directly.
///
/// - SeeAlso: ``View/scale(_:on:)``, ``TranslateModifier``
public struct ScaleModifier: ThemeAwareModifier {
    let x: Double?
    let y: Double?
    let condition: ModifierCondition?

    public init(x: Double? = nil, y: Double? = nil, condition: ModifierCondition? = nil) {
        self.x = x
        self.y = y
        self.condition = condition
    }

    public init(uniform: Double, condition: ModifierCondition? = nil) {
        self.x = uniform
        self.y = uniform
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        let value: String
        switch (x, y) {
        case (let x?, let y?) where x == y:
            value = "scale(\(x.cssStr))"
        case (let x?, let y?):
            value = "scale(\(x.cssStr),\(y.cssStr))"
        case (let x?, nil):
            value = "scaleX(\(x.cssStr))"
        case (nil, let y?):
            value = "scaleY(\(y.cssStr))"
        case (nil, nil):
            return []
        }
        return [ConditionedDeclaration("transform", value, condition: condition)]
    }
}

// MARK: - RotateModifier

/// A modifier that applies a CSS `rotate(Ndeg)` transform.
///
/// Use ``View/rotate(_:on:)`` rather than constructing `RotateModifier` directly.
///
/// - SeeAlso: ``View/rotate(_:on:)``, ``TranslateModifier``
public struct RotateModifier: ThemeAwareModifier {
    let degrees: Double
    let condition: ModifierCondition?

    public init(degrees: Double, condition: ModifierCondition? = nil) {
        self.degrees = degrees
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("transform", "rotate(\(degrees.cssStr)deg)", condition: condition)]
    }
}

// MARK: - SkewModifier

/// A modifier that applies a CSS `skewX`/`skewY` transform.
///
/// Use ``View/skew(x:y:on:)`` rather than constructing `SkewModifier` directly.
///
/// - SeeAlso: ``View/skew(x:y:on:)``, ``TranslateModifier``
public struct SkewModifier: ThemeAwareModifier {
    let x: Double?
    let y: Double?
    let condition: ModifierCondition?

    public init(x: Double? = nil, y: Double? = nil, condition: ModifierCondition? = nil) {
        self.x = x
        self.y = y
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        let value: String
        switch (x, y) {
        case (let x?, let y?):
            value = "skew(\(x.cssStr)deg,\(y.cssStr)deg)"
        case (let x?, nil):
            value = "skewX(\(x.cssStr)deg)"
        case (nil, let y?):
            value = "skewY(\(y.cssStr)deg)"
        case (nil, nil):
            return []
        }
        return [ConditionedDeclaration("transform", value, condition: condition)]
    }
}

// MARK: - TransformOriginModifier

/// A modifier that sets the CSS `transform-origin` property.
///
/// Use ``View/transformOrigin(_:on:)`` rather than constructing
/// `TransformOriginModifier` directly.
///
/// - SeeAlso: ``View/transformOrigin(_:on:)``, ``TranslateModifier``
public struct TransformOriginModifier: ThemeAwareModifier {
    let origin: TransformOrigin
    let condition: ModifierCondition?

    public init(origin: TransformOrigin, condition: ModifierCondition? = nil) {
        self.origin = origin
        self.condition = condition
    }

    public func declarations(theme: SiteTheme) -> [ConditionedDeclaration] {
        [ConditionedDeclaration("transform-origin", origin.css, condition: condition)]
    }
}
