import Score

struct SiteFooter: View {
    var body: some View {
        Footer {
            HStack {
                Text { "© 2026 __NAME__. Built with " }
                    .font(size: .sm, color: .muted)
                Link(to: "https://github.com/mac95sb/score") { "Score" }
                    .font(size: .sm, color: .primary)
                Text { "." }
                    .font(size: .sm, color: .muted)
            }
            .flex(justify: .center)
            .padding(8)
        }
        .border(color: .muted.opacity(0.15), edge: .top)
    }
}
