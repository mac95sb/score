import Testing

@testable import ScoreCore

@Suite("ViewBuilder")
struct ViewBuilderTests {
    @Test("builds single view")
    func buildsSingleView() throws {
        let view = Text { "Hello" }
        var ctx = RenderContext()
        let html = view._renderInto(&ctx)
        #expect(html == "<p>Hello</p>")
    }

    @Test("builds tuple of views")
    func buildsTuple() throws {
        @ViewBuilder func content() -> some View {
            Text { "One" }
            Text { "Two" }
        }
        var ctx = RenderContext()
        let html = content()._renderInto(&ctx)
        #expect(html.contains("<p>One</p>"))
        #expect(html.contains("<p>Two</p>"))
    }

    @Test("builds conditional true branch")
    func buildsConditionalTrue() throws {
        let flag = true
        @ViewBuilder func content() -> some View {
            if flag {
                Text { "Shown" }
            } else {
                Text { "Hidden" }
            }
        }
        var ctx = RenderContext()
        let html = content()._renderInto(&ctx)
        #expect(html.contains("Shown"))
        #expect(!html.contains("Hidden"))
    }

    @Test("builds optional view when present")
    func buildsOptionalPresent() throws {
        let value: String? = "present"
        @ViewBuilder func content() -> some View {
            if let v = value {
                Text { v }
            }
        }
        var ctx = RenderContext()
        let html = content()._renderInto(&ctx)
        #expect(html.contains("present"))
    }

    @Test("builds optional view when nil produces empty")
    func buildsOptionalNil() throws {
        let value: String? = nil
        @ViewBuilder func content() -> some View {
            if let v = value {
                Text { v }
            }
        }
        var ctx = RenderContext()
        let html = content()._renderInto(&ctx)
        #expect(html.isEmpty || html == "")
    }

    @Test("builds array of views")
    func buildsArray() throws {
        let items = ["A", "B", "C"]
        @ViewBuilder func content() -> some View {
            for item in items {
                Text { item }
            }
        }
        var ctx = RenderContext()
        let html = content()._renderInto(&ctx)
        #expect(html.contains("A"))
        #expect(html.contains("B"))
        #expect(html.contains("C"))
    }
}
