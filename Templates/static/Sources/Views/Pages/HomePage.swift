import Score

struct HomePage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "Home", description: "Welcome to __NAME__.")
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "Welcome to __NAME__" }
                    .font(size: .fourXL)
                    .font(weight: .bold)
                    .font(wrap: .balance)
                Text { "A static site built with Score." }
                    .font(size: .xl)
                    .font(color: .muted)
                    .margin(top: 4)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
            .padding(16, at: .desktop)
        }
    }
}
