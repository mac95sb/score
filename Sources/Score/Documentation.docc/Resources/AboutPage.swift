import Score

struct AboutPage: Page {
    var metadata: PageMetadata? {
        PageMetadata(title: "About", description: "About MySite.")
    }

    var body: some View {
        Main {
            Section {
                Heading(1) { "About" }
                    .font(size: .threeXL, weight: .bold)
                Text { "MySite is a Score-powered static site." }
                    .margin(top: 4)
            }
            .frame(maxWidth: .px(720))
            .margin(x: .auto)
            .padding(8)
        }
    }
}
