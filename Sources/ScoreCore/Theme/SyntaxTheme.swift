// MARK: - SyntaxTheme

/// Protocol for syntax highlighting themes.
public protocol SyntaxTheme: Sendable {
    var name: String { get }
    var background: Color { get }
    var text: Color { get }
    var comment: Color { get }
    var keyword: Color { get }
    var string: Color { get }
    var number: Color { get }
    var type: Color { get }
    var function: Color { get }
    var variable: Color { get }
    var operator_: Color { get }
    var punctuation: Color { get }
    var attribute: Color { get }
    var literal: Color { get }
    var lineNumbers: Color { get }
}

// MARK: - Score Dark

/// Score's default dark syntax theme.
public struct ScoreDarkSyntaxTheme: SyntaxTheme {
    public var name: String       { "score-dark" }
    public var background: Color  { Color(oklch: 0.13, 0.02, 265) }
    public var text: Color        { Color(oklch: 0.90, 0.02, 265) }
    public var comment: Color     { Color(oklch: 0.55, 0.02, 265) }
    public var keyword: Color     { .violet(400) }
    public var string: Color      { .emerald(400) }
    public var number: Color      { .orange(400) }
    public var type: Color        { .cyan(400) }
    public var function: Color    { .blue(400) }
    public var variable: Color    { Color(oklch: 0.90, 0.02, 265) }
    public var operator_: Color   { .slate(400) }
    public var punctuation: Color { .slate(400) }
    public var attribute: Color   { .pink(400) }
    public var literal: Color     { .amber(400) }
    public var lineNumbers: Color { Color(oklch: 0.40, 0.02, 265) }
    public init() {}
}

// MARK: - Score Light

public struct ScoreLightSyntaxTheme: SyntaxTheme {
    public var name: String       { "score-light" }
    public var background: Color  { Color(oklch: 0.98, 0, 0) }
    public var text: Color        { .slate(900) }
    public var comment: Color     { .slate(400) }
    public var keyword: Color     { .violet(700) }
    public var string: Color      { .emerald(700) }
    public var number: Color      { .orange(700) }
    public var type: Color        { .blue(700) }
    public var function: Color    { .indigo(700) }
    public var variable: Color    { .slate(800) }
    public var operator_: Color   { .slate(600) }
    public var punctuation: Color { .slate(500) }
    public var attribute: Color   { .rose(700) }
    public var literal: Color     { .amber(700) }
    public var lineNumbers: Color { .slate(300) }
    public init() {}
}

// MARK: - GitHub

public struct GithubSyntaxTheme: SyntaxTheme {
    public var name: String       { "github" }
    public var background: Color  { Color(oklch: 1.0, 0, 0) }
    public var text: Color        { Color(oklch: 0.20, 0.01, 260) }
    public var comment: Color     { Color(oklch: 0.55, 0.01, 150) }
    public var keyword: Color     { Color(oklch: 0.45, 0.22, 293) }
    public var string: Color      { Color(oklch: 0.43, 0.16, 25) }
    public var number: Color      { Color(oklch: 0.44, 0.19, 25) }
    public var type: Color        { Color(oklch: 0.50, 0.19, 215) }
    public var function: Color    { Color(oklch: 0.52, 0.17, 215) }
    public var variable: Color    { Color(oklch: 0.20, 0.01, 260) }
    public var operator_: Color   { Color(oklch: 0.20, 0.01, 260) }
    public var punctuation: Color { Color(oklch: 0.35, 0.01, 260) }
    public var attribute: Color   { Color(oklch: 0.47, 0.18, 150) }
    public var literal: Color     { Color(oklch: 0.44, 0.19, 25) }
    public var lineNumbers: Color { Color(oklch: 0.70, 0.01, 260) }
    public init() {}
}

// MARK: - Nord

public struct NordSyntaxTheme: SyntaxTheme {
    public var name: String       { "nord" }
    public var background: Color  { Color(oklch: 0.24, 0.02, 240) }
    public var text: Color        { Color(oklch: 0.91, 0.01, 220) }
    public var comment: Color     { Color(oklch: 0.60, 0.02, 230) }
    public var keyword: Color     { Color(oklch: 0.70, 0.09, 235) }
    public var string: Color      { Color(oklch: 0.80, 0.09, 155) }
    public var number: Color      { Color(oklch: 0.75, 0.10, 205) }
    public var type: Color        { Color(oklch: 0.78, 0.09, 210) }
    public var function: Color    { Color(oklch: 0.75, 0.08, 220) }
    public var variable: Color    { Color(oklch: 0.91, 0.01, 220) }
    public var operator_: Color   { Color(oklch: 0.70, 0.09, 235) }
    public var punctuation: Color { Color(oklch: 0.80, 0.01, 220) }
    public var attribute: Color   { Color(oklch: 0.78, 0.09, 200) }
    public var literal: Color     { Color(oklch: 0.75, 0.10, 50) }
    public var lineNumbers: Color { Color(oklch: 0.45, 0.02, 235) }
    public init() {}
}

// MARK: - Dracula

public struct DraculaSyntaxTheme: SyntaxTheme {
    public var name: String       { "dracula" }
    public var background: Color  { Color(oklch: 0.22, 0.04, 290) }
    public var text: Color        { Color(oklch: 0.92, 0.01, 260) }
    public var comment: Color     { Color(oklch: 0.58, 0.04, 290) }
    public var keyword: Color     { Color(oklch: 0.70, 0.20, 330) }
    public var string: Color      { Color(oklch: 0.78, 0.14, 130) }
    public var number: Color      { Color(oklch: 0.74, 0.12, 60) }
    public var type: Color        { Color(oklch: 0.73, 0.16, 200) }
    public var function: Color    { Color(oklch: 0.82, 0.14, 95) }
    public var variable: Color    { Color(oklch: 0.92, 0.01, 260) }
    public var operator_: Color   { Color(oklch: 0.70, 0.20, 330) }
    public var punctuation: Color { Color(oklch: 0.92, 0.01, 260) }
    public var attribute: Color   { Color(oklch: 0.78, 0.14, 130) }
    public var literal: Color     { Color(oklch: 0.74, 0.12, 60) }
    public var lineNumbers: Color { Color(oklch: 0.42, 0.04, 290) }
    public init() {}
}

// MARK: - One Dark

public struct OneDarkSyntaxTheme: SyntaxTheme {
    public var name: String       { "one-dark" }
    public var background: Color  { Color(oklch: 0.23, 0.02, 255) }
    public var text: Color        { Color(oklch: 0.85, 0.01, 255) }
    public var comment: Color     { Color(oklch: 0.52, 0.02, 255) }
    public var keyword: Color     { Color(oklch: 0.65, 0.17, 320) }
    public var string: Color      { Color(oklch: 0.72, 0.14, 140) }
    public var number: Color      { Color(oklch: 0.75, 0.14, 55) }
    public var type: Color        { Color(oklch: 0.75, 0.14, 210) }
    public var function: Color    { Color(oklch: 0.72, 0.10, 215) }
    public var variable: Color    { Color(oklch: 0.78, 0.12, 30) }
    public var operator_: Color   { Color(oklch: 0.65, 0.17, 320) }
    public var punctuation: Color { Color(oklch: 0.85, 0.01, 255) }
    public var attribute: Color   { Color(oklch: 0.75, 0.14, 55) }
    public var literal: Color     { Color(oklch: 0.75, 0.14, 55) }
    public var lineNumbers: Color { Color(oklch: 0.42, 0.02, 255) }
    public init() {}
}
