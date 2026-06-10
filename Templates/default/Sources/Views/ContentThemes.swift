import Score

extension ContentTheme {
    /// The content theme used for blog posts in __NAME__.
    static var blog: ContentTheme {
        ContentTheme(
            heading: { level, v in
                let size: FontSize = level == 1 ? .fourXL : level == 2 ? .threeXL : level == 3 ? .twoXL : .xl
                return AnyView(AnyView(v).modifier(FontModifier(size: size, weight: .bold)).margin(y: .rem(1)))
            },
            paragraph: { v in
                AnyView(AnyView(v).modifier(FontModifier(size: .lg, leading: .relaxed)).margin(y: .rem(0.75)))
            },
            code: { v in
                AnyView(AnyView(v).modifier(FontModifier(family: .systemMono)).padding(.px(2), .px(6)).border(radius: .sm).background(color: .surface))
            },
            blockquote: { v in
                AnyView(AnyView(v).border(color: .primary, width: 4, edge: .left).padding(left: 4).margin(y: .rem(1)))
            },
            list: { _, v in
                AnyView(AnyView(v).margin(y: .rem(0.75)).padding(left: 6))
            },
            listItem: { v in AnyView(v) },
            table: { v in AnyView(AnyView(v).margin(y: .rem(1))) },
            link: { v in AnyView(AnyView(v).font(color: .primary).font(decoration: .underline)) },
            image: { v in AnyView(AnyView(v).border(radius: .lg).margin(y: .rem(1.5))) },
            divider: { v in AnyView(AnyView(v).margin(y: .rem(2))) },
            strong: { v in AnyView(AnyView(v).font(weight: .semibold)) },
            emphasis: { v in AnyView(AnyView(v).font(style: .italic)) },
            strikethrough: { v in AnyView(AnyView(v).font(decoration: .lineThrough)) }
        )
    }
}
