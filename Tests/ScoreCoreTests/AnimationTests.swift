import Testing

@testable import ScoreCore

@Suite("Animation")
struct AnimationTests {

    // MARK: - KeyframeAnimation

    @Test("keyframesCSS starts with @keyframes")
    func keyframesCSSFormat() {
        let anim = KeyframeAnimation("my-anim") {
            KeyFrame(0) { [AnimOpacity(0)] }
            KeyFrame(100) { [AnimOpacity(1)] }
        }
        let css = anim.keyframesCSS()
        #expect(css.hasPrefix("@keyframes my-anim"))
    }

    @Test("keyframesCSS contains both keyframe stops")
    func keyframesBothStops() {
        let anim = KeyframeAnimation("fade") {
            KeyFrame(0) { [AnimOpacity(0)] }
            KeyFrame(100) { [AnimOpacity(1)] }
        }
        let css = anim.keyframesCSS()
        #expect(css.contains("0%"))
        #expect(css.contains("100%"))
        #expect(css.contains("opacity"))
    }

    @Test("keyframesCSS includes declared CSS properties")
    func keyframeProperties() {
        let anim = KeyframeAnimation("slide") {
            KeyFrame(0) { [AnimTranslateY(.px(20)), AnimOpacity(0)] }
            KeyFrame(100) { [AnimTranslateY(.px(0)), AnimOpacity(1)] }
        }
        let css = anim.keyframesCSS()
        #expect(css.contains("translateY"))
        #expect(css.contains("opacity"))
    }

    // MARK: - Built-in animations

    @Test("built-in fadeIn has correct name")
    func fadeInName() {
        #expect(KeyframeAnimation.fadeIn.name == "score-fade-in")
    }

    @Test("built-in fadeUp has correct name")
    func fadeUpName() {
        #expect(KeyframeAnimation.fadeUp.name == "score-fade-up")
    }

    @Test("built-in slideInLeft has correct name")
    func slideInLeftName() {
        #expect(KeyframeAnimation.slideInLeft.name == "score-slide-in-left")
    }

    @Test("built-in scaleIn has two keyframe stops")
    func scaleInStops() {
        #expect(KeyframeAnimation.scaleIn.frames.count == 2)
    }

    @Test("all built-in animations emit valid @keyframes CSS")
    func allBuiltinsValid() {
        let builtins: [KeyframeAnimation] = [
            .fadeIn, .fadeOut, .fadeUp, .fadeDown,
            .slideInLeft, .slideInRight, .slideInUp, .slideInDown,
            .scaleIn,
        ]
        for anim in builtins {
            let css = anim.keyframesCSS()
            #expect(css.hasPrefix("@keyframes score-"), "Expected @keyframes prefix for \(anim.name)")
            #expect(css.contains("{"))
            #expect(css.hasSuffix("}"))
        }
    }

    // MARK: - AnimationModifier CSS output

    @Test("AnimationModifier emits animation-name declaration")
    func animationModifierDeclarations() {
        let mod = AnimationModifier(
            animationName: "score-fade-in",
            duration: 300.ms,
            easing: .easeOut,
            delay: 0.ms,
            iterations: .once,
            fillMode: "both"
        )
        let decls = mod.cssDeclarations()
        let names = decls.map(\.property)
        #expect(names.contains("animation-name") || names.contains("animation"))
    }
}
