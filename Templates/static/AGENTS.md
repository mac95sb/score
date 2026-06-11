# __NAME__ — Score Agent Reference

## Project Structure

```
Sources/
  Application.swift           — app entry point, theme, metadata, routes
  Views/Pages/                — Top-level pages (HomePage, AboutPage, etc.)
  Views/Pages/Blog/           — Blog-specific pages (BlogPostPage, etc.)
  Views/Components/           — Reusable View structs
Content/posts/                — Markdown files with YAML frontmatter
Public/                       — Static assets (copied verbatim to output)
```

---

## Critical Rules

**Never write raw HTML, CSS, or JavaScript strings.** This framework renders everything from the Swift DSL. The following are all forbidden:

```swift
// ❌ Raw HTML string
Stack { "<div class='foo'>hello</div>" }

// ❌ Inline style string
Stack { }.modifier(RawCSSModifier("display: flex"))
```

Always express layout and style through Score view types and modifiers.

**Do not chain repeated single-property modifier calls.** Combine them:

```swift
// ❌
Text { "hi" }.font(size: .lg).font(weight: .bold).font(color: .muted)

// ✅
Text { "hi" }.font(size: .lg, weight: .bold, color: .muted)
```

**Never double-wrap `AnyView` in ContentTheme closures.** Use `.erased()`:

```swift
// ❌
paragraph: { v in AnyView(AnyView(v).font(leading: .relaxed)) }

// ✅
paragraph: { v in v.erased().font(leading: .relaxed) }
```

---

## View Elements

### Content

| View | HTML | Notes |
|------|------|-------|
| `Text { … }` | `<p>` or `<span>` | Renders `<p>` for block/paragraph content, `<span>` for inline runs. Infers the correct tag from grammatical context automatically; override with `inline: true` / `inline: false`. |
| `Heading(_ level: Int) { … }` | `<h1>`…`<h6>` | level 1–6 |
| `RichText(markdown: String, theme:?)` | `<div class="rich-text">` | Renders markdown |
| `Code(_ value: String)` | `<code>` | Inline code |
| `CodeBlock(language:?, syntaxTheme:?) { … }` | `<pre><code>` | |
| `Badge { … }` | `<span>` | |
| `Blockquote { … }` | `<blockquote>` | |
| `Highlight { … }` | `<mark>` | |
| `Abbreviation(title:) { … }` | `<abbr>` | |
| `Subscript { … }` | `<sub>` | |
| `Superscript { … }` | `<sup>` | |
| `DateElement(_ date: Date)` | `<time>` | |
| `NumberElement(_ value:)` | text node | |

**CodeLanguage**: `.swift` `.js` `.ts` `.html` `.css` `.json` `.markdown` `.bash` `.python` `.sql` `.rust` `.go` `.yaml` `.toml` `.diff` `.text`

### Layout

| View | HTML | Notes |
|------|------|-------|
| `Stack { … }` | `<div>` | Generic container |
| `VStack { … }` | `<div>` | `flex-direction: column` |
| `HStack { … }` | `<div>` | `flex-direction: row` |
| `ZStack { … }` | `<div>` | `position: relative` for layering |
| `Grid(columns:?) { … }` | `<div>` | CSS Grid container |
| `ScrollView { … }` | `<div>` | Scrollable |
| `Spacer()` | `<div>` | `flex: 1` |
| `Divider()` | `<hr>` | |
| `EmptyView()` | — | Renders nothing |

### Navigation & Buttons

| View | HTML |
|------|------|
| `Link(to: String) { … }` | `<a>` — external auto-gets `target="_blank"` |
| `NavLink(to: String) { … }` | `<a>` — active-state aware |
| `Button(_ variant:, type:, disabled:) { … }` | `<button>` |

**ButtonVariant**: `.primary` `.secondary` `.ghost` `.destructive` `.icon` `.outline`

### Media

| View | HTML |
|------|------|
| `Image(_ src:, alt:, caption:?, width:?, height:?, loading:)` | `<img>` or `<figure>` |
| `Video(src:, poster:?, autoplay:, controls:, loop:, muted:)` | `<video>` |
| `Audio(src:, controls:, autoplay:, loop:, muted:)` | `<audio>` |

### Forms

`Form(action:?, method:)` `Input(type:, name:, placeholder:?, label:?, required:)` `Label(for:)` `Option(value:)` `OptionGroup(label:)` `Fieldset` `Legend`

**InputType**: `.text` `.email` `.password` `.number` `.tel` `.url` `.search` `.textarea` `.select` `.checkbox` `.radio` `.file` `.hidden` `.date` `.time` `.datetimeLocal` `.range` `.color`

### Lists & Tables

```swift
List(.unordered) { ListItem { … } }
// ListStyle: .unordered .ordered .decimal .alpha .none
DescriptionList { Term { … }; Description { … } }

Table(caption:?) {
    TableHeader { TableRow { TableCell(.header) { "Col" } } }
    TableBody   { TableRow { TableCell { "Data" } } }
}
// CellRole: .data .header
```

### Semantic

`Header` `Main` `Nav` `Section` `Article` `Aside` `Footer`
`Details(@ViewBuilder summary:) { … }` `Summary { … }`

### Utility

`ForEach(collection) { item in … }` — iterate collections  
`AnyView(_ view: any View)` — type erasure, avoid except at existential boundaries

---

## Modifiers

All modifiers return `ModifiedContent<Self, M>`. Combine parameters in one call.

### Spacing
```swift
.padding(_ all: SpacingValue)
.padding(_ vertical: SpacingValue, _ horizontal: SpacingValue)
.padding(x:?, y:?)
.padding(top:?, right:?, bottom:?, left:?)
.margin(_ all: SpacingValue)
.margin(x:?, y:?)
.margin(top:?, right:?, bottom:?, left:?)
```

### Sizing & Layout
```swift
.frame(width:?, height:?)
.frame(minWidth:?, maxWidth:?, minHeight:?, maxHeight:?)
.frame(aspectRatio: Double)
.flex(direction:?, wrap:?, align:?, justify:?, gap:?, columnGap:?, rowGap:?,
      grow:?, shrink:?, basis:?, alignSelf:?, order:?, placeItems:?)
.grid(columns:?, rows:?, gap:?, span:?, rowSpan:?, spanFull:?, autoFlow:?,
      placeItems:?, alignSelf:?, justifySelf:?)
.overflow(_ value: OverflowValue)
.overflow(x:?, y:?)
.display(_ value: DisplayValue)
.visibility(_ hidden: Bool)
```

### Positioning & Transform
```swift
.position(_ type: PositionType?, top:?, right:?, bottom:?, left:?, inset:?, zIndex:?)
.translate(x:?, y:?)
.scale(_ uniform: Double)
.scale(x:?, y:?)
.rotate(_ degrees: Double)
.skew(x:?, y:?)
.transformOrigin(_ origin: TransformOrigin)
```

### Visual
```swift
.background(color: Color)
.background(gradient: Gradient)
.background(image: String, size: BackgroundSize, position: BackgroundPosition)
.background(clip: BackgroundClip)
.border(color:?, width: Double = 1, edge:?, style: BorderStyle = .solid)
.border(radius: RadiusToken)
.border(radius px: Double)
.border(color:?, width:?, edge:?, style:?, radius:?)   // combined
.shadow(_ token: ShadowToken = .md, color:?)
.shadow(_ custom: String)
.shadow(ring: Double, color:?)
```

### Typography
```swift
// Prefer combined overload:
.font(size:?, weight:?, color:?, family:?, style:?, align:?, leading:?,
      tracking:?, wrap:?, decoration:?, transform:?, smoothing:?)
```

### Effects
```swift
.effect(opacity: Double)
.effect(blur: SpacingValue)
.effect(cursor: CursorValue)
.effect(objectFit: ObjectFit)
.effect(userSelect: UserSelect)
.effect(pointerEvents: Bool)
.effect(fill: Color)
.effect(blendMode: BlendMode)
.effect(grayscale: Bool)
.effect(brightness: Double)
.effect(saturate: Double)
.effect(backdropBlur: SpacingValue)
// Combined:
.effect(opacity:?, blur:?, saturate:?, brightness:?, grayscale:?,
        objectFit:?, cursor:?, userSelect:?, pointerEvents:?,
        fill:?, blendMode:?, backdropBlur:?)
```

### Animation
```swift
.animate(_ animation: Animation, duration: AnimationDuration,
         easing: AnimationTiming = .easeOut, delay: AnimationDuration = 0.ms)
.animate(_ transition: TransitionProperty, duration: AnimationDuration)
.animateChildren(_ animation: Animation, duration: 300.ms, stagger: 100.ms)
.animateOnScroll(_ animation: Animation, threshold: Double = 0.1)
.viewTransition(_ name: String)
```

### Conditional & Responsive
```swift
.on(.hover)   { $0.shadow(.md).translate(y: .px(-2)) }
.on(.dark)    { $0.background(color: .slate(900)) }
.at(.tablet)  { $0.padding(8) }
.at(.desktop) { $0.frame(maxWidth: .px(1024)) }
```

---

## Token Enums

### SpacingValue
```
Integer/float literals → step units (1 step = 4 px)
.px(Double)  .rem(Double)  .percent(Double)  .vw(Double)  .vh(Double)
.dvh(Double)  .fr(Double)  .auto  .full  .screen  .min  .max  .fit  .none
```

### FontSize
`.xs`(12px) `.sm`(14px) `.base`(16px) `.lg`(18px) `.xl`(20px) `.twoXL`(24px) `.threeXL`(30px) `.fourXL`(36px) `.fiveXL`(48px) `.sixXL`(60px) `.sevenXL`(72px) `.px(Double)`

### FontWeight
`.thin`(100) `.extraLight`(200) `.light`(300) `.regular`(400) `.medium`(500) `.semibold`(600) `.bold`(700) `.extraBold`(800) `.black`(900)

### Typography Enums
- **FontStyle**: `.normal` `.italic` `.oblique`
- **TextDecoration**: `.none` `.underline` `.overline` `.lineThrough`
- **TextTransform**: `.none` `.uppercase` `.lowercase` `.capitalize`
- **TextWrap**: `.wrap` `.nowrap` `.balance` `.pretty`
- **LineHeight**: `.none`(1) `.tight`(1.25) `.snug`(1.375) `.normal`(1.5) `.relaxed`(1.625) `.loose`(2) `.custom(Double)`
- **LetterSpacing**: `.tighter` `.tight` `.normal` `.wide` `.wider` `.widest` `.custom(Double)`
- **TextAlign**: `.start` `.end` `.left` `.right` `.center` `.justify`
- **FontSmoothing**: `.auto` `.antialiased` `.subpixel`

### Layout Enums
- **DisplayValue**: `.none` `.block` `.inline` `.inlineBlock` `.flex` `.inlineFlex` `.grid` `.inlineGrid` `.contents` `.table` `.listItem`
- **OverflowValue**: `.visible` `.hidden` `.scroll` `.auto` `.clip`
- **PositionType**: `.static` `.relative` `.absolute` `.fixed` `.sticky`
- **FlexDirection**: `.horizontal`(row) `.vertical`(column) `.horizontalReversed` `.verticalReversed`
- **FlexAlignment**: `.start` `.end` `.center` `.stretch` `.baseline` `.spaceBetween` `.spaceAround` `.spaceEvenly`
- **FlexWrap**: `.wrap` `.nowrap` `.wrapReverse`
- **GridAutoFlow**: `.row` `.column` `.rowDense` `.columnDense`
- **Edge**: `.top` `.right` `.bottom` `.left` `.x` `.y`

### Visual Enums
- **BorderStyle**: `.solid` `.dashed` `.dotted` `.double` `.none`
- **RadiusToken**: `.sm` `.md` `.lg` `.xl` `.twoXL` `.full`
- **ShadowToken**: `.sm` `.md` `.lg` `.xl` `.twoXL` `.inner` `.none`
- **ObjectFit**: `.fill` `.contain` `.cover` `.none` `.scaleDown`
- **CursorValue**: `.auto` `.default` `.pointer` `.wait` `.text` `.move` `.help` `.notAllowed` `.crosshair` `.grab` `.grabbing` `.zoomIn` `.zoomOut` `.noDrop` `.none`
- **BlendMode**: `.normal` `.multiply` `.screen` `.overlay` `.darken` `.lighten` `.colorDodge` `.colorBurn` `.hardLight` `.softLight` `.difference` `.exclusion` `.hue` `.saturation` `.color` `.luminosity`
- **UserSelect**: `.none` `.text` `.all` `.auto`
- **BackgroundSize**: `.cover` `.contain` `.auto` `.custom(String)`
- **BackgroundPosition**: `.center` `.top` `.bottom` `.left` `.right` `.topLeft` `.topRight` `.bottomLeft` `.bottomRight`
- **BackgroundClip**: `.text` `.border` `.padding` `.content`
- **TransformOrigin**: `.center` `.top` `.bottom` `.left` `.right` `.topLeft` `.topRight` `.bottomLeft` `.bottomRight` `.custom(SpacingValue, SpacingValue)`

### Animation Enums
- **Animation**: `.none` `.spin` `.ping` `.pulse` `.bounce` `.fadeIn` `.fadeOut` `.slideInLeft` `.slideInRight` `.slideInUp` `.slideInDown` `.custom(String)`
- **TransitionProperty**: `.all` `.transform` `.opacity` `.color` `.backgroundColor` `.border` `.shadow` `.filter` `.custom(String)`
- **AnimationTiming**: `.linear` `.ease` `.easeIn` `.easeOut` `.easeInOut` `.custom(String)`
- **AnimationIterations**: `.once` `.times(Int)` `.infinite`
- **AnimationDuration**: `Int.ms` / `Double.ms` — e.g. `300.ms`

### ModifierCondition
- **Pseudo-classes**: `.hover` `.focus` `.active` `.visited` `.disabled` `.checked` `.required` `.invalid` `.valid` `.empty` `.first` `.last` `.odd` `.even` `.backdrop`
- **Media**: `.dark` `.print` `.motion` `.portrait` `.landscape`
- **Breakpoints**: `.phone` `.tablet` `.desktop` `.wide` `.ultrawide`

---

## Color

### Semantic
```swift
Color.primary      // violet(600)
Color.accent       // emerald(400)
Color.surface      // white
Color.secondary    // slate(100)
Color.tertiary     // slate(50)
Color.text         // slate(900)
Color.muted        // slate(500)
Color.destructive  // rose(600)
Color.white  Color.black  Color.clear
```

### Palette
```swift
Color.slate(500)   // shade: 50–950
Color.gray(_:)  Color.zinc(_:)  Color.neutral(_:)  Color.stone(_:)
Color.red(_:)   Color.orange(_:)  Color.amber(_:)  Color.yellow(_:)
Color.lime(_:)  Color.green(_:)   Color.emerald(_:) Color.teal(_:)
Color.cyan(_:)  Color.sky(_:)     Color.blue(_:)   Color.indigo(_:)
Color.violet(_:) Color.purple(_:) Color.fuchsia(_:) Color.pink(_:) Color.rose(_:)
```

### Constructors & Mutations
```swift
Color(hex: "#7C3AED")
Color(oklch: 0.6, 0.22, 293)
Color(rgb: 124, 58, 237)
Color(hsl: 263, 69, 58)
color.opacity(0.5)
color.lighten(0.1)
color.darken(0.1)
color.mix(other, by: 0.5)
```

### Gradient
```swift
Gradient.linear(from: .primary, to: .accent, angle: 135)
Gradient.radial(from: .white, to: .slate(100))
Gradient.linearMulti(angle: 90, stops: [(.primary, 0), (.accent, 1)])
```

---

## Application & Routing

```swift
@main
struct MyApp: Application {
    var metadata: SiteMetadata {
        SiteMetadata(title: "Site", description: "…", baseURL: "https://example.com")
    }
    var theme: SiteTheme { .default }
    
    @RouteBuilder var routes: some RouteCollection {
        Page("/")       { req in HomePage() }
        Page("/about")  { req in AboutPage() }
        Page("/blog/:slug") { req in BlogPostPage(slug: req.parameters["slug"]!) }
    }
}
```

### Page Protocol
```swift
struct HomePage: Page {
    var metadata: PageMetadata? { PageMetadata(title: "Home") }
    var body: some View { Main { Heading(1) { "Hello" } } }
}
```

### StaticPage (pre-rendering)
```swift
extension BlogPostPage: StaticPage {
    var path: String { "/blog/\(slug)" }
    static func instances() async throws -> [BlogPostPage] { … }
}
```

---

## ContentTheme

Use `.erased()` to style `any View` in closures:

```swift
extension ContentTheme {
    static var article: ContentTheme {
        ContentTheme(
            heading:      { level, v in
                let size: FontSize = level == 1 ? .fourXL : level == 2 ? .threeXL : level == 3 ? .twoXL : .xl
                return v.erased().font(size: size, weight: .bold).margin(y: .rem(1))
            },
            paragraph:    { v in v.erased().font(size: .lg, leading: .relaxed).margin(y: .rem(0.75)) },
            link:         { v in v.erased().font(color: .primary, decoration: .underline) },
            strong:       { v in v.erased().font(weight: .semibold) },
            emphasis:     { v in v.erased().font(style: .italic) },
            strikethrough: { v in v.erased().font(decoration: .lineThrough) }
        )
    }
}
```

Built-in themes: `ContentTheme.default` (identity), `ContentTheme.blog` (article-optimised).

---

## String Literals as Views

`String` conforms to `View`. Use them directly in `@ViewBuilder`:

```swift
Heading(1) { "Hello World" }
Link(to: "/") { "Home" }
```

---

## CLI

```bash
score dev     # dev server with hot-reload
score build   # production static build
```
