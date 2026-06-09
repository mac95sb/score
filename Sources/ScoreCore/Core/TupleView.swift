// MARK: - TupleView2

public struct TupleView2<C0: View, C1: View>: View, _HTMLRenderable {
    let c0: C0
    let c1: C1
    init(_ c0: C0, _ c1: C1) { self.c0 = c0; self.c1 = c1 }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context)
        c1._collectCSSInto(&context)
    }
}

// MARK: - TupleView3

public struct TupleView3<C0: View, C1: View, C2: View>: View, _HTMLRenderable {
    let c0: C0; let c1: C1; let c2: C2
    init(_ c0: C0, _ c1: C1, _ c2: C2) { self.c0 = c0; self.c1 = c1; self.c2 = c2 }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context) + c2._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context); c1._collectCSSInto(&context); c2._collectCSSInto(&context)
    }
}

// MARK: - TupleView4

public struct TupleView4<C0: View, C1: View, C2: View, C3: View>: View, _HTMLRenderable {
    let c0: C0; let c1: C1; let c2: C2; let c3: C3
    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) {
        self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3
    }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context)
            + c2._renderInto(&context) + c3._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context); c1._collectCSSInto(&context)
        c2._collectCSSInto(&context); c3._collectCSSInto(&context)
    }
}

// MARK: - TupleView5

public struct TupleView5<C0: View, C1: View, C2: View, C3: View, C4: View>: View, _HTMLRenderable {
    let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4
    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) {
        self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3; self.c4 = c4
    }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context) + c2._renderInto(&context)
            + c3._renderInto(&context) + c4._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context); c1._collectCSSInto(&context); c2._collectCSSInto(&context)
        c3._collectCSSInto(&context); c4._collectCSSInto(&context)
    }
}

// MARK: - TupleView6

public struct TupleView6<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>: View, _HTMLRenderable {
    let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4; let c5: C5
    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) {
        self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3; self.c4 = c4; self.c5 = c5
    }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context) + c2._renderInto(&context)
            + c3._renderInto(&context) + c4._renderInto(&context) + c5._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context); c1._collectCSSInto(&context); c2._collectCSSInto(&context)
        c3._collectCSSInto(&context); c4._collectCSSInto(&context); c5._collectCSSInto(&context)
    }
}

// MARK: - TupleView7

public struct TupleView7<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>: View, _HTMLRenderable {
    let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4; let c5: C5; let c6: C6
    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) {
        self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3
        self.c4 = c4; self.c5 = c5; self.c6 = c6
    }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context) + c2._renderInto(&context)
            + c3._renderInto(&context) + c4._renderInto(&context) + c5._renderInto(&context)
            + c6._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context); c1._collectCSSInto(&context); c2._collectCSSInto(&context)
        c3._collectCSSInto(&context); c4._collectCSSInto(&context); c5._collectCSSInto(&context)
        c6._collectCSSInto(&context)
    }
}

// MARK: - TupleView8

public struct TupleView8<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>: View, _HTMLRenderable {
    let c0: C0; let c1: C1; let c2: C2; let c3: C3
    let c4: C4; let c5: C5; let c6: C6; let c7: C7
    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) {
        self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3
        self.c4 = c4; self.c5 = c5; self.c6 = c6; self.c7 = c7
    }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context) + c2._renderInto(&context)
            + c3._renderInto(&context) + c4._renderInto(&context) + c5._renderInto(&context)
            + c6._renderInto(&context) + c7._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context); c1._collectCSSInto(&context); c2._collectCSSInto(&context)
        c3._collectCSSInto(&context); c4._collectCSSInto(&context); c5._collectCSSInto(&context)
        c6._collectCSSInto(&context); c7._collectCSSInto(&context)
    }
}

// MARK: - TupleView9

public struct TupleView9<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>: View, _HTMLRenderable {
    let c0: C0; let c1: C1; let c2: C2; let c3: C3
    let c4: C4; let c5: C5; let c6: C6; let c7: C7; let c8: C8
    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) {
        self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3
        self.c4 = c4; self.c5 = c5; self.c6 = c6; self.c7 = c7; self.c8 = c8
    }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context) + c2._renderInto(&context)
            + c3._renderInto(&context) + c4._renderInto(&context) + c5._renderInto(&context)
            + c6._renderInto(&context) + c7._renderInto(&context) + c8._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context); c1._collectCSSInto(&context); c2._collectCSSInto(&context)
        c3._collectCSSInto(&context); c4._collectCSSInto(&context); c5._collectCSSInto(&context)
        c6._collectCSSInto(&context); c7._collectCSSInto(&context); c8._collectCSSInto(&context)
    }
}

// MARK: - TupleView10

public struct TupleView10<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>: View, _HTMLRenderable {
    let c0: C0; let c1: C1; let c2: C2; let c3: C3
    let c4: C4; let c5: C5; let c6: C6; let c7: C7; let c8: C8; let c9: C9
    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) {
        self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3
        self.c4 = c4; self.c5 = c5; self.c6 = c6; self.c7 = c7; self.c8 = c8; self.c9 = c9
    }
    public typealias Body = Swift.Never
    public var body: Swift.Never { fatalError() }
    public func renderHTML(context: inout RenderContext) -> String {
        c0._renderInto(&context) + c1._renderInto(&context) + c2._renderInto(&context)
            + c3._renderInto(&context) + c4._renderInto(&context) + c5._renderInto(&context)
            + c6._renderInto(&context) + c7._renderInto(&context) + c8._renderInto(&context)
            + c9._renderInto(&context)
    }
    public func collectCSS(context: inout CSSCollectionContext) {
        c0._collectCSSInto(&context); c1._collectCSSInto(&context); c2._collectCSSInto(&context)
        c3._collectCSSInto(&context); c4._collectCSSInto(&context); c5._collectCSSInto(&context)
        c6._collectCSSInto(&context); c7._collectCSSInto(&context); c8._collectCSSInto(&context)
        c9._collectCSSInto(&context)
    }
}
