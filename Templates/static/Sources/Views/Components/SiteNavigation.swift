import Score

struct SiteNavigation: View {
    var body: some View {
        Nav(label: "Main navigation") {
            HStack {
                Link(to: "/") { "__NAME__" }
                    .font(weight: .semibold)
                Spacer()
                HStack {
                    NavLink(to: "/") { "Home" }
                    NavLink(to: "/blog") { "Blog" }
                    NavLink(to: "/about") { "About" }
                }
                .flex(gap: 6)
            }
            .flex(align: .center)
            .padding(x: 6, y: 4)
            .frame(maxWidth: .px(1200))
            .margin(x: .auto)
        }
        .border(color: .muted.opacity(0.15), edge: .bottom)
        .background(color: .surface)
        .position(.sticky, top: 0)
        .position(zIndex: 10)
    }
}
