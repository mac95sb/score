import Score

struct AboutPage: Page {
    var metadata: PageMetadata {
        PageMetadata(title: "About", description: "About __NAME__.")
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "About" }
                    .font(size: .threeXL)
                    .font(weight: .bold)
                Text { "Learn more about __NAME__." }
                    .font(size: .lg)
                    .font(color: .muted)
                    .margin(top: 4)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
