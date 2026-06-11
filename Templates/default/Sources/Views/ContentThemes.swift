import Score

extension ContentTheme {
    static var article: ContentTheme {
        ContentTheme(
            heading: { level, v in
                let size: FontSize = level == 1 ? .fourXL : level == 2 ? .threeXL : level == 3 ? .twoXL : .xl
                return v.erased().font(size: size, weight: .bold).margin(y: .rem(1))
            },
            paragraph: { v in
                v.erased().font(size: .lg, leading: .relaxed).margin(y: .rem(0.75))
            },
            code: { v in
                v.erased().font(family: .systemMono).padding(.px(2), .px(6)).border(radius: .sm).background(color: .surface)
            },
            blockquote: { v in
                v.erased().border(color: .primary, width: 4, edge: .left).padding(left: 4).margin(y: .rem(1))
            },
            list: { _, v in
                v.erased().margin(y: .rem(0.75)).padding(left: 6)
            },
            listItem: { v in v },
            table: { v in v.erased().margin(y: .rem(1)) },
            link: { v in v.erased().font(color: .primary, decoration: .underline) },
            image: { v in v.erased().border(radius: .lg).margin(y: .rem(1.5)) },
            divider: { v in v.erased().margin(y: .rem(2)) },
            strong: { v in v.erased().font(weight: .semibold) },
            emphasis: { v in v.erased().font(style: .italic) },
            strikethrough: { v in v.erased().font(decoration: .lineThrough) }
        )
    }
}
