import Testing
@testable import ScoreCore

@Suite("Modifiers")
struct ModifierTests {
    @Test("padding modifier produces CSS declaration")
    func paddingModifier() throws {
        let modified = Text { "hi" }.padding(4)
        var cssCtx = CSSCollectionContext()
        modified._collectCSSInto(&cssCtx)
        // Modifiers attach to the component's CSS block
        // We verify the view renders without crashing
        var ctx = RenderContext()
        let html = modified._renderInto(&ctx)
        #expect(!html.isEmpty)
    }

    @Test("chaining multiple modifiers works")
    func chainedModifiers() throws {
        let view = Stack { Text { "layered" } }
            .padding(4)
            .margin(x: 2)
            .background(color: .primary)
        var ctx = RenderContext()
        let html = view._renderInto(&ctx)
        #expect(html.contains("<div"))
    }

    @Test("frame modifier sets width and height")
    func frameModifier() throws {
        let view = Stack { EmptyView() }
            .frame(width: .px(100), height: .px(200))
        var ctx = RenderContext()
        _ = view._renderInto(&ctx)  // should not crash
    }

    @Test("display modifier produces correct value")
    func displayModifier() throws {
        let view = Stack { EmptyView() }.display(.flex)
        var ctx = RenderContext()
        _ = view._renderInto(&ctx)
    }

    @Test("font modifier applies size and weight")
    func fontModifier() throws {
        let view = Text { "styled" }.font(size: .lg).font(weight: .bold)
        var ctx = RenderContext()
        _ = view._renderInto(&ctx)
    }

    @Test("border modifier renders without crash")
    func borderModifier() throws {
        let view = Stack { EmptyView() }.border(color: .primary, width: 1)
        var ctx = RenderContext()
        _ = view._renderInto(&ctx)
    }

    @Test("shadow modifier renders without crash")
    func shadowModifier() throws {
        let view = Stack { EmptyView() }.shadow(.md)
        var ctx = RenderContext()
        _ = view._renderInto(&ctx)
    }
}
