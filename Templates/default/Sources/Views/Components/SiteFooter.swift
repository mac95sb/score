import Score

struct SiteFooter: View {
    var body: some View {
        Footer {
            HStack {
                Text { "© 2026 __NAME__. Built with " }
                    .font(size: .sm)
                    .font(color: .muted)
                Link(to: "https://github.com/mac95sb/score") { "Score" }
                    .font(size: .sm)
                    .font(color: .primary)
                Text { "." }
                    .font(size: .sm)
                    .font(color: .muted)
            }
            .flex(justify: .center)
            .padding(8)
        }
        .border(color: .muted.opacity(0.15), edge: .top)
    }
}
