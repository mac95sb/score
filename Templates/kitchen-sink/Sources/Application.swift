import Foundation
import Score

// MARK: - Application

@main
struct KitchenSink: Application {
    var metadata: SiteMetadata {
        SiteMetadata(
            siteName: "Kitchen Sink",
            titleSeparator: " – ",
            description: "A live showcase of every Score system: elements, modifiers, themes, state, animation, routing, and data.",
            baseURL: "https://example.com"
        )
    }

    var theme: SiteTheme {
        // Palettes unify built-in colour schemes and open-source dev themes — all are
        // ThemeColors and swap the same CSS vars. Presets swap radii + shadows only.
        // data-theme="dark"/"light" is emitted automatically when darkColors is set.
        var t = SiteTheme.preset(.modern, palette: .ocean)
        t.customPalettes = [
            // Score built-in colour palettes
            "violet":           ThemePalette.violet.light,
            "indigo":           ThemePalette.indigo.light,
            "forest":           ThemePalette.forest.light,
            "sunset":           ThemePalette.sunset.light,
            "midnight":         ThemePalette.midnight.light,
            "berry":            ThemePalette.berry.light,
            "ember":            ThemePalette.ember.light,
            "rose":             ThemePalette.rose.light,
            // Open-source developer colour palettes
            "rose-pine":        .rosePine,
            "rose-pine-dawn":   .rosePineDawn,
            "tokyo-night":      .tokyoNight,
            "tokyo-night-storm":.tokyoNightStorm,
            "vesper":           .vesper,
            "one-dark":         .oneDark,
            "gruvbox-dark":     .gruvboxDark,
            "gruvbox-light":    .gruvboxLight,
        ]
        t.customPresets = Dictionary(uniqueKeysWithValues:
            ThemePreset.allCases.map { ($0.rawValue, $0.presetOverride) }
        )
        return t
    }

    var routes: some RouteCollection {
        Page("/")        { KitchenSinkPage() }
        Page("/about")   { AboutPage() }
        Page("/blog")    { BlogIndexPage() }
        BlogPostPage.self
    }
}

// MARK: - Root page

struct KitchenSinkPage: Page {
    var metadata: PageMetadata? {
        PageMetadata(
            title: "Kitchen Sink",
            description: "Every Score system on one page."
        )
    }

    var body: some View {
        SiteNav()
        Main {
            // ViewBuilder limit is 10 — split into two groups.
            VStack {
                ThemeSection()
                StateSection()
                RoutingSection()
                AnimationSection()
                ModifiersSection()
            }
            VStack {
                TypographySection()
                LayoutSection()
                ComponentsSection()
                FormSection()
                ContentSection()
                DataSection()
                NativeSection()
                MediaSection()
            }
        }
        .frame(maxWidth: .px(1120))
        .margin(x: .auto)
        .padding(6)
        .padding(12, at: .desktop)
    }
}

// MARK: - Navigation

struct SiteNav: View {
    var body: some View {
        Nav(label: "Kitchen Sink navigation") {
            HStack {
                Link(to: "/") { "Kitchen Sink" }
                    .font(weight: .bold)
                Spacer()
                HStack {
                    Link(to: "#theme") { "Theme" }
                    Link(to: "#state") { "State" }
                    Link(to: "#animation") { "Animation" }
                    Link(to: "#modifiers") { "Modifiers" }
                }
                .flex(gap: 5)
                .display(.none)
                .display(.flex, at: .tablet)
            }
            .flex(align: .center)
            .padding(x: 6, y: 4)
            .frame(maxWidth: .px(1120))
            .margin(x: .auto)
        }
        .border(color: .muted.opacity(0.15), edge: .bottom)
        .background(color: .surface)
        .position(.sticky, top: 0)
        .position(zIndex: 10)
    }
}

// MARK: - Section shell

struct KSSection<Content: View>: View {
    let title: String
    let id: String
    let lead: String
    let content: Content

    init(title: String, id: String, lead: String = "", @ViewBuilder content: () -> Content) {
        self.title = title
        self.id = id
        self.lead = lead
        self.content = content()
    }

    var body: some View {
        Section {
            Heading(2) { title }
                .font(size: .twoXL, weight: .bold)
            if !lead.isEmpty {
                Text { lead }
                    .font(size: .sm, color: .muted)
                    .margin(top: 1)
            }
            content
                .margin(top: 5)
        }
        .padding(y: 8)
        .border(color: .muted.opacity(0.16), edge: .bottom)
    }
}

// MARK: - Card helper

struct KSCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack {
            Text { title }
                .font(size: .xs, weight: .semibold, color: .muted, tracking: .wide, transform: .uppercase)
            content
        }
        .flex(direction: .vertical, gap: 3)
        .padding(5)
        .background(color: .secondary)
        .border(color: .muted.opacity(0.15), radius: .lg)
    }
}

// MARK: - 1. Theme system

struct ThemeSection: View {
    var body: some View {
        KSSection(
            title: "Theme system",
            id: "theme",
            lead: "SiteTheme presets, palettes, dark mode, ComponentTheme variants, gradient backgrounds, and runtime ThemeSelector."
        ) {
            VStack {
                // Runtime controls: preset, palette, and dark/light mode
                HStack {
                    HStack {
                        Text { "Preset:" }.font(size: .sm, color: .muted)
                        ThemeSelector(
                            preset: [
                                .init("Modern (default)", themeKey: ""),
                                .init("Minimal",          themeKey: "minimal"),
                                .init("Soft",             themeKey: "soft"),
                                .init("Neo-Brutalism",    themeKey: "neoBrutalism"),
                            ],
                            id: "ks-preset-selector"
                        )
                    }
                    .flex(align: .center, gap: 2)

                    HStack {
                        Text { "Palette:" }.font(size: .sm, color: .muted)
                        ThemeSelector(
                            palette: [
                                // Score built-in palettes
                                .init("Ocean (default)",    themeKey: ""),
                                .init("Violet",             themeKey: "violet"),
                                .init("Indigo",             themeKey: "indigo"),
                                .init("Forest",             themeKey: "forest"),
                                .init("Sunset",             themeKey: "sunset"),
                                .init("Midnight",           themeKey: "midnight"),
                                .init("Berry",              themeKey: "berry"),
                                .init("Ember",              themeKey: "ember"),
                                .init("Rose",               themeKey: "rose"),
                                // Open-source developer palettes
                                .init("Rosé Pine",          themeKey: "rose-pine"),
                                .init("Rosé Pine Dawn",     themeKey: "rose-pine-dawn"),
                                .init("Tokyo Night",        themeKey: "tokyo-night"),
                                .init("Tokyo Night Storm",  themeKey: "tokyo-night-storm"),
                                .init("Vesper",             themeKey: "vesper"),
                                .init("One Dark",           themeKey: "one-dark"),
                                .init("Gruvbox Dark",       themeKey: "gruvbox-dark"),
                                .init("Gruvbox Light",      themeKey: "gruvbox-light"),
                            ],
                            id: "ks-palette-selector"
                        )
                    }
                    .flex(align: .center, gap: 2)

                    HStack {
                        Text { "Mode:" }.font(size: .sm, color: .muted)
                        ThemeSelector(
                            themes: [
                                .init("System", themeKey: ""),
                                .init("Light",  themeKey: "light"),
                                .init("Dark",   themeKey: "dark"),
                            ],
                            id: "ks-mode-selector"
                        )
                    }
                    .flex(align: .center, gap: 2)
                }
                .flex(wrap: .wrap, align: .center, gap: 5)

                // Dark mode — .on(.dark) modifier
                HStack {
                    VStack {
                        Text { "Light surface" }.font(size: .sm, weight: .medium)
                        Text { "Default background" }.font(size: .xs, color: .muted)
                    }
                    .padding(4)
                    .background(color: .surface)
                    .border(color: .muted.opacity(0.2), radius: .md)
                    .flex(direction: .vertical, gap: 1)

                    VStack {
                        Text { ".on(.dark)" }.font(size: .sm, weight: .medium)
                        Text { "Swaps on prefers-color-scheme: dark" }.font(size: .xs, color: .muted)
                    }
                    .padding(4)
                    .background(color: .surface)
                    .on(.dark) { $0.background(color: .secondary) }
                    .border(color: .muted.opacity(0.2), radius: .md)
                    .flex(direction: .vertical, gap: 1)

                    VStack {
                        Text { "Tertiary" }.font(size: .sm, weight: .medium)
                        Text { ".tertiary token" }.font(size: .xs, color: .muted)
                    }
                    .padding(4)
                    .background(color: .tertiary)
                    .border(color: .muted.opacity(0.2), radius: .md)
                    .flex(direction: .vertical, gap: 1)
                }
                .flex(wrap: .wrap, gap: 4)

                // ComponentTheme: Button preset variants
                HStack {
                    Button(.primary) { "Primary" }
                    Button(.secondary) { "Secondary" }
                    Button(.outline) { "Outline" }
                    Button(.ghost) { "Ghost" }
                    Button(.destructive) { "Destructive" }
                }
                .flex(wrap: .wrap, gap: 3)

                // Gradient backgrounds
                HStack {
                    VStack {}
                        .frame(width: .fr(1), height: .px(56))
                        .background(gradient: .linear(from: .primary, to: .accent))
                        .border(radius: .md)
                    VStack {}
                        .frame(width: .fr(1), height: .px(56))
                        .background(gradient: .linear(from: .secondary, to: .tertiary, angle: 135))
                        .border(radius: .md)
                    VStack {}
                        .frame(width: .fr(1), height: .px(56))
                        .background(gradient: .radial(from: .accent, to: .surface))
                        .border(radius: .md)
                }
                .flex(gap: 3)
            }
            .flex(direction: .vertical, gap: 5)
        }
    }
}

// MARK: - 2. State & reactivity

struct StateSection: View {
    @State var count: Int = 0
    @State var isOpen: Bool = false

    var body: some View {
        KSSection(
            title: "State & reactivity",
            id: "state",
            lead: "@State, @Binding, @Connectivity, and @Action — Score renders the initial snapshot; the JS runtime handles mutations."
        ) {
            VStack {
                Grid(columns: 2) {
                    // Live counter: initial render shows 0; JS runtime handles mutations.
                    KSCard(title: "@State<Int> — counter") {
                        HStack {
                            Button(.outline) { "−" }
                                .on(.active) { $0.scale(0.95) }
                                .animate(.transform, duration: 100.ms)
                            Text { "\(count)" }
                                .font(size: .twoXL, weight: .bold)
                                .padding(x: 5)
                            Button(.outline) { "+" }
                                .on(.active) { $0.scale(0.95) }
                                .animate(.transform, duration: 100.ms)
                        }
                        .flex(align: .center, justify: .center, gap: 2)
                    }

                    // Live toggle: initial collapsed state; JS runtime handles expand.
                    KSCard(title: "@State<Bool> — toggle") {
                        VStack {
                            Button(isOpen ? .primary : .outline) {
                                isOpen ? "Collapse ▲" : "Expand ▼"
                            }
                            if isOpen {
                                Text { "Revealed content — visible when isOpen is true." }
                                    .font(size: .sm, color: .muted)
                                    .padding(3)
                                    .background(color: .surface)
                                    .border(radius: .md)
                                    .animate(.fadeIn, duration: 200.ms)
                            }
                        }
                        .flex(direction: .vertical, gap: 3)
                    }

                    // @Binding: live form input — parent owns @State, child receives $binding.
                    KSCard(title: "@Binding — parent → child") {
                        VStack {
                            Text { "SearchInput(query: $searchQuery)" }
                                .font(size: .xs, color: .muted, family: .systemMono)
                            Input(type: .text, name: "q", placeholder: "Type to search…")
                            Text { "Child receives a Binding<String> — writes back to the parent's @State." }
                                .font(size: .xs, color: .muted)
                        }
                        .flex(direction: .vertical, gap: 2)
                    }

                    // @Connectivity: shows all three states at render time.
                    KSCard(title: "@Connectivity — network state") {
                        VStack {
                            ConnectivityBadge(state: .online)
                            ConnectivityBadge(state: .reconnecting)
                            ConnectivityBadge(state: .offline)
                        }
                        .flex(direction: .vertical, gap: 2)
                    }
                }
                .flex(gap: 4)
            }
        }
    }
}

struct ConnectivityBadge: View {
    let state: ConnectivityState

    var body: some View {
        HStack {
            VStack {}
                .frame(width: .px(8), height: .px(8))
                .background(color: dotColor)
                .border(radius: .full)
            Text { label }
                .font(size: .sm)
        }
        .flex(align: .center, gap: 2)
        .padding(2, 4)
        .background(color: dotColor.opacity(0.12))
        .border(radius: .md)
    }

    private var dotColor: Color {
        switch state {
        case .online:       return .primary
        case .offline:      return .destructive
        case .reconnecting: return .muted
        }
    }

    private var label: String {
        switch state {
        case .online:       return "Online"
        case .offline:      return "Offline — changes sync when reconnected"
        case .reconnecting: return "Reconnecting…"
        }
    }
}

// MARK: - 3. Routing

struct RoutingSection: View {
    var body: some View {
        KSSection(
            title: "Routing",
            id: "routing",
            lead: "Page(), RouteCollection, and StaticPage — live routes registered in this app."
        ) {
            VStack {
                // Live route links — these are real registered routes in this app.
                KSCard(title: "Live pages — Page(\"/\") + StaticPage") {
                    VStack {
                        RouteRow(
                            path: "/",
                            kind: "Page — static",
                            desc: "This page. Pre-rendered at build time."
                        )
                        RouteRow(
                            path: "/about",
                            kind: "Page — static",
                            desc: "About this kitchen-sink app."
                        )
                        RouteRow(
                            path: "/blog",
                            kind: "Page — static",
                            desc: "Blog index: lists all StaticPage instances."
                        )
                        ForEach(samplePosts) { post in
                            RouteRow(
                                path: "/blog/\(post.slug)",
                                kind: "StaticPage",
                                desc: post.title
                            )
                        }
                    }
                    .flex(direction: .vertical, gap: 2)
                }

                // API routes + WebSocket remain as code — they have no renderable URL.
                Grid(columns: 2) {
                    KSCard(title: "API routes + RouteGroup") {
                        CodeBlock(language: .swift, """
                        RouteGroup(api: "/posts") {
                            GET("/") { req in
                                let posts = try await db.query(Post.self).all()
                                return try Response.json(posts)
                            }
                            POST("/") { req in
                                let body = try req.decode(CreatePost.self)
                                return try Response.created(body.toPost())
                            }
                            DELETE("/:id") { req in
                                try await db.delete(Post.self, id: req.pathParameter("id"))
                                return Response.noContent()
                            }
                        }
                        """)
                    }
                    KSCard(title: "WebSocket") {
                        CodeBlock(language: .swift, """
                        WS("/chat") { ws, req in
                            try await ws.send("hello")
                            for try await msg in ws.messages {
                                try await ws.send("echo: \\(msg)")
                            }
                        }
                        """)
                    }
                }
                .flex(gap: 4)
            }
            .flex(direction: .vertical, gap: 4)
        }
    }
}

struct RouteRow: View {
    let path: String
    let kind: String
    let desc: String

    var body: some View {
        HStack {
            Link(to: path) {
                Code(path)
            }
            .font(size: .sm)
            Badge { kind }
            Text { desc }
                .font(size: .sm, color: .muted)
        }
        .flex(wrap: .wrap, align: .center, gap: 3)
        .padding(2, 0)
    }
}

// MARK: - 4. Animation

struct AnimationSection: View {
    var body: some View {
        KSSection(
            title: "Animation",
            id: "animation",
            lead: ".animate() (CSS animation), .animate() (CSS transition), .animateOnScroll(), .animateChildren(), .viewTransition(), and KeyframeAnimation."
        ) {
            VStack {
                // Built-in Animation enum values
                Grid(columns: 4) {
                    AnimBox(label: ".fadeIn").animate(.fadeIn, duration: 600.ms)
                    AnimBox(label: ".pulse").animate(.pulse, duration: 1200.ms)
                    AnimBox(label: ".bounce").animate(.bounce, duration: 800.ms)
                    AnimBox(label: ".slideInLeft").animate(.slideInLeft, duration: 500.ms)
                }
                .flex(gap: 3)

                // CSS transitions (.animate with TransitionProperty)
                HStack {
                    Text { ".animate(.all) on hover" }
                        .padding(3, 5)
                        .background(color: .secondary)
                        .border(radius: .md)
                        .on(.hover) { $0.shadow(.md).translate(y: .px(-2)).scale(1.02) }
                        .animate(.all, duration: 200.ms)
                    Text { ".animate(.opacity)" }
                        .padding(3, 5)
                        .background(color: .secondary)
                        .border(radius: .md)
                        .on(.hover) { $0.effect(opacity: 0.5) }
                        .animate(.opacity, duration: 200.ms)
                    Text { ".animate(.transform)" }
                        .padding(3, 5)
                        .background(color: .secondary)
                        .border(radius: .md)
                        .on(.hover) { $0.rotate(6) }
                        .animate(.transform, duration: 200.ms)
                }
                .flex(wrap: .wrap, gap: 4)

                // Scroll-triggered — .animateOnScroll takes Animation + threshold
                HStack {
                    AnimBox(label: "animateOnScroll(.fadeIn)")
                        .animateOnScroll(.fadeIn, threshold: 0.1)
                        .frame(maxWidth: .fr(1))
                    AnimBox(label: "animateOnScroll(.slideInUp)")
                        .animateOnScroll(.slideInUp, threshold: 0.15)
                        .frame(maxWidth: .fr(1))
                }
                .flex(gap: 3)

                // Stagger children
                HStack {
                    ForEach(["Child 1", "Child 2", "Child 3", "Child 4"]) { label in
                        AnimBox(label: label)
                    }
                }
                .flex(gap: 3)
                .animateChildren(.fadeIn, duration: 400.ms, stagger: 80.ms)

                // .viewTransition
                AnimBox(label: ".viewTransition(\"hero\")")
                    .viewTransition("hero")
                    .frame(maxWidth: .fr(1))
            }
            .flex(direction: .vertical, gap: 4)
        }
    }
}

struct AnimBox: View {
    let label: String
    var body: some View {
        Text { label }
            .font(size: .xs, weight: .medium, align: .center)
            .padding(4)
            .frame(maxWidth: .fr(1))
            .background(color: .secondary)
            .border(color: .muted.opacity(0.2), radius: .md)
    }
}

// MARK: - 5. Modifiers

struct ModifiersSection: View {
    var body: some View {
        KSSection(
            title: "Modifiers",
            id: "modifiers",
            lead: "Responsive breakpoints, pseudo-states, transforms, effects, shadows, overflow, display, and visibility."
        ) {
            VStack {
                // Responsive breakpoints
                KSCard(title: "Responsive — .at(.tablet), .at(.desktop)") {
                    HStack {
                        Text { "Base" }
                            .padding(3)
                            .background(color: .secondary)
                            .border(radius: .md)
                        Text { "+ tablet padding" }
                            .padding(3)
                            .background(color: .secondary)
                            .border(radius: .md)
                            .padding(4, at: .tablet)
                        Text { "Bold at desktop" }
                            .padding(3)
                            .background(color: .secondary)
                            .border(radius: .md)
                            .font(weight: .bold, at: .desktop)
                        Text { "Hidden on mobile" }
                            .padding(3)
                            .background(color: .accent.opacity(0.15))
                            .border(radius: .md)
                            .display(.none)
                            .display(.block, at: .tablet)
                    }
                    .flex(wrap: .wrap, gap: 3)
                }

                // Pseudo-states
                KSCard(title: "Pseudo-states — .on(.hover), .on(.focus), .on(.active), .on(.dark)") {
                    HStack {
                        Text { "Hover" }
                            .padding(3, 5)
                            .background(color: .surface)
                            .border(color: .muted.opacity(0.2), radius: .md)
                            .on(.hover) { $0.background(color: .secondary).shadow(.sm) }
                            .animate(.all, duration: 150.ms)

                        Text { "Focus ring" }
                            .padding(3, 5)
                            .background(color: .surface)
                            .border(color: .muted.opacity(0.2), radius: .md)
                            .on(.focus) { $0.shadow(ring: 2, color: .primary) }

                        Text { "Active scale" }
                            .padding(3, 5)
                            .background(color: .secondary)
                            .border(radius: .md)
                            .on(.active) { $0.scale(0.96) }
                            .animate(.transform, duration: 100.ms)

                        Text { "Dark swap" }
                            .padding(3, 5)
                            .background(color: .surface)
                            .border(color: .muted.opacity(0.2), radius: .md)
                            .on(.dark) { $0.background(color: .secondary).font(color: .primary) }
                    }
                    .flex(wrap: .wrap, gap: 3)
                }

                // Combined state + breakpoint
                KSCard(title: ".on(.combined(state: .hover, breakpoint: .desktop))") {
                    Text { "Desktop-only hover highlight" }
                        .padding(3, 5)
                        .background(color: .surface)
                        .border(color: .muted.opacity(0.2), radius: .md)
                        .on(.combined(state: .hover, breakpoint: .desktop)) {
                            $0.background(color: .primary).font(color: .surface)
                        }
                        .animate(.all, duration: 150.ms)
                }

                // Transforms
                KSCard(title: "Transforms — translate, scale, rotate, skew, transformOrigin") {
                    HStack {
                        TransformBox(label: "translate y -8px").translate(y: .px(-8))
                        TransformBox(label: "scale 1.15").scale(1.15)
                        TransformBox(label: "rotate 8°").rotate(8)
                        TransformBox(label: "skew x 8°").skew(x: 8)
                        TransformBox(label: "origin: topLeft").scale(1.1).transformOrigin(.topLeft)
                    }
                    .flex(wrap: .wrap, align: .center, gap: 4)
                }

                // Effects
                KSCard(title: "Effects — opacity, blur, grayscale, brightness, saturate") {
                    HStack {
                        EffectBox(label: "opacity 50%").effect(opacity: 0.5)
                        EffectBox(label: "blur 3px").effect(blur: .px(3))
                        EffectBox(label: "grayscale").effect(grayscale: true)
                        EffectBox(label: "brightness 1.4").effect(brightness: 1.4)
                        EffectBox(label: "saturate 2.0").effect(saturate: 2.0)
                    }
                    .flex(wrap: .wrap, gap: 3)
                }

                // Shadows
                KSCard(title: "Shadows — .shadow(), .shadow(ring:)") {
                    HStack {
                        ShadowBox(label: ".sm").shadow(.sm)
                        ShadowBox(label: ".md").shadow(.md)
                        ShadowBox(label: ".lg").shadow(.lg)
                        ShadowBox(label: ".xl").shadow(.xl)
                        ShadowBox(label: "ring 2").shadow(ring: 2, color: .primary)
                    }
                    .flex(wrap: .wrap, align: .center, gap: 5)
                }

                // Overflow / display / visibility
                KSCard(title: "Overflow, display, visibility") {
                    HStack {
                        VStack {
                            Text { "overflow: hidden" }.font(size: .xs, color: .muted)
                            Text { "This deliberately long text is clipped by overflow hidden." }
                                .font(size: .sm)
                                .frame(width: .px(140), height: .px(40))
                                .overflow(.hidden)
                                .border(color: .muted.opacity(0.2), radius: .sm)
                        }
                        .flex(direction: .vertical, gap: 2)

                        VStack {
                            Text { "overflow: scroll" }.font(size: .xs, color: .muted)
                            Text { "Scrollable. This deliberately long text will scroll horizontally." }
                                .font(size: .sm)
                                .frame(width: .px(140), height: .px(40))
                                .overflow(.scroll)
                                .border(color: .muted.opacity(0.2), radius: .sm)
                        }
                        .flex(direction: .vertical, gap: 2)

                        VStack {
                            Text { "display(.none)" }.font(size: .xs, color: .muted)
                            Text { "Hidden (no space)" }.font(size: .sm).display(.none)
                            Text { "(nothing above)" }.font(size: .sm, color: .muted)
                        }
                        .flex(direction: .vertical, gap: 2)

                        VStack {
                            Text { "visibility(true)" }.font(size: .xs, color: .muted)
                            Text { "Space reserved" }.font(size: .sm).visibility(true)
                            Text { "(space above)" }.font(size: .sm, color: .muted)
                        }
                        .flex(direction: .vertical, gap: 2)
                    }
                    .flex(wrap: .wrap, align: .start, gap: 5)
                }
            }
            .flex(direction: .vertical, gap: 4)
        }
    }
}

struct TransformBox: View {
    let label: String
    var body: some View {
        Text { label }.font(size: .xs, weight: .medium)
            .padding(3, 4).background(color: .secondary).border(radius: .md)
    }
}

struct EffectBox: View {
    let label: String
    var body: some View {
        Text { label }.font(size: .xs, weight: .medium)
            .padding(3, 4).background(color: .primary.opacity(0.15)).border(radius: .md)
    }
}

struct ShadowBox: View {
    let label: String
    var body: some View {
        Text { label }.font(size: .xs, weight: .medium)
            .padding(3, 4).background(color: .surface).border(color: .muted.opacity(0.1), radius: .md)
    }
}

// MARK: - 6. Typography

struct TypographySection: View {
    var body: some View {
        KSSection(
            title: "Typography",
            id: "typography",
            lead: "Heading (1–6), Text, Code, Highlight, Blockquote, and all font() modifier axes."
        ) {
            VStack {
                // Headings
                VStack {
                    ForEach([1, 2, 3, 4, 5, 6]) { level in Heading(level) { "Heading \(level)" } }
                }
                .flex(direction: .vertical, gap: 2)

                // Font modifier axes
                Grid(columns: 3) {
                    VStack {
                        Text { "Weights" }.font(size: .xs, weight: .semibold, color: .muted)
                        VStack {
                            Text { "Thin" }.font(weight: .thin)
                            Text { "Light" }.font(weight: .light)
                            Text { "Regular" }.font(weight: .regular)
                            Text { "Medium" }.font(weight: .medium)
                            Text { "Semibold" }.font(weight: .semibold)
                            Text { "Bold" }.font(weight: .bold)
                            Text { "Black" }.font(weight: .black)
                        }
                        .flex(direction: .vertical, gap: 1)
                    }
                    VStack {
                        Text { "Styles" }.font(size: .xs, weight: .semibold, color: .muted)
                        VStack {
                            Text { "Italic" }.font(style: .italic)
                            Text { "Underline" }.font(decoration: .underline)
                            Text { "Line-through" }.font(decoration: .lineThrough)
                            Text { "Uppercase" }.font(transform: .uppercase)
                            Text { "Mono" }.font(family: .systemMono)
                            Text { "Truncated long text here" }.font(truncate: true).frame(width: .px(130))
                        }
                        .flex(direction: .vertical, gap: 1)
                    }
                    VStack {
                        Text { "Leading / tracking" }.font(size: .xs, weight: .semibold, color: .muted)
                        VStack {
                            Text { "leading: .tight" }.font(leading: .tight)
                            Text { "leading: .normal" }.font(leading: .normal)
                            Text { "leading: .relaxed" }.font(leading: .relaxed)
                            Text { "leading: .loose" }.font(leading: .loose)
                            Text { "tracking: .tight" }.font(tracking: .tight)
                            Text { "tracking: .wide" }.font(tracking: .wide)
                            Text { "tracking: .widest" }.font(tracking: .widest)
                        }
                        .flex(direction: .vertical, gap: 1)
                    }
                }
                .flex(gap: 6)

                // Inline elements
                HStack {
                    Code { "let score = 100" }
                    Highlight { "highlighted" }
                    Abbreviation("HTML", title: "HyperText Markup Language")
                    Superscript { "super" }
                    Subscript { "sub" }
                    TimeElement(Date(timeIntervalSince1970: 1750032000))
                    NumberElement(3.14159, format: .decimal(places: 2))
                }
                .flex(wrap: .wrap, gap: 3)

                Blockquote {
                    Text { "Score renders views to HTML at build time or request time — nothing Swift runs in the browser." }
                }
            }
            .flex(direction: .vertical, gap: 5)
        }
    }
}

// MARK: - 7. Layout

struct LayoutSection: View {
    var body: some View {
        KSSection(
            title: "Layout",
            id: "layout",
            lead: "VStack, HStack, Grid, ZStack, ScrollView, Spacer, Divider — and all flex/grid/frame modifiers."
        ) {
            VStack {
                // ZStack
                KSCard(title: "ZStack — layered content") {
                    ZStack {
                        VStack {}
                            .frame(width: .px(200), height: .px(80))
                            .background(gradient: .linear(from: .primary, to: .accent))
                            .border(radius: .lg)
                        Text { "On top" }
                            .font(size: .sm, weight: .semibold)
                            .padding(2, 4)
                            .background(color: .surface)
                            .border(radius: .md)
                    }
                }

                // ScrollView
                KSCard(title: "ScrollView(axis: .x) — horizontal scroll") {
                    ScrollView(axis: .x) {
                        HStack {
                            ForEach([1, 2, 3, 4, 5, 6, 7, 8]) { i in
                                VStack {}
                                    .frame(width: .px(80), height: .px(60))
                                    .background(color: .primary.opacity(Double(i) / 8.0))
                                    .border(radius: .md)
                            }
                        }
                        .flex(gap: 3)
                    }
                }

                // Grid + responsive columns
                KSCard(title: "Grid — responsive columns (.grid(columns: 4, at: .desktop))") {
                    Grid(columns: 2) {
                        FeatureTile(title: "2 cols base", detail: "Grid(columns: 2)")
                        FeatureTile(title: "4 cols desktop", detail: ".grid(columns: 4, at: .desktop)")
                        FeatureTile(title: "Equal widths", detail: "minmax(0, 1fr)")
                        FeatureTile(title: "Gap control", detail: ".flex(gap:) on grid")
                    }
                    .flex(gap: 3)
                    .grid(columns: 4, at: .desktop)
                }

                // Spacer / Divider
                KSCard(title: "Spacer and Divider") {
                    VStack {
                        HStack {
                            Text { "Left" }.font(size: .sm)
                            Spacer()
                            Text { "Right" }.font(size: .sm)
                        }
                        .flex(align: .center)
                        Divider()
                        HStack {
                            Text { "A" }.font(size: .sm)
                            Divider()
                            Text { "B" }.font(size: .sm)
                            Divider()
                            Text { "C" }.font(size: .sm)
                        }
                        .flex(align: .center, gap: 4)
                        .frame(height: .px(24))
                    }
                    .flex(direction: .vertical, gap: 3)
                }
            }
            .flex(direction: .vertical, gap: 4)
        }
    }
}

struct FeatureTile: View {
    let title: String
    let detail: String
    var body: some View {
        Article {
            Heading(3) { title }.font(size: .sm, weight: .semibold)
            Text { detail }.font(size: .xs, color: .muted).margin(top: 1)
        }
        .padding(4)
        .background(color: .surface)
        .border(color: .muted.opacity(0.18), radius: .md)
        .on(.hover) { $0.shadow(.sm).translate(y: .px(-1)) }
        .animate(.all, duration: 150.ms)
    }
}

// MARK: - 8. Components

struct ComponentsSection: View {
    var body: some View {
        KSSection(
            title: "Components",
            id: "components",
            lead: "Button, Badge, Link, NavLink, Dialog, Popover — Score's ComponentTheme-styled elements."
        ) {
            VStack {
                HStack {
                    Button(.primary) { "Primary" }
                    Button(.secondary) { "Secondary" }
                    Button(.outline) { "Outline" }
                    Button(.ghost) { "Ghost" }
                    Button(.destructive) { "Destructive" }
                }
                .flex(wrap: .wrap, gap: 3)

                HStack {
                    Badge { "Default" }
                    Badge { "Badge" }
                }
                .flex(wrap: .wrap, gap: 3)

                HStack {
                    Link(to: "/") { "Internal link" }
                    Link(to: "https://swift.org") { "External link" }
                    NavLink(to: "/") { "NavLink (active)" }
                    NavLink(to: "/other") { "NavLink (inactive)" }
                }
                .flex(wrap: .wrap, align: .center, gap: 5)

                KSCard(title: "Dialog — native <dialog>") {
                    HStack {
                        Dialog {
                            Heading(3) { "Native dialog" }.font(size: .lg, weight: .semibold)
                            Text { "Score renders this as a native <dialog> element." }
                                .font(size: .sm).margin(top: 2)
                        }
                        Text { "→ <dialog data-score-dialog>" }.font(size: .xs, color: .muted)
                    }
                    .flex(align: .center, gap: 4)
                }

                KSCard(title: "Popover — native Popover API") {
                    HStack {
                        Button(.outline) { "Toggle popover" }
                        Popover {
                            Text { "Native popover — no JS required." }
                                .font(size: .sm).padding(3)
                        }
                    }
                    .flex(align: .center, gap: 3)
                }
            }
            .flex(direction: .vertical, gap: 5)
        }
    }
}

// MARK: - 9. Forms

struct FormSection: View {
    var body: some View {
        KSSection(
            title: "Forms",
            id: "forms",
            lead: "Form, Input (all types), Label, Fieldset, Legend, OptionGroup — every form primitive Score supports."
        ) {
            Form(action: "/api/contact", method: .post) {
                // Split into two Grid blocks to stay under the ViewBuilder 10-child limit.
                Grid(columns: 2) {
                    Input(type: .text, name: "name", placeholder: "Ada Lovelace", required: true)
                    Input(type: .email, name: "email", placeholder: "ada@example.com", required: true)
                    Input(type: .select, name: "topic") {
                        Option(value: "theme") { "Theme system" }
                        Option(value: "routing") { "Routing" }
                        OptionGroup(label: "Advanced") {
                            Option(value: "state") { "State" }
                            Option(value: "data") { "Data layer" }
                        }
                    }
                    Input(type: .date, name: "date")
                    Input(type: .url, name: "website", placeholder: "https://")
                    Input(type: .number, name: "count", placeholder: "42")
                }
                .flex(gap: 4)
                Grid(columns: 2) {
                    Input(type: .password, name: "token", placeholder: "API token")
                    Input(type: .textarea, name: "message", placeholder: "Message…", rows: 3)
                    Input(type: .range, name: "priority", min: 0, max: 10)
                    Input(type: .color, name: "accent")
                    Input(type: .file, name: "attachment")
                    Input(type: .tel, name: "phone", placeholder: "+1 555 000 0000")
                }
                .flex(gap: 4)

                Fieldset {
                    Legend { "Preferences" }
                    VStack {
                        Input(type: .checkbox, name: "newsletter", label: "Subscribe to newsletter")
                        Input(type: .radio, name: "plan", value: "free", label: "Free")
                        Input(type: .radio, name: "plan", value: "pro", label: "Pro")
                    }
                    .flex(direction: .vertical, gap: 2)
                }
                .margin(top: 2)

                HStack {
                    Button(.primary, type: .submit) { "Submit" }
                    Button(.secondary, type: .reset) { "Reset" }
                    Button(.ghost, type: .button) { "Cancel" }
                }
                .flex(wrap: .wrap, gap: 3)
                .margin(top: 4)
            }
        }
    }
}

// MARK: - 10. Content & ContentTheme

struct ContentSection: View {
    var body: some View {
        KSSection(
            title: "Content & ContentTheme",
            id: "content",
            lead: "RichText(markdown:), CodeBlock, and ContentTheme — Score's structured, typed content styling layer."
        ) {
            VStack {
                Grid(columns: 2) {
                    KSCard(title: "RichText — default ContentTheme") {
                        RichText(
                            markdown: """
                            ## Markdown
                            Score renders **bold**, *emphasis*, `code`, safe [links](/), and lists.
                            - First item
                            - Second item
                            > Blockquotes work too.
                            """)
                    }

                    KSCard(title: "RichText — ContentTheme.blog") {
                        RichText(
                            markdown: """
                            ## Article heading
                            Long-form prose with *relaxed* leading and **generous** spacing.
                            - Left-bordered blockquotes
                            - Larger body text
                            > Styled via typed closures — not CSS class strings.
                            """,
                            theme: .blog
                        )
                    }
                }
                .flex(gap: 4)

                CodeBlock(
                    language: .swift,
                    """
                    // ContentTheme is a set of typed closures — not a CSS class.
                    // Safe: no raw HTML, no string injection.
                    // Every node type (heading, paragraph, code, link, image…)
                    // routes through the closure which returns a modifier chain.
                    struct BlogPostPage: Page {
                        var contentTheme: ContentTheme { .blog }
                        var body: some View {
                            RichText(markdown: post.content)
                        }
                    }
                    """)
            }
            .flex(direction: .vertical, gap: 4)
        }
    }
}

// MARK: - Sample post data (stands in for db.query(Post.self).all())

struct SamplePost: Sendable {
    let title: String
    let slug: String
    let tags: String
    let date: String
}

let samplePosts: [SamplePost] = [
    SamplePost(title: "Getting Started with Score",          slug: "getting-started",        tags: "score, swift",      date: "2026-01-12"),
    SamplePost(title: "Building a Blog with ContentStore",   slug: "blog-with-content-store", tags: "score, markdown",   date: "2026-02-28"),
    SamplePost(title: "Reactive State and the JS Runtime",   slug: "reactive-state",          tags: "state, javascript", date: "2026-03-15"),
]

// MARK: - 11. Data layer

struct DataSection: View {
    var body: some View {
        KSSection(
            title: "Data layer",
            id: "data",
            lead: "Record ORM (db.query, filter, orderBy), ContentStore for Markdown files, and DescriptionList / Table for structured display."
        ) {
            VStack {
                // Live post list — what Record + db.query output looks like when rendered.
                KSCard(title: "Record — rendered post list") {
                    VStack {
                        ForEach(samplePosts) { post in
                            HStack {
                                VStack {
                                    Text { post.title }
                                        .font(size: .sm, weight: .semibold)
                                    Text { post.tags }
                                        .font(size: .xs, color: .muted)
                                }
                                .flex(direction: .vertical, gap: 1)
                                Spacer()
                                Text { post.date }
                                    .font(size: .xs, color: .muted, family: .systemMono)
                            }
                            .flex(align: .center)
                            .padding(3, 0)
                            .border(color: .muted.opacity(0.1), edge: .bottom)
                        }
                    }
                    .flex(direction: .vertical)
                }

                // Live ContentStore entries — frontmatter fields as a description list.
                KSCard(title: "ContentStore — rendered frontmatter") {
                    DescriptionList {
                        Term { "title" }
                        Description { "Getting Started with Score" }
                        Term { "slug" }
                        Description { "getting-started" }
                        Term { "published" }
                        Description { "true" }
                        Term { "tags" }
                        Description { "score, swift" }
                        Term { "content" }
                        Description { "<rendered HTML from Markdown body>" }
                    }
                }

                Table(caption: "Score module map") {
                    TableHeader {
                        TableRow {
                            TableCell(.header) { "Module" }
                            TableCell(.header) { "Responsibility" }
                        }
                    }
                    TableBody {
                        TableRow {
                            TableCell { Code { "ScoreCore" } }
                            TableCell { "Elements, modifiers, theme, CSS emission" }
                        }
                        TableRow {
                            TableCell { Code { "ScoreRouter" } }
                            TableCell { "Page/API routes, RouteCollection, RenderMode" }
                        }
                        TableRow {
                            TableCell { Code { "ScoreData" } }
                            TableCell { "ORM, Record, SQLite adapter" }
                        }
                        TableRow {
                            TableCell { Code { "ScoreSSG" } }
                            TableCell { "StaticPage, PageRenderer, DependencyGraph" }
                        }
                        TableRow {
                            TableCell { Code { "ScoreBuild" } }
                            TableCell { "CSS bundles, fingerprinting, minification" }
                        }
                    }
                }
            }
            .flex(direction: .vertical, gap: 5)
        }
    }
}

// MARK: - 12. Native elements

struct NativeSection: View {
    var body: some View {
        KSSection(
            title: "Native elements",
            id: "native",
            lead: "Score maps to the full HTML element set — no polyfills, no JS shims where the platform provides it natively."
        ) {
            Grid(columns: 2) {
                KSCard(title: "Details + Summary") {
                    VStack {
                        Details(isOpen: true, group: "ks-native") {
                            Summary { "Open by default" }
                            Text { "Native <details> disclosure — no JS." }.font(size: .sm)
                        }
                        Details(group: "ks-native") {
                            Summary { "Closed (exclusive group)" }
                            Text { "Only one in a name group opens at a time." }.font(size: .sm)
                        }
                    }
                    .flex(direction: .vertical, gap: 2)
                }

                KSCard(title: "Progress + Meter") {
                    VStack {
                        HStack {
                            Text { "72%" }.font(size: .xs, color: .muted)
                            Progress(value: 72, total: 100)
                        }
                        .flex(align: .center, gap: 3)
                        HStack {
                            Text { "78%" }.font(size: .xs, color: .muted)
                            Meter(value: 0.78, low: 0.3, high: 0.8, optimum: 0.9)
                        }
                        .flex(align: .center, gap: 3)
                    }
                    .flex(direction: .vertical, gap: 3)
                }

                KSCard(title: "Output") {
                    Output(for: "result") { "42" }
                }

                KSCard(title: "Semantic HTML landmarks") {
                    VStack {
                        ForEach(["<header>", "<nav>", "<main>", "<aside>", "<article>", "<section>", "<footer>"]) { tag in
                            Text { tag }.font(size: .sm, color: .muted, family: .systemMono)
                        }
                    }
                    .flex(direction: .vertical, gap: 1)
                }
            }
            .flex(gap: 4)
        }
    }
}

// MARK: - 13. Media

struct MediaSection: View {
    var body: some View {
        KSSection(
            title: "Media",
            id: "media",
            lead: "Image (lazy/eager, optional caption), Audio, and Video — typed wrappers with safe attribute emission."
        ) {
            Grid(columns: 3) {
                VStack {
                    Text { "Image — lazy + caption" }.font(size: .xs, color: .muted)
                    Image(
                        "/score-mark.svg",
                        alt: "Score mark",
                        caption: "Caption via <figcaption>",
                        width: 640, height: 360,
                        loading: .lazy
                    )
                    .border(radius: .md)
                }
                .flex(direction: .vertical, gap: 2)

                VStack {
                    Text { "Image — eager" }.font(size: .xs, color: .muted)
                    Image("/score-mark.svg", alt: "Score mark", width: 640, height: 360, loading: .eager)
                        .border(radius: .md)
                }
                .flex(direction: .vertical, gap: 2)

                VStack {
                    Text { "Audio + Video" }.font(size: .xs, color: .muted)
                    Audio(src: "/example-audio.mp3")
                    Video(src: "/example-video.mp4", poster: "/score-mark.svg")
                        .margin(top: 2)
                }
                .flex(direction: .vertical, gap: 2)
            }
            .flex(gap: 5)
        }
    }
}

// MARK: - About page (demonstrates Page("/about"))

struct AboutPage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "About", description: "About the Kitchen Sink example app.")
    }

    var body: some View {
        SiteNav()
        Main {
            VStack {
                Link(to: "/") { "← Kitchen Sink" }.font(size: .sm, color: .muted)
                Heading(1) { "About" }.font(size: .threeXL, weight: .bold)
                Text {
                    "The Kitchen Sink is a single-app showcase of every Score API — elements, modifiers, theme, state, animation, routing, and data — rendered live so you can see what each feature actually produces."
                }
                .font(leading: .relaxed)

                Divider().margin(y: 4)

                DescriptionList {
                    Term { "Framework" }
                    Description { "Score — Swift-native HTML rendering" }
                    Term { "Preset" }
                    Description { ".modern, palette: .ocean" }
                    Term { "Routes" }
                    Description { "/, /about, /blog, /blog/:slug" }
                    Term { "Source" }
                    Description { "Templates/kitchen-sink/Sources/Application.swift" }
                }
            }
            .flex(direction: .vertical, gap: 4)
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(6)
            .padding(12, at: .desktop)
        }
    }
}

// MARK: - Blog index page (demonstrates Page("/blog") + StaticPage list)

struct BlogIndexPage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "Blog", description: "Kitchen Sink blog — StaticPage demo.")
    }

    var body: some View {
        SiteNav()
        Main {
            VStack {
                Link(to: "/") { "← Kitchen Sink" }.font(size: .sm, color: .muted)
                Heading(1) { "Blog" }.font(size: .threeXL, weight: .bold)
                Text { "Three posts generated via StaticPage — one route per SamplePost instance." }
                    .font(size: .sm, color: .muted)

                VStack {
                    ForEach(samplePosts) { post in
                        Article {
                            HStack {
                                VStack {
                                    Heading(2) { post.title }
                                        .font(size: .lg, weight: .semibold)
                                    Text { post.tags }
                                        .font(size: .xs, color: .muted)
                                        .margin(top: 1)
                                }
                                .flex(direction: .vertical, gap: 0)
                                Spacer()
                                HStack {
                                    Text { post.date }.font(size: .xs, color: .muted, family: .systemMono)
                                    Link(to: "/blog/\(post.slug)") { "Read →" }
                                        .font(size: .sm, weight: .medium)
                                }
                                .flex(align: .center, gap: 4)
                            }
                            .flex(align: .center)
                        }
                        .padding(4)
                        .background(color: .surface)
                        .border(color: .muted.opacity(0.15), radius: .md)
                        .on(.hover) { $0.shadow(.sm).translate(y: .px(-1)) }
                        .animate(.all, duration: 150.ms)
                    }
                }
                .flex(direction: .vertical, gap: 3)
            }
            .flex(direction: .vertical, gap: 5)
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(6)
            .padding(12, at: .desktop)
        }
    }
}

// MARK: - Blog post page (demonstrates StaticPage)

struct BlogPostPage: Page, StaticPage {
    let post: SamplePost

    var metadata: PageMetadata? {
        PageMetadata(title: post.title, description: "Kitchen Sink blog post.")
    }

    var path: String { "/blog/\(post.slug)" }

    static func instances() async throws -> [BlogPostPage] {
        samplePosts.map { BlogPostPage(post: $0) }
    }

    var body: some View {
        SiteNav()
        Main {
            VStack {
                Link(to: "/blog") { "← Blog" }.font(size: .sm, color: .muted)
                Heading(1) { post.title }.font(size: .threeXL, weight: .bold)
                HStack {
                    Badge { "StaticPage" }
                    Text { post.date }.font(size: .sm, color: .muted, family: .systemMono)
                    Text { post.tags }.font(size: .sm, color: .muted)
                }
                .flex(align: .center, gap: 3)

                Divider().margin(y: 2)

                RichText(
                    markdown: """
                    ## Introduction
                    This page was generated by `BlogPostPage`, which conforms to `StaticPage`.
                    Score calls `instances()` at build time and pre-renders one HTML file per post.

                    ## How StaticPage works
                    1. Implement `static func instances() async throws -> [Self]`
                    2. Declare a `var path: String` to set the URL
                    3. Score calls `instances()` during the build and pre-renders each one

                    ## Tags
                    This post is tagged: **\(post.tags)**
                    """,
                    theme: .blog
                )
            }
            .flex(direction: .vertical, gap: 4)
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(6)
            .padding(12, at: .desktop)
        }
    }
}
