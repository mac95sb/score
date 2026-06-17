# Reactive State

Use `@State`, `@Binding`, and `@Action` to build interactive components.

## Overview

Score has one state primitive: `@State`. Declare state on a view — Score infers
what to do with it from the type and app configuration.

`@State` and `@Action` expand into HTML `data-state-*` attributes carrying
initial values and vanilla JavaScript wired by Score's runtime on page load.

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
        .flex(align: .center, gap: 4)
    }
}
```

State variables in element content are captured directly — no explicit binding
needed for display-only use. Score subscribes the text node to the signal
and updates it in place.

## Two Tiers, One Syntax

Score infers whether state is ephemeral or persistent from the type and app config:

| Type | Behaviour |
|------|-----------|
| `Bool`, `Int`, `String`… | Always ephemeral UI state |
| `Codable` struct (not Record) | Persistent when `stateMode: .localFirst` |
| ``Record`` conformer | Always persistent, always CRDT-synced |

```swift
// Ephemeral — in-memory, resets on navigation
@State var isOpen: Bool = false
@State var count: Int = 0
@State var draft: PostDraft = PostDraft()

// Persistent — requires stateMode: .localFirst or a Record type
@State var preferences: UserPreferences = UserPreferences()
@State var post: Post                                        // Record → always persistent
```

## @Action

`@Action` marks a function as a reactive action. Whether it runs in the browser
or on the server is determined by what it captures — not by how it's annotated.
Actions that capture only `@State` values are emitted as vanilla JavaScript.
Actions that capture server-only types (`db`, `cache`) are compiled server-side
and invoked over an automatically generated endpoint.

```swift
struct CounterView: View {
    @State var count: Int = 0

    @Action func increment() { count += 1 }
    @Action func reset() { count = 0 }

    var body: some View {
        HStack {
            Heading(2) { "\(count)" }
            Button(.ghost) { "+" }.on(.click, run: increment)
            Button(.ghost) { "Reset" }.on(.click, run: reset)
        }
        .flex(align: .center, gap: 4)
    }
}
```

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
        Input(type: .search, name: "q", value: $query)
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

## See Also

- <doc:DataLayer>
- <doc:APIRoutes>
- <doc:ViewHierarchy>
