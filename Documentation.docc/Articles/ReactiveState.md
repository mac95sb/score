# Reactive State

Use `@State`, `@Binding`, and `@Action` to build interactive components.

## Overview

Score has one state primitive: `@State`. The developer declares state — Score
infers what to do with it from the type and app configuration.

`@State` and `@Action` are compile-time macros. They expand into HTML
`data-state-*` attributes carrying initial values and vanilla JS wired by
Score's runtime on page load. Nothing Swift runs in the browser. No WASM.

## @State — UI State

```swift
struct CounterView: View {
    @State var count: Int = 0

    var body: some View {
        HStack {
            Heading(2) { "\(count)" }
            Button(.ghost) { "−" }.on(.click) { count -= 1 }
            Button(.ghost) { "+" }.on(.click) { count += 1 }
        }
        .flex(align: .center)
        .flex(gap: 4)
    }
}
```

State variables in element content are captured directly — no explicit binding
needed for display-only use. Score subscribes the text node to the signal
and updates it in place.

## Two Tiers, One Syntax

```swift
// Tier 1 — UI state (ephemeral, in-memory, resets on navigation)
// Type: any primitive or Codable struct that is not a Record
@State var isOpen: Bool = false
@State var count: Int = 0
@State var draft: PostDraft = PostDraft()   // PostDraft: Codable, not Record

// Tier 2 — persistent state (requires stateMode: .localFirst or Record type)
@State var preferences: UserPreferences = UserPreferences()  // Codable + localFirst
@State var post: Post                                         // Record → always persistent
```

Score infers the tier from the type and app config. The developer never annotates it.

| Type | Behaviour |
|------|-----------|
| `Bool`, `Int`, `String`… | Always ephemeral UI state |
| `Codable` struct (not Record) | Persistent when `stateMode: .localFirst` |
| ``Record`` conformer | Always persistent, always CRDT-synced |

## @Action

Actions modify state or call server-side logic. Whether an `@Action` runs on
the server or the client is determined by what it **captures**, not by inspecting
its body:

```swift
struct PostEditor: View {
    @State var post: Post   // Record → persistent, CRDT synced

    // Server action — captures db → compiler-enforced server-only
    @Action func save() async throws {
        try await db.update(post)
    }

    // Client action — no db/cache capture → emitted as vanilla JS
    @Action func togglePublished() {
        post.published.toggle()
    }

    var body: some View {
        VStack {
            Input(type: .text, name: "title")
                .bind(to: $post.title)
            Button(.primary) { "Save" }.on(.click, run: save)
        }
    }
}
```

`db` and `cache` are server-only types. The Swift compiler enforces this — you
cannot call `db.query()` in a client action because `db` is unavailable in the
client build. No magic, no heuristics.

## @Binding — Sharing State

Pass a parent's `@State` down to a child without transferring ownership:

```swift
struct SearchForm: View {
    @State var query: String = ""

    var body: some View {
        SearchInput(query: $query)   // $ prefix creates a Binding
    }
}

struct SearchInput: View {
    @Binding var query: String

    var body: some View {
        Input(type: .search, name: "q")
            .bind(to: $query)
    }
}
```

> Important: Never place `@State` and `@Binding` on the same property. `@State`
> declares ownership; `@Binding` is a reference to someone else's state.

## @Fetch — Server Data in Views

Fetch data from an API endpoint and use it directly in a view:

```swift
struct BlogIndexPage: Page {
    @Fetch("/api/v1/posts") var posts: [Post]

    var body: some View {
        Grid { for post in posts { ArticleCard(post: post) } }
            .grid(columns: 3)
    }
}
```

Reactive refetch when a `@State` parameter changes:

```swift
struct PostList: View {
    @State var tag: String = "all"
    @Fetch("/api/v1/posts", params: ["tag": $tag]) var posts: [Post]

    var body: some View {
        if posts.isLoading {
            Spinner()
        } else {
            for post in posts.value ?? [] { ArticleCard(post: post) }
        }
    }
}
```

## Static vs Reactive Components

Score analyses each component at build time:

| Mode | Condition | JS emitted |
|------|-----------|-----------|
| `.static` | No `@State` anywhere in component tree | None |
| `.reactive` | Has `@State` | Only modules the component needs |
| `.boundary` | Static parent, reactive child island | Minimal — island only |

A marketing page with no state emits zero JavaScript. An interactive widget on
the same page contributes only the modules it uses, conditionally included.

## App-Level State Mode

```swift
@main
struct MySite: Application {
    var stateMode: StateMode { .ephemeral }   // default — nothing persisted beyond Records
    // var stateMode: StateMode { .localFirst } // plain Codable @State → CRDT + IndexedDB
}
```

## Related Concepts

- <doc:ViewHierarchy> — the view layer state drives
- <doc:DataLayer> — persisting state with Records and the ORM
- <doc:APIRoutes> — API endpoints that `@Fetch` calls
