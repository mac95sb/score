/// Score — a Swift-first full-stack web framework.
///
/// Score lets you describe web content, layout, and behaviour entirely in Swift.
/// It renders to vanilla HTML, CSS, and JavaScript — no WebAssembly, no
/// transpilation, no JavaScript build step required.
///
/// This module re-exports every Score sub-module so that a single
/// `import Score` is all client code needs:
///
/// - ``ScoreCore``   — shared primitives, protocols, and utilities
/// - ``ScoreHTTP``   — NIO-backed HTTP/1.1 and HTTP/2 server
/// - ``ScoreRouter`` — type-safe request routing
/// - ``ScoreData``   — persistence, migrations, and query building
/// - ``ScoreSSG``    — static-site generation and Markdown rendering
/// - ``ScoreBuild``  — asset pipeline and incremental build system

@_exported import ScoreCore
@_exported import ScoreHTTP
@_exported import ScoreRouter
@_exported import ScoreData
@_exported import ScoreSSG
@_exported import ScoreBuild
