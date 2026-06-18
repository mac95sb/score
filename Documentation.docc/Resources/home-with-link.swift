import Score

struct HomePage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "Home", description: "Welcome to MySite.")
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "Welcome to MySite" }
                    .font(size: .fourXL, weight: .bold)
                Text { "A site built with Score." }
                    .margin(top: 4)
                Link(to: "/about") { "About this site" }
                    .margin(top: 6)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
