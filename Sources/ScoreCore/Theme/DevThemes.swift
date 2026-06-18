// MARK: - Popular developer editor themes as Score ThemeColors presets
//
// Use these as `customThemes` entries on your `SiteTheme` or as a full
// `darkColors` replacement to ship a themed site that matches a developer's
// familiar editor palette.
//
// ```swift
// var theme: SiteTheme {
//     SiteTheme(
//         darkColors: .rosePine,
//         customThemes: [
//             "tokyo-night": .tokyoNight,
//             "gruvbox":     .gruvbox,
//         ]
//     )
// }
// ```

extension ThemeColors {

    // MARK: Rosé Pine — https://rosepinetheme.com
    public static let rosePine = ThemeColors(
        primary: Color(hex: "#c4a7e7"),  // iris
        accent: Color(hex: "#9ccfd8"),  // foam
        surface: Color(hex: "#1f1d2e"),  // surface
        secondary: Color(hex: "#26233a"),  // overlay
        tertiary: Color(hex: "#191724"),  // base
        text: Color(hex: "#e0def4"),  // text
        muted: Color(hex: "#908caa"),  // subtle
        destructive: Color(hex: "#eb6f92")  // love
    )

    /// Rosé Pine Dawn — light variant
    public static let rosePineDawn = ThemeColors(
        primary: Color(hex: "#907aa9"),  // iris
        accent: Color(hex: "#56949f"),  // foam
        surface: Color(hex: "#faf4ed"),  // base
        secondary: Color(hex: "#f2e9e1"),  // surface
        tertiary: Color(hex: "#fffaf3"),  // overlay
        text: Color(hex: "#575279"),  // text
        muted: Color(hex: "#9893a5"),  // subtle
        destructive: Color(hex: "#b4637a")  // love
    )

    // MARK: Tokyo Night — https://github.com/enkia/tokyo-night-vscode-theme
    public static let tokyoNight = ThemeColors(
        primary: Color(hex: "#7aa2f7"),  // blue
        accent: Color(hex: "#7dcfff"),  // cyan
        surface: Color(hex: "#24283b"),  // bg_highlight
        secondary: Color(hex: "#1a1b26"),  // bg
        tertiary: Color(hex: "#16161e"),  // bg_dark
        text: Color(hex: "#c0caf5"),  // fg
        muted: Color(hex: "#565f89"),  // comment
        destructive: Color(hex: "#f7768e")  // red
    )

    /// Tokyo Night Storm — slightly lighter dark variant
    public static let tokyoNightStorm = ThemeColors(
        primary: Color(hex: "#7aa2f7"),
        accent: Color(hex: "#73daca"),  // teal
        surface: Color(hex: "#2f334d"),
        secondary: Color(hex: "#24283b"),
        tertiary: Color(hex: "#1d2033"),
        text: Color(hex: "#c0caf5"),
        muted: Color(hex: "#565f89"),
        destructive: Color(hex: "#f7768e")
    )

    // MARK: Vesper — https://github.com/raunofreiberg/vesper
    public static let vesper = ThemeColors(
        primary: Color(hex: "#ffc799"),  // orange
        accent: Color(hex: "#ffbd5a"),  // gold
        surface: Color(hex: "#1a1a1a"),
        secondary: Color(hex: "#151515"),
        tertiary: Color(hex: "#101010"),
        text: Color(hex: "#ffffff"),
        muted: Color(hex: "#5e5e5e"),
        destructive: Color(hex: "#ff5f57")
    )

    // MARK: One Dark — https://github.com/atom/one-dark-syntax
    public static let oneDark = ThemeColors(
        primary: Color(hex: "#61afef"),  // blue
        accent: Color(hex: "#56b6c2"),  // cyan
        surface: Color(hex: "#2c313a"),  // bg1
        secondary: Color(hex: "#282c34"),  // bg0
        tertiary: Color(hex: "#21252b"),  // bg_dark
        text: Color(hex: "#abb2bf"),  // fg
        muted: Color(hex: "#5c6370"),  // comment
        destructive: Color(hex: "#e06c75")  // red
    )

    // MARK: Gruvbox Dark — https://github.com/morhetz/gruvbox
    public static let gruvboxDark = ThemeColors(
        primary: Color(hex: "#458588"),  // blue
        accent: Color(hex: "#98971a"),  // green
        surface: Color(hex: "#3c3836"),  // bg1
        secondary: Color(hex: "#282828"),  // bg0
        tertiary: Color(hex: "#1d2021"),  // bg_hard
        text: Color(hex: "#ebdbb2"),  // fg
        muted: Color(hex: "#928374"),  // gray
        destructive: Color(hex: "#cc241d")  // red
    )

    /// Gruvbox Light
    public static let gruvboxLight = ThemeColors(
        primary: Color(hex: "#076678"),  // blue dark
        accent: Color(hex: "#79740e"),  // green dark
        surface: Color(hex: "#f2e5bc"),  // bg1
        secondary: Color(hex: "#fbf1c7"),  // bg0
        tertiary: Color(hex: "#f9f5d7"),  // bg_hard
        text: Color(hex: "#3c3836"),  // fg
        muted: Color(hex: "#928374"),  // gray
        destructive: Color(hex: "#9d0006")  // red dark
    )
}
