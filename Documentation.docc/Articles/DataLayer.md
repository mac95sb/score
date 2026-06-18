# Data Layer

Define models, query the database, and manage the key-value cache.

## Overview

Score's data layer provides a minimal ORM backed by SQLite (default), with a
``QueryBuilder`` for common operations and a raw SQL interface for queries the
builder does not cover. The cache layer defaults to in-memory storage, with Redis
available as a drop-in replacement.

## Defining Models

Conform a struct to ``Record`` to make it a database entity:

```swift
struct Post: Record {
    var id: UUID = UUID()
    var title: String
    var slug: String
    var excerpt: String
    var body: String
    var published: Bool = false
    var authorId: UUID
    var createdAt: Date = .now
    var updatedAt: Date = .now
}
```

Score derives the table name from the type name (`posts`), column names
from property names, and creates the schema automatically on first run.
UUID primary keys are the default.

## Querying

```swift
// Fetch all matching records
let posts = try await db.query(Post.self)
    .filter(\.published == true)
    .orderBy(\.createdAt, .descending)
    .limit(10)
    .offset(page * 10)
    .all()

// First matching record (nil if none)
let post = try await db.query(Post.self)
    .filter(\.slug == slug)
    .first()

// Lookup by primary key
let post = try await db.find(Post.self, id: someUUID)

// Count
let count = try await db.query(Post.self)
    .filter(\.published == true)
    .count()

// Existence check (more efficient than fetching the record)
let exists = try await db.query(Post.self)
    .filter(\.slug == slug)
    .exists()
```

## Relations

Eager-load related records to avoid N+1 queries:

```swift
let posts = try await db.query(Post.self)
    .include(Author.self, on: \.authorId)
    .filter(\.published == true)
    .all()
```

## Mutations

```swift
// Insert — returns the saved record with any generated defaults
let post = try await db.insert(
    Post(title: "Hello", slug: "hello", excerpt: "...", body: "...", authorId: author.id)
)

// Update — modify and save in place
var post = try await db.find(Post.self, id: id)!
post.published = true
try await db.update(post)

// Delete by primary key
try await db.delete(Post.self, id: id)

// Bulk delete via query
try await db.query(Post.self)
    .filter(\.published == false)
    .delete()
```

## Transactions

Wrap multiple operations in an atomic transaction:

```swift
try await db.transaction { tx in
    let author = try await tx.insert(
        Author(name: "Mac", email: "mac@example.com")
    )
    _ = try await tx.insert(
        Post(title: "First Post", slug: "first-post", authorId: author.id, ...)
    )
}
```

## Raw SQL

For complex queries not covered by ``QueryBuilder``:

```swift
let rows = try await db.raw(
    "SELECT * FROM posts WHERE slug = ?",
    parameters: [slug]
)
```

> Note: v1 does not support OR conditions, nested relations, aggregates beyond
> count, upsert, or bulk insert. Use `.raw()` for these.

## Key-Value Cache

```swift
// Set with expiry
try await cache.set("featured-posts", value: posts, expiry: .minutes(5))

// Get typed value
let cached = try await cache.get("featured-posts", as: [Post].self)

// Atomic increment (view counters, rate limiting)
let views = try await cache.increment("views:\(post.slug)")
let requests = try await cache.increment("ratelimit:\(ip)", expiry: .seconds(60))

// Delete
try await cache.delete("featured-posts")
try await cache.flush(prefix: "featured-")
```

## Configuration

Declare the database on ``Application``. The in-memory cache is available via
`InMemoryCacheConfig` and can be instantiated directly in route handlers or
stored as a property on your application type:

```swift
@main
struct MySite: Application {
    var database: some DatabaseConfig {
        SQLiteDatabase(path: ".score/db.sqlite")
    }
}
```

The SQLite database file is gitignored by default (`.score/db.sqlite`). For
static sites driven entirely by content files, committing the database is safe
and convenient — the `StaticPage.instances()` pattern loads records at build time.

## Database and Cache Plugins

Score ships SQLite and in-memory adapters out of the box. Production deployments
typically use the official plugins:

**PostgreSQL** — drop-in `DatabaseConfig` backed by `PostgresNIO`:

```swift
// Package.swift
.package(url: "https://github.com/mac95sb/score-postgres", branch: "main")

// Application.swift
var database: some DatabaseConfig {
    PostgreSQLDatabase(url: Env.required("DATABASE_URL"))
}
```

**Redis** — drop-in `CacheConfig` backed by `RediStack`:

```swift
// Package.swift
.package(url: "https://github.com/mac95sb/score-redis", branch: "main")

// Application.swift — store as a property so the context is shared across requests
let cache = RedisCache(url: Env.required("REDIS_URL"))
```

Both plugins conform to the same `DatabaseConfig` / `CacheConfig` protocols as
the built-in adapters, so all query and cache APIs work identically.

## See Also

- <doc:APIRoutes>
- <doc:ReactiveState>
- <doc:GettingStarted>
