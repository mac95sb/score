// MARK: - AnimationTiming extensions
//
// The base `AnimationTiming` enum is defined in Modifiers/Values/AnimationValues.swift.
// This file adds factory helpers and additional derived timing functions
// that are useful when authoring `KeyframeAnimation` definitions.

extension AnimationTiming {

    // MARK: Cubic-bezier factory

    /// A custom cubic-bezier timing function.
    ///
    /// ```swift
    /// .cubicBezier(0.34, 1.56, 0.64, 1)   // spring-like overshoot
    /// ```
    public static func cubicBezier(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> AnimationTiming {
        .custom("cubic-bezier(\(x1.cssStr),\(y1.cssStr),\(x2.cssStr),\(y2.cssStr))")
    }

    // MARK: Spring approximation

    /// An approximate spring timing function expressed as a cubic-bezier curve.
    ///
    /// - Parameters:
    ///   - stiffness: Spring stiffness (positive). Higher values produce a snappier animation.
    ///   - damping: Spring damping ratio. Values < 1 overshoot; 1 is critically damped.
    public static func spring(stiffness: Double, damping: Double) -> AnimationTiming {
        // Map stiffness/damping onto a cubic-bezier that approximates spring physics.
        // A simple heuristic: tension drives the overshoot of the y control point.
        let tension = max(0.05, min(1.5, stiffness / 300.0))
        let y2 = damping < 1.0 ? 1.0 + tension : 1.0
        return .custom("cubic-bezier(0.34,\(y2.cssStr),0.64,1)")
    }

    // MARK: Step timing

    /// Jump to the final value at the start of each step interval (`step-start`).
    public static let stepStart: AnimationTiming = .custom("step-start")

    /// Jump to the final value at the end of each step interval (`step-end`).
    public static let stepEnd: AnimationTiming = .custom("step-end")

    /// A stepped timing function with `n` equal intervals.
    ///
    /// - Parameters:
    ///   - count: Number of steps.
    ///   - jumpTerm: One of `"jump-start"`, `"jump-end"`, `"jump-none"`, `"jump-both"`.
    ///     Defaults to `"jump-end"` (equivalent to CSS `steps(n, end)`).
    public static func steps(_ count: Int, _ jumpTerm: String = "jump-end") -> AnimationTiming {
        .custom("steps(\(count),\(jumpTerm))")
    }
}
