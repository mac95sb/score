# Modifier System

Style any view with Score's complete CSS modifier API.

## Overview

Modifiers are chainable methods on ``View`` that emit CSS declarations directly
onto the element they're applied to. Each modifier corresponds to one or more
CSS properties — `.padding(6)` emits `padding: 24px`, `.border(radius: .lg)`
emits `border-radius: 12px`, `.shadow(.md)` emits `box-shadow: var(--shadow-md)`.

Modifiers produce native CSS nesting, scoped to the component's auto-derived
class name. An `ArticleCard` with a hover shadow compiles to:

```css
.article-card {
  &:hover { box-shadow: var(--shadow-md); }
}
```

Values that reference the theme — colours, radii, shadows — are emitted as CSS
custom property references so they automatically track dark mode and palette
switches.

## Spacing

The spacing scale converts step numbers to pixel values using a 4 pt base unit.
Step 6 = 24px, step 8 = 32px, step 12 = 48px.

```swift
.padding(6)  // all sides — step 6 = 24px
    .padding(x: 4, y: 6)  // horizontal / vertical
    .padding(top: 8)  // single edge
    .padding(.px(14))  // explicit off-scale value

    .margin(x: .auto)  // horizontal centering
    .margin(y: 8)
    .margin(top: 4)
```

## Sizing

```swift
.frame(width: .full)  // width: 100%
    .frame(width: .px(320))  // explicit px value
    .frame(maxWidth: .px(1200))  // max-width constraint
    .frame(height: .screen)  // height: 100vh
    .frame(minHeight: .dvh(100))  // min-height: 100dvh
    .frame(aspectRatio: 16 / 9)  // aspect-ratio: 1.78

    // Spacing scale applies to frame too
    .frame(width: 64)  // step 64 = 256px
    .frame(height: 48)  // step 48 = 192px
```

Available size values: `.px(n)`, `.rem(n)`, `.percent(n)`, `.vw(n)`, `.vh(n)`,
`.dvh(n)`, `.auto`, `.full`, `.screen`, `.min`, `.max`, `.fit`, or a step number.

## Typography

Combine multiple font properties in one call when they belong to the same
typographic decision:

```swift
.font(size: .threeXL, weight: .bold)
    .font(size: .xl, color: .muted, leading: .relaxed)
```

| Modifier | Purpose |
| -------- | ------- |
| `.font(size: .lg)` | Font size |
| `.font(weight: .semibold)` | Font weight — `.thin` through `.black` |
| `.font(family: .heading)` | Font family from the theme |
| `.font(color: .primary)` | Text colour |
| `.font(leading: .relaxed)` | Line height |
| `.font(tracking: .tight)` | Letter spacing |
| `.font(align: .center)` | Text alignment |
| `.font(transform: .uppercase)` | Text transform |
| `.font(decoration: .underline)` | Text decoration |
| `.font(style: .italic)` | Font style |
| `.font(wrap: .balance)` | Text wrapping strategy |
| `.font(lineClamp: 3)` | Clamp to a fixed number of lines |
| `.font(smoothing: .antialiased)` | Font smoothing |

## Flexbox

Combine properties in a single call for a clear layout declaration:

```swift
.flex(direction: .horizontal, align: .center, gap: 4)
    .flex(direction: .vertical, gap: 6)
```

| Modifier | Purpose |
| -------- | ------- |
| `.flex(direction: .horizontal)` | `flex-direction: row` |
| `.flex(direction: .vertical)` | `flex-direction: column` |
| `.flex(align: .center)` | Cross-axis alignment |
| `.flex(justify: .spaceBetween)` | Main-axis distribution |
| `.flex(gap: 4)` | Gap between children (spacing scale) |
| `.flex(wrap: .wrap)` | Enable flex wrapping |
| `.flex(grow: 1)` | Allow a view to grow |
| `.flex(shrink: 0)` | Prevent a view from shrinking |

## CSS Grid

```swift
.grid(columns: 3)
    .grid(columns: "repeat(auto-fill, minmax(240px, 1fr))")
    .grid(gap: 6)
    .grid(span: 2)
    .grid(spanFull: true)
```

## Visual — Borders, Backgrounds, Shadows

Combine border properties when they belong to the same declaration:

```swift
.border(color: .muted.opacity(0.2), radius: .lg)
```

| Modifier | Purpose |
| -------- | ------- |
| `.background(color: .surface)` | Solid background colour |
| `.background(color: .primary.opacity(0.05))` | Translucent background |
| `.background(gradient: .linear(from: .primary, to: .accent, angle: 135))` | Gradient |
| `.background(image: "/hero.jpg", size: .cover, position: .center)` | Image background |
| `.border(color: .muted.opacity(0.2))` | Border colour |
| `.border(color: .primary, width: 2, edge: .bottom)` | Single edge border |
| `.border(radius: .lg)` | Rounded corners |
| `.border(radius: .full)` | Pill shape |
| `.border(outline: .primary, width: 2)` | Outline ring |

```swift
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

## Transforms

```swift
.translate(y: -2)  // step -2 = -8px; negative values allowed
    .translate(x: .percent(-100))  // slide from offscreen
    .scale(0.98)
    .scale(x: 1.05, y: 0.95)
    .rotate(45)
    .skew(x: 6, y: 3)
    .transformOrigin(.center)
```

## Overflow and Positioning

```swift
.overflow(.hidden)
    .overflow(.scroll)
    .position(.sticky, top: 0)
    .position(zIndex: 10)
    .position(.absolute, top: 0, right: 0)
```

## Transitions

Transitions interpolate between CSS values when a property changes — on hover,
after a state update, or when a class is toggled:

```swift
.animate(.all, duration: 200.ms)
    .animate(.transform, duration: 300.ms, easing: .easeOut)
    .animate(.transform, duration: 400.ms, easing: .spring(stiffness: 300, damping: 30))
```

## Keyframe Animations

Keyframe animations play a named `@keyframes` sequence on entry or on a loop.
Pass a `KeyframeAnimation` value to the second overload of `.animate`:

```swift
.animate(KeyframeAnimation.fadeUp, duration: 600.ms, easing: .easeOut)
    .animate(KeyframeAnimation.slideInLeft, duration: 400.ms)
    .animate(KeyframeAnimation.bounce, duration: 800.ms, iterations: .infinite)
```

Define a custom sequence when the built-ins do not cover your case:

```swift
let heroReveal = KeyframeAnimation("hero-reveal") {
    KeyFrame(0) { [AnimOpacity(0), AnimScale(0.95), AnimTranslateY(.px(12))] }
    KeyFrame(100) { [AnimOpacity(1), AnimScale(1.0), AnimTranslateY(.px(0))] }
}

Heading(1) { "Welcome" }
    .animate(heroReveal, duration: 500.ms, easing: .easeOut)
```

All animation output is wrapped in `@media (prefers-reduced-motion: no-preference)`
automatically.

## State Variants

Apply modifiers that activate on interactive or media states using `.on(_:)`:

```swift
// Single property — use the inline on: parameter
Text { "Label" }
    .font(color: .primary, on: .hover)
    .font(color: .muted, on: .dark)

// Multiple properties — use the trailing closure form
Button(.primary) { "Submit" }
    .on(.hover) {
        $0.background(color: .primary(700))
            .translate(y: .px(-1))
            .shadow(.md)
    }
    .on(.focus) { $0.shadow(ring: 2, color: .primary.opacity(0.5)) }
    .on(.active) { $0.scale(0.97) }
    .on(.disabled) { $0.effect(opacity: 0.5).effect(cursor: .notAllowed) }
```

Available variants: `.hover`, `.focus` (`:focus-visible`), `.active`,
`.visited`, `.disabled`, `.checked`, `.dark`, `.print`, `.motion`,
`.portrait`, `.landscape`, `.backdrop`

## Responsive Modifiers

Breakpoints: `phone` 480pt · `tablet` 768pt · `desktop` 1024pt · `wide` 1280pt · `ultrawide` 1536pt

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

## Conditional Modifiers

Swift's own conditional expressions drive modifier branching:

```swift
// Ternary on a constant resolves at render time — no JS emitted
Stack { ... }
    .background(color: isError ? .destructive(50) : .surface)

// Multiple properties — extract a computed view property
var statusCard: some View {
    Stack { ... }
        .background(color: isError ? .destructive(50) : .surface)
        .border(color: isError ? .destructive : .muted.opacity(0.2))
        .font(color: isError ? .destructive : .text)
}
```

Conditions on `@State` values emit a data-attribute-driven DOM toggle; conditions
on constants fold away at render time with no JavaScript output.

## CSS Output

Score generates native CSS nesting (Baseline 2024), scoped to each component:

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

> Tip: Colour values like `.primary`, `.surface`, and `.muted`, and size tokens
> like `.lg`, `.threeXL`, and `.md` are resolved from your `SiteTheme`. See
> <doc:ThemeAndTokens> for the full token catalogue and how to customise them.

## See Also

- <doc:ThemeAndTokens>
- <doc:ViewHierarchy>
- <doc:ReactiveState>
