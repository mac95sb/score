# __NAME__ — Score Agent Reference

## Project Structure

```
Sources/
  Application.swift           — app entry point, theme, metadata, route registration
  Models/                     — Record-conforming data models
  Views/Pages/                — Top-level pages (HomePage, etc.)
  Views/Pages/Blog/           — Blog-specific pages (BlogIndexPage, BlogPostPage)
  Views/Components/           — Reusable View structs
  Views/ContentThemes.swift   — ContentTheme extensions for RichText styling
  Controllers/                — RouteCollection controllers (pages + API)
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

// ❌ Inline script string (use ScoreHTTP WebSocket/SSE APIs instead)
Script { "document.getElementById('x').addEventListener(...)" }
```

Always express layout, style, and behaviour through Score view types and modifiers.

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
| `CodeBlock(language:?, syntaxTheme:?) { … }` | `<pre><code>` | Fenced code block |
| `Badge { … }` | `<span>` | Pill/tag label |
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
| `ScrollView(axis: .both) { … }` | `<div>` | Scrollable. Default axis is `.both`; use `.x` or `.y` to restrict. |
| `Spacer()` | `<div>` | `flex: 1` fill |
| `Divider()` | `<hr>` | |
| `EmptyView()` | — | Renders nothing |

### Navigation & Buttons

| View | HTML | Notes |
|------|------|-------|
| `Link(to: String) { … }` | `<a>` | External links auto-get `target="_blank"` |
| `NavLink(to: String) { … }` | `<a>` | Active-state aware nav link |
| `Button(_ variant:, type:, disabled:) { … }` | `<button>` | |

**ButtonVariant**: `.primary` `.secondary` `.ghost` `.destructive` `.icon` `.outline`  
**ButtonType**: `.button` `.submit` `.reset`

### Media

| View | HTML | Notes |
|------|------|-------|
| `Image(_ src: String, alt: String, caption:?, width:?, height:?, loading:)` | `<img>` or `<figure>` | |
| `Video(src:, poster:?, autoplay:, controls:, loop:, muted:)` | `<video>` | |
| `Audio(src:, controls:, autoplay:, loop:, muted:)` | `<audio>` | |

**ImageLoading**: `.lazy` `.eager` `.auto`

### Forms

| View | HTML | Notes |
|------|------|-------|
| `Form(action:?, method:) { … }` | `<form>` | |
| `Input(type:, name:, placeholder:?, value:?, label:?, required:, disabled:)` | `<input>`/`<textarea>`/`<select>` | |
| `Label(for:) { … }` | `<label>` | |
| `Option(value:, selected:?) { … }` | `<option>` | |
| `OptionGroup(label:) { … }` | `<optgroup>` | |
| `Fieldset { … }` | `<fieldset>` | |
| `Legend { … }` | `<legend>` | |

**InputType**: `.text` `.email` `.password` `.number` `.tel` `.url` `.search` `.textarea` `.select` `.checkbox` `.radio` `.file` `.hidden` `.date` `.time` `.datetimeLocal` `.range` `.color`

### Lists

| View | HTML |
|------|------|
| `List(_ style: ListStyle = .unordered) { … }` | `<ul>` or `<ol>` |
| `ListItem { … }` | `<li>` |
| `DescriptionList { … }` | `<dl>` |
| `Term { … }` | `<dt>` |
| `Description { … }` | `<dd>` |

**ListStyle**: `.unordered` `.ordered` `.decimal` `.alpha` `.none`

### Tables

```swift
Table(caption:?) {
    TableHeader { TableRow { TableCell(.header) { "Col" } } }
    TableBody  { TableRow { TableCell { "Data" } } }
    TableFooter { … }
}
```

**CellRole**: `.data` (default) `.header`

### Semantic

`Header` `Main` `Nav` `Section` `Article` `Aside` `Footer`  
`Details(@ViewBuilder summary:) { … }` `Summary { … }`

### Utility

| View | Notes |
|------|-------|
| `ForEach(collection) { item in … }` | Iterate collections |
| `AnyView(_ view: any View)` | Type erasure — avoid except at existential boundaries |

---

## Modifiers

All modifiers are chainable and return `ModifiedContent<Self, M>`. Combine parameters in a single call wherever possible.

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

.flex(direction:?, wrap:?, align:?, justify:?, gap:?,
      columnGap:?, rowGap:?, grow:?, shrink:?, basis:?,
      alignSelf:?, order:?, placeItems:?)

.grid(columns:?, rows:?, gap:?, columnGap:?, rowGap:?,
      span:?, rowSpan:?, spanFull:?, area:?,
      autoFlow:?, placeItems:?, alignSelf:?, justifySelf:?)

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
.border(color:?, width:?, edge:?, style:?, radius:?)        // combined

.shadow(_ token: ShadowToken = .md, color:?)
.shadow(_ custom: String)
.shadow(ring: Double, color:?)
```

### Typography

```swift
// Prefer the combined overload over separate calls:
.font(size:?, weight:?, color:?, family:?, style:?,
      align:?, leading:?, tracking:?, wrap:?,
      decoration:?, transform:?, smoothing:?)

// Available individually when only one property is needed:
.font(size: FontSize)
.font(weight: FontWeight)
.font(color: Color)
.font(family: FontFamily)
.font(leading: LineHeight)
.font(tracking: LetterSpacing)
.font(align: TextAlign)
.font(style: FontStyle)
.font(decoration: TextDecoration)
.font(transform: TextTransform)
.font(wrap: TextWrap)
.font(lineClamp: Int)
.font(truncate: Bool)
.font(smoothing: FontSmoothing)
```

### Effects

```swift
// Combined:
.effect(opacity:?, blur:?, saturate:?, brightness:?, grayscale:?,
        objectFit:?, cursor:?, userSelect:?, pointerEvents:?,
        fill:?, blendMode:?, backdropBlur:?)

// Individual:
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
.effect(willChange: String)
```

### Animation

```swift
.animate(_ animation: Animation, duration: AnimationDuration,
         easing: AnimationTiming = .easeOut, delay: AnimationDuration = 0.ms,
         iterations: AnimationIterations = .once)

.animate(_ transition: TransitionProperty, duration: AnimationDuration,
         easing: AnimationTiming = .easeInOut)

.animateChildren(_ animation: Animation, duration: AnimationDuration = 300.ms,
                 stagger: AnimationDuration = 100.ms)

.animateOnScroll(_ animation: Animation, threshold: Double = 0.1)
.viewTransition(_ name: String)
```

### Conditional & Responsive

```swift
// Interactive state
.on(.hover)   { $0.shadow(.md).translate(y: .px(-2)) }
.on(.focus)   { $0.shadow(ring: 2, color: .primary) }
.on(.active)  { $0.scale(0.98) }
.on(.dark)    { $0.background(color: .slate(900)) }

// Breakpoint (min-width)
.at(.tablet)  { $0.padding(8) }
.at(.desktop) { $0.frame(maxWidth: .px(1024)) }
```

---

## Token Enums

### SpacingValue
```
Integer/float literals → step units (1 step = 4 px)
.px(Double)    .rem(Double)    .percent(Double)
.vw(Double)    .vh(Double)     .dvh(Double)    .fr(Double)
.auto          .full (100%)    .screen         .min   .max   .fit   .none
```

### FontSize
`.xs` (12px)  `.sm` (14px)  `.base` (16px)  `.lg` (18px)  `.xl` (20px)  
`.twoXL` (24px)  `.threeXL` (30px)  `.fourXL` (36px)  `.fiveXL` (48px)  
`.sixXL` (60px)  `.sevenXL` (72px)  `.px(Double)`

### FontWeight
`.thin` (100)  `.extraLight` (200)  `.light` (300)  `.regular` (400)  
`.medium` (500)  `.semibold` (600)  `.bold` (700)  `.extraBold` (800)  `.black` (900)

### FontStyle · TextDecoration · TextTransform · TextWrap
- **FontStyle**: `.normal` `.italic` `.oblique`
- **TextDecoration**: `.none` `.underline` `.overline` `.lineThrough`
- **TextTransform**: `.none` `.uppercase` `.lowercase` `.capitalize`
- **TextWrap**: `.wrap` `.nowrap` `.balance` `.pretty`
- **FontSmoothing**: `.auto` `.antialiased` `.subpixel`

### LineHeight (leading) · LetterSpacing (tracking)
- **LineHeight**: `.none` (1)  `.tight` (1.25)  `.snug` (1.375)  `.normal` (1.5)  `.relaxed` (1.625)  `.loose` (2)  `.custom(Double)`
- **LetterSpacing**: `.tighter`  `.tight`  `.normal`  `.wide`  `.wider`  `.widest`  `.custom(Double)`

### TextAlign
`.start` `.end` `.left` `.right` `.center` `.justify`

### DisplayValue
`.none` `.block` `.inline` `.inlineBlock` `.flex` `.inlineFlex` `.grid` `.inlineGrid` `.contents` `.table` `.listItem`

### OverflowValue
`.visible` `.hidden` `.scroll` `.auto` `.clip`

### FlexDirection
`.horizontal` (row)  `.vertical` (column)  `.horizontalReversed`  `.verticalReversed`

### FlexAlignment
`.start` `.end` `.center` `.stretch` `.baseline` `.spaceBetween` `.spaceAround` `.spaceEvenly`

### FlexWrap
`.wrap` `.nowrap` `.wrapReverse`

### PositionType
`.static` `.relative` `.absolute` `.fixed` `.sticky`

### BorderStyle
`.solid` `.dashed` `.dotted` `.double` `.none`

### Edge
`.top` `.right` `.bottom` `.left` `.x` (left+right)  `.y` (top+bottom)

### RadiusToken
`.sm` `.md` `.lg` `.xl` `.twoXL` `.full`

### ShadowToken
`.sm` `.md` `.lg` `.xl` `.twoXL` `.inner` `.none`

### ModifierCondition (pseudo-classes)
`.hover` `.focus` `.active` `.visited` `.disabled` `.checked` `.required` `.invalid` `.valid` `.empty` `.first` `.last` `.odd` `.even` `.backdrop`

### ModifierCondition (media/breakpoints)
`.dark` `.print` `.motion` `.portrait` `.landscape`  
`.phone` `.tablet` `.desktop` `.wide` `.ultrawide`

### ObjectFit · CursorValue · BlendMode · UserSelect
- **ObjectFit**: `.fill` `.contain` `.cover` `.none` `.scaleDown`
- **CursorValue**: `.auto` `.default` `.pointer` `.wait` `.text` `.move` `.help` `.notAllowed` `.crosshair` `.grab` `.grabbing` `.zoomIn` `.zoomOut` `.noDrop` `.none`
- **BlendMode**: `.normal` `.multiply` `.screen` `.overlay` `.darken` `.lighten` `.colorDodge` `.colorBurn` `.hardLight` `.softLight` `.difference` `.exclusion` `.hue` `.saturation` `.color` `.luminosity`
- **UserSelect**: `.none` `.text` `.all` `.auto`

### Animation
**Animation**: `.none` `.spin` `.ping` `.pulse` `.bounce` `.fadeIn` `.fadeOut` `.slideInLeft` `.slideInRight` `.slideInUp` `.slideInDown` `.custom(String)`  
**TransitionProperty**: `.all` `.transform` `.opacity` `.color` `.backgroundColor` `.border` `.shadow` `.filter` `.custom(String)`  
**AnimationTiming**: `.linear` `.ease` `.easeIn` `.easeOut` `.easeInOut` `.custom(String)`  
**AnimationIterations**: `.once`  `.times(Int)` `.infinite`  
**AnimationDuration**: `Int.ms` / `Double.ms` (e.g. `300.ms`, `0.5.ms`)

### GridAutoFlow
`.row` `.column` `.rowDense` `.columnDense`

### BackgroundSize · BackgroundPosition · BackgroundClip
- **BackgroundSize**: `.cover` `.contain` `.auto` `.custom(String)`
- **BackgroundPosition**: `.center` `.top` `.bottom` `.left` `.right` `.topLeft` `.topRight` `.bottomLeft` `.bottomRight`
- **BackgroundClip**: `.text` `.border` `.padding` `.content`

### TransformOrigin
`.center` `.top` `.bottom` `.left` `.right` `.topLeft` `.topRight` `.bottomLeft` `.bottomRight` `.custom(SpacingValue, SpacingValue)`

---

## Color

### Semantic (theme-resolved)
```swift
Color.primary      // violet(600) by default
Color.accent       // emerald(400)
Color.surface      // white
Color.secondary    // slate(100)
Color.tertiary     // slate(50)
Color.text         // slate(900)
Color.muted        // slate(500)
Color.destructive  // rose(600)
Color.white  Color.black  Color.clear
```

### Tailwind v4 Palette
```swift
Color.slate(500)    // shade: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950
Color.gray(_:)      Color.zinc(_:)      Color.neutral(_:)   Color.stone(_:)
Color.red(_:)       Color.orange(_:)    Color.amber(_:)     Color.yellow(_:)
Color.lime(_:)      Color.green(_:)     Color.emerald(_:)   Color.teal(_:)
Color.cyan(_:)      Color.sky(_:)       Color.blue(_:)      Color.indigo(_:)
Color.violet(_:)    Color.purple(_:)    Color.fuchsia(_:)   Color.pink(_:)
Color.rose(_:)
```

### Color Initialisers & Mutations
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

### Application.swift
```swift
@main
struct MyApp: Application {
    var metadata: SiteMetadata {
        SiteMetadata(title: "Site", description: "…", baseURL: "https://example.com")
    }
    var theme: SiteTheme { .default }  // customise colors, fonts, spacing
    
    @RouteBuilder var routes: some RouteCollection {
        PostsController()
        Page("/")      { req in HomePage() }
        Page("/about") { req in AboutPage() }
    }
}
```

### RouteCollection
```swift
struct PostsController: RouteCollection {
    var routes: [Route] {
        RouteGroup("/blog") {
            Page("/")       { req in BlogIndexPage() }
            Page("/:slug")  { req in try await BlogPostPage(slug: req.parameters["slug"]!) }
        }
        RouteGroup(api: "/posts") {
            GET("/")    { req in try Response.json(posts) }
            POST("/")   { req in try Response.json(newPost) }
            PUT("/:id") { req in try Response.json(updated) }
            DELETE("/:id") { req in Response(status: .noContent) }
        }
    }
}
```

### Page Protocol
```swift
struct BlogPostPage: Page {
    let post: Post
    
    var metadata: PageMetadata? {
        PageMetadata(title: post.title, description: post.excerpt)
    }
    
    var contentTheme: ContentTheme { .article }
    
    var body: some View {
        Main {
            Article {
                Heading(1) { post.title }
                RichText(markdown: post.body)
            }
        }
    }
}
```

### StaticPage (SSG pre-rendering)
```swift
extension BlogPostPage: StaticPage {
    var path: String { "/blog/\(post.slug)" }
    static func instances() async throws -> [BlogPostPage] {
        let store = try ContentStore<Post>()
        return try await store.all().map { BlogPostPage(post: $0) }
    }
}
```

---

## ContentTheme

Used by `RichText` to style rendered markdown elements. Always use `.erased()` to bridge the `any View` existential:

```swift
extension ContentTheme {
    static var article: ContentTheme {
        ContentTheme(
            heading: { level, v in
                let size: FontSize = level == 1 ? .fourXL : level == 2 ? .threeXL : level == 3 ? .twoXL : .xl
                return v.erased().font(size: size, weight: .bold).margin(y: .rem(1))
            },
            paragraph:    { v in v.erased().font(size: .lg, leading: .relaxed).margin(y: .rem(0.75)) },
            code:         { v in v.erased().font(family: .systemMono).padding(.px(2), .px(6)).border(radius: .sm).background(color: .surface) },
            blockquote:   { v in v.erased().border(color: .primary, width: 4, edge: .left).padding(left: 4).margin(y: .rem(1)) },
            list:         { _, v in v.erased().margin(y: .rem(0.75)).padding(left: 6) },
            listItem:     { v in v },
            table:        { v in v.erased().margin(y: .rem(1)) },
            link:         { v in v.erased().font(color: .primary, decoration: .underline) },
            image:        { v in v.erased().border(radius: .lg).margin(y: .rem(1.5)) },
            divider:      { v in v.erased().margin(y: .rem(2)) },
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

`String` conforms to `View`. Embed text directly inside `@ViewBuilder` closures without a wrapping element:

```swift
Heading(1) { "Hello World" }
Text { "Welcome, \(user.name)" }
Link(to: "/") { "Home" }
```

---

## CLI

```bash
score dev            # dev server with hot-reload
score build          # production static build
score new <name>     # scaffold a new project
```
