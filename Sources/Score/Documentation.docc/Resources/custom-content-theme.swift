extension ContentTheme {
    static var blog: ContentTheme {
        ContentTheme(
            heading: { level, v in
                let size: FontSize = level <= 2 ? .threeXL : .twoXL
                return v.erased().font(size: size, weight: .bold).margin(top: 8, bottom: 2)
            },
            paragraph: { v in
                v.erased().font(leading: .relaxed)
            },
            code: { v in
                v.erased().background(color: .secondary).border(radius: .sm)
            },
            blockquote: { v in
                v.erased()
                    .border(color: .primary, width: 4, edge: .left)
                    .padding(left: 4)
            }
        )
    }
}
