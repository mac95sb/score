# Modifier System

Style any view with Score's complete CSS modifier API — no stylesheets, no class names.

## Overview

Score owns all styles. There is no `.class()` modifier, no raw CSS escape
hatch, and no external stylesheet integration. Every CSS property is surfaced
as a typed modifier. If a modifier is missing, that is a framework gap — file
an issue.

Modifiers produce native CSS nesting. `ArticleCard` with a hover shadow becomes:

```css
.article-card {
  &:hover { box-shadow: var(--shadow-md); }
}
```

## Spacing

```swift
.padding(6)                  // all sides — step 6 = 24px
.padding(x: 4, y: 6)        // horizontal / vertical
.padding(top: 8)             // single edge
.padding(.px(14))            // explicit off-scale value
.padding(6, at: .desktop)    // responsive

.margin(x: .auto)            // horizontal centering
.margin(y: 8)
.margin(top: 4)
```

## Sizing

```swift
.frame(width: .full)
.frame(width: .px(320))
.frame(maxWidth: .px(1200))
.frame(height: .screen)
.frame(minHeight: .dvh(100))
.frame(aspectRatio: 16/9)
.frame(maxWidth: 10, at: .desktop)
```

## Typography

```swift
.font(size: .lg)
.font(size: .fourXL, at: .desktop)
.font(weight: .semibold)
.font(family: .heading)
.font(color: .primary)
.font(color: .muted, on: .dark)
.font(leading: .relaxed)
.font(tracking: .tight)
.font(align: .center)
.font(transform: .uppercase)
.font(decoration: .underline)
.font(style: .italic)
.font(wrap: .balance)
.font(lineClamp: 3)
.font(smoothing: .antialiased)
```

## Flexbox

```swift
.flex(direction: .horizontal)
.flex(direction: .vertical)
.flex(align: .center)
.flex(justify: .spaceBetween)
.flex(gap: 4)
.flex(wrap: .wrap)
.flex(grow: 1)
.flex(shrink: 0)
.flex(direction: .horizontal, at: .tablet)  // responsive
```

## CSS Grid

```swift
.grid(columns: 3)
.grid(columns: 2, at: .tablet)
.grid(columns: "repeat(auto-fill, minmax(240px, 1fr))")
.grid(gap: 6)
.grid(span: 2)
.grid(spanFull: true)
```

## Visual

```swift
.background(color: .surface)
.background(color: .primary.opacity(0.05))
.background(gradient: .linear(from: .primary, to: .accent, angle: 135))
.background(image: "/hero.jpg", size: .cover, position: .center)

.border(color: .muted.opacity(0.2))
.border(color: .primary, width: 2, edge: .bottom)
.border(radius: .lg)
.border(radius: .full)
.border(outline: .primary, width: 2)

.shadow(.sm)
.shadow(.md)
.shadow(.lg)
.shadow(.md, color: .primary.opacity(0.3))
.shadow(ring: 2, color: .primary.opacity(0.4))
```

## Effects

```swift
.effect(opacity: 0.5)
.effect(blur: .md)
.effect(saturate: 150)
.effect(cursor: .pointer)
.effect(objectFit: .cover)
.effect(userSelect: .none)
.effect(pointerEvents: .none)
.effect(willChange: .transform)
```

## State Variants

Apply modifiers conditionally on interactive states:

```swift
// Single property — inline on: parameter
Text { "Label" }
    .font(color: .primary, on: .hover)
    .font(color: .muted, on: .dark)

// Multiple properties — trailing closure
Button(.primary) { "Submit" }
    .on(.hover) {
        $0.background(color: .primary(700))
          .translate(y: .px(-1))
          .shadow(.md)
    }
    .on(.focus) { $0.shadow(ring: 2, color: .primary.opacity(0.5)) }
    .on(.active) { $0.scale(0.97) }
    .on(.disabled) {
        $0.effect(opacity: 0.5)
          .effect(cursor: .notAllowed)
    }
```

Available variants: `.hover`, `.focus` (maps to `:focus-visible`), `.active`,
`.visited`, `.disabled`, `.checked`, `.dark`, `.print`, `.motion`,
`.portrait`, `.landscape`, `.backdrop`

## Responsive Modifiers

```swift
// Single property — inline at: parameter
.font(size: .twoXL)
.font(size: .fourXL, at: .desktop)

// Multiple properties — trailing closure
Stack { ... }
    .padding(4)
    .at(.tablet) {
        $0.padding(8).flex(direction: .horizontal)
    }
    .at(.desktop) {
        $0.padding(12).grid(columns: 3)
    }
```

Breakpoints: `phone` 480pt, `tablet` 768pt, `desktop` 1024pt, `wide` 1280pt, `ultrawide` 1536pt.

## Transforms

```swift
.translate(y: -2)                // step -2 = -8px
.translate(x: .percent(-100))    // slide from offscreen
.scale(0.98)
.scale(x: 1.05, y: 0.95)
.rotate(45)
.skew(x: 6, y: 3)
.transformOrigin(.center)
```

> Note: Translate uses the spacing scale with negative values allowed.
> `.translate(y: -4)` is -16px (step 4).

## Animations

Score has two distinct animation systems with different purposes.

### Transitions — `animate(_:TransitionProperty, …)`

Transitions interpolate between CSS property states when a value changes
(e.g. on hover, after a state update). They answer *"how does this change?"*

```swift
// Smooth out all property changes
.animate(.all, duration: 200.ms)

// Only animate the transform property
.animate(.transform, duration: 300.ms, easing: .easeOut)

// Physics-based spring easing
.animate(.transform, duration: 400.ms, easing: .spring(stiffness: 300, damping: 30))
```

### Keyframe Animations — `animate(_:KeyframeAnimation, …)`

Keyframe animations play a named `@keyframes` sequence. They answer
*"what does this element do on entry / on loop?"*

```swift
// Use a built-in keyframe sequence
.animate(KeyframeAnimation.fadeUp, duration: 600.ms, easing: .easeOut)
.animate(KeyframeAnimation.slideInLeft, duration: 400.ms)
.animate(KeyframeAnimation.bounce, duration: 800.ms, iterations: .infinite)

// Define a custom keyframe sequence
let heroReveal = KeyframeAnimation("hero-reveal") {
    KeyFrame(0)   { [AnimOpacity(0), AnimScale(0.95), AnimTranslateY(.px(12))] }
    KeyFrame(100) { [AnimOpacity(1), AnimScale(1.0),  AnimTranslateY(.px(0))]  }
}

Heading(1) { "Welcome" }
    .animate(heroReveal, duration: 500.ms, easing: .easeOut)
```

### Scroll-triggered Animations

Play a keyframe animation when the element enters the viewport:

```swift
Card { … }
    .animateOnScroll(KeyframeAnimation.fadeUp, threshold: 0.15)

// Stagger children with increasing delays
Grid(columns: 3) { … }
    .animateChildren(KeyframeAnimation.fadeUp, duration: 400.ms, stagger: 80.ms)
```

All animation output is wrapped in `@media (prefers-reduced-motion: no-preference)` — users who prefer reduced motion see no animations.

## Conditional Modifiers

Use Swift's own conditional expressions — no Score-specific mini-DSL:

```swift
// Two states — ternary on the value is idiomatic
Stack { ... }
    .background(color: isError ? .destructive(50) : .surface)

// Multiple properties — extracted computed property
var statusCard: some View {
    Stack { ... }
        .background(color: isError ? .destructive(50) : .surface)
        .border(color: isError ? .destructive : .muted.opacity(0.2))
        .font(color: isError ? .destructive : .text)
}
```

Score infers static vs reactive from the condition type. Ternary on a `let`
resolves at render time (zero JS). Ternary on `@State` emits a data-attribute
driven toggle — same source syntax either way.

## CSS Output

Score generates native CSS nesting (baseline 2024). Every modifier on a view
nests inside the component's CSS class block:

```css
.article-card {
  padding: 24px;
  border-radius: 12px;

  &:hover {
    box-shadow: var(--shadow-lg);
    transform: translateY(-2px);
  }

  @media (min-width: 1024px) {
    padding: 32px;
  }
}
```

## Related Concepts

- <doc:ThemeAndTokens> — the token values modifiers resolve to
- <doc:ViewHierarchy> — the views modifiers are applied to
