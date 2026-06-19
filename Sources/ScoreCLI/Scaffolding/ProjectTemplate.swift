import ArgumentParser

// MARK: - ProjectTemplate

enum ProjectTemplate: String, ExpressibleByArgument, CaseIterable {
    case `default`
    case `static`
    case kitchenSink = "kitchen-sink"
}

// MARK: - AgentsMode

/// Controls which AI context files `score new` writes into the new project.
enum AgentsMode: String, ExpressibleByArgument, CaseIterable {
    /// Write both `AGENTS.md` (all AI agents) and `CLAUDE.md` (Claude Code).
    case `default`
    /// Write `AGENTS.md` only.
    case agents
    /// Write `CLAUDE.md` only.
    case claude
    /// Write neither file.
    case none

    var writesAgents: Bool { self == .default || self == .agents }
    var writesClaude: Bool { self == .default || self == .claude }
}
