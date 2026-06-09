import Foundation

/// A CSS keyframe animation definition.
///
/// ```swift
/// let fadeUp = KeyframeAnimation("fade-up") {
///     KeyFrame(0)   { AnimOpacity(0); AnimTranslateY(.px(20)) }
///     KeyFrame(100) { AnimOpacity(1); AnimTranslateY(.px(0)) }
/// }
///
/// Heading(1) { "Welcome" }
///     .animate(fadeUp, duration: 600.ms, easing: .easeOut)
/// ```
public struct KeyframeAnimation: Sendable {
    public let name: String
    public let frames: [KeyFrame]

    public init(_ name: String, @KeyframeBuilder frames: () -> [KeyFrame]) {
        self.name = name
        self.frames = frames()
    }

    /// Emit the `@keyframes` CSS block for this animation.
    public func keyframesCSS() -> String {
        var css = "@keyframes \(name){"
        for frame in frames {
            css += "\(frame.percent)%{"
            css += frame.properties.map { $0.css }.joined(separator: ";")
            css += "}"
        }
        css += "}"
        return css
    }

    // MARK: - Built-in animations

    public static let fadeIn = KeyframeAnimation("score-fade-in") {
        KeyFrame(0)   { [AnimOpacity(0)] }
        KeyFrame(100) { [AnimOpacity(1)] }
    }

    public static let fadeOut = KeyframeAnimation("score-fade-out") {
        KeyFrame(0)   { [AnimOpacity(1)] }
        KeyFrame(100) { [AnimOpacity(0)] }
    }

    public static let fadeUp = KeyframeAnimation("score-fade-up") {
        KeyFrame(0)   { [AnimOpacity(0), AnimTranslateY(.px(20))] }
        KeyFrame(100) { [AnimOpacity(1), AnimTranslateY(.px(0))] }
    }

    public static let fadeDown = KeyframeAnimation("score-fade-down") {
        KeyFrame(0)   { [AnimOpacity(0), AnimTranslateY(.px(-20))] }
        KeyFrame(100) { [AnimOpacity(1), AnimTranslateY(.px(0))] }
    }

    public static let slideInLeft = KeyframeAnimation("score-slide-in-left") {
        KeyFrame(0)   { [AnimTranslateX(.percent(-100))] }
        KeyFrame(100) { [AnimTranslateX(.percent(0))] }
    }

    public static let slideInRight = KeyframeAnimation("score-slide-in-right") {
        KeyFrame(0)   { [AnimTranslateX(.percent(100))] }
        KeyFrame(100) { [AnimTranslateX(.percent(0))] }
    }

    public static let slideInUp = KeyframeAnimation("score-slide-in-up") {
        KeyFrame(0)   { [AnimTranslateY(.percent(100))] }
        KeyFrame(100) { [AnimTranslateY(.percent(0))] }
    }

    public static let slideInDown = KeyframeAnimation("score-slide-in-down") {
        KeyFrame(0)   { [AnimTranslateY(.percent(-100))] }
        KeyFrame(100) { [AnimTranslateY(.percent(0))] }
    }

    public static let scaleIn = KeyframeAnimation("score-scale-in") {
        KeyFrame(0)   { [AnimScale(0.95), AnimOpacity(0)] }
        KeyFrame(100) { [AnimScale(1),    AnimOpacity(1)] }
    }

    public static let scaleOut = KeyframeAnimation("score-scale-out") {
        KeyFrame(0)   { [AnimScale(1),    AnimOpacity(1)] }
        KeyFrame(100) { [AnimScale(0.95), AnimOpacity(0)] }
    }

    public static let spin = KeyframeAnimation("score-spin") {
        KeyFrame(0)   { [AnimRotate(0)] }
        KeyFrame(100) { [AnimRotate(360)] }
    }

    public static let ping = KeyframeAnimation("score-ping") {
        KeyFrame(75)  { [AnimScale(2), AnimOpacity(0)] }
        KeyFrame(100) { [AnimScale(2), AnimOpacity(0)] }
    }

    public static let pulse = KeyframeAnimation("score-pulse") {
        KeyFrame(0)   { [AnimOpacity(1)] }
        KeyFrame(50)  { [AnimOpacity(0.5)] }
        KeyFrame(100) { [AnimOpacity(1)] }
    }

    public static let bounce = KeyframeAnimation("score-bounce") {
        KeyFrame(0)   { [AnimTranslateY(.percent(0))] }
        KeyFrame(50)  { [AnimTranslateY(.percent(-25))] }
        KeyFrame(100) { [AnimTranslateY(.percent(0))] }
    }

    public static let shimmer = KeyframeAnimation("score-shimmer") {
        KeyFrame(0)   { [AnimTranslateX(.percent(-100))] }
        KeyFrame(100) { [AnimTranslateX(.percent(100))] }
    }

    public static let shake = KeyframeAnimation("score-shake") {
        KeyFrame(0)   { [AnimTranslateX(.px(0))] }
        KeyFrame(10)  { [AnimTranslateX(.px(-10))] }
        KeyFrame(30)  { [AnimTranslateX(.px(10))] }
        KeyFrame(50)  { [AnimTranslateX(.px(-10))] }
        KeyFrame(70)  { [AnimTranslateX(.px(10))] }
        KeyFrame(90)  { [AnimTranslateX(.px(-10))] }
        KeyFrame(100) { [AnimTranslateX(.px(0))] }
    }

    /// CSS for all built-in animations.
    public static func builtInKeyframesCSS() -> String {
        [fadeIn, fadeOut, fadeUp, fadeDown,
         slideInLeft, slideInRight, slideInUp, slideInDown,
         scaleIn, scaleOut, spin, ping, pulse, bounce, shimmer, shake]
            .map { $0.keyframesCSS() }
            .joined()
    }
}

// MARK: - Keyframe Builder

@resultBuilder
public struct KeyframeBuilder {
    public static func buildBlock(_ frames: KeyFrame...) -> [KeyFrame] { frames }
}

// MARK: - KeyFrame

/// A single keyframe at a given percentage along the animation timeline.
public struct KeyFrame: Sendable {
    public let percent: Int
    public let properties: [any AnimationProperty]

    public init(_ percent: Int, properties: () -> [any AnimationProperty]) {
        self.percent = percent
        self.properties = properties()
    }
}

// MARK: - AnimationProperty

/// A single CSS property declared inside a keyframe.
public protocol AnimationProperty: Sendable {
    var css: String { get }
}

// MARK: - Built-in AnimationProperty types

/// Opacity keyframe property.
public struct AnimOpacity: AnimationProperty {
    let value: Double
    public init(_ value: Double) { self.value = value }
    public var css: String { "opacity:\(value.cssStr)" }
}

/// Vertical translate keyframe property.
public struct AnimTranslateY: AnimationProperty {
    let value: SpacingValue
    public init(_ value: SpacingValue) { self.value = value }
    public var css: String { "transform:translateY(\(value.css))" }
}

/// Horizontal translate keyframe property.
public struct AnimTranslateX: AnimationProperty {
    let value: SpacingValue
    public init(_ value: SpacingValue) { self.value = value }
    public var css: String { "transform:translateX(\(value.css))" }
}

/// Scale keyframe property.
public struct AnimScale: AnimationProperty {
    let value: Double
    public init(_ value: Double) { self.value = value }
    public var css: String { "transform:scale(\(value.cssStr))" }
}

/// Rotation keyframe property.
public struct AnimRotate: AnimationProperty {
    let degrees: Double
    public init(_ degrees: Double) { self.degrees = degrees }
    public var css: String { "transform:rotate(\(degrees.cssStr)deg)" }
}
