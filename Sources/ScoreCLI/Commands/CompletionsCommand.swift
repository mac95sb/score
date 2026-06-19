import ArgumentParser

/// `score completions <shell>` — print a shell completion script for the Score CLI.
///
/// Source the output to enable tab-completion in your shell:
///
/// ```sh
/// # zsh
/// score completions zsh > ~/.zsh/_score && autoload -Uz compinit && compinit
///
/// # bash
/// score completions bash > /usr/local/etc/bash_completion.d/score
///
/// # fish
/// score completions fish > ~/.config/fish/completions/score.fish
/// ```
struct CompletionsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "completions",
        abstract: "Print a shell completion script (zsh, bash, or fish)."
    )

    enum Shell: String, ExpressibleByArgument, CaseIterable {
        case zsh
        case bash
        case fish
    }

    @Argument(help: "Shell to generate completions for: zsh, bash, fish.")
    var shell: Shell

    mutating func run() throws {
        // ArgumentParser generates completion scripts via --generate-completion-script.
        // We delegate to that mechanism by re-invoking the top-level command.
        let args = ["score", "--generate-completion-script", shell.rawValue]
        var cmd = try ScoreCLI.parseAsRoot(Array(args.dropFirst()))
        try cmd.run()
    }
}
