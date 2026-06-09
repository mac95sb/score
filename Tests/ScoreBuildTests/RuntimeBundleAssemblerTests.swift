import Testing
@testable import ScoreBuild

@Suite("RuntimeBundleAssembler")
struct RuntimeBundleAssemblerTests {
    let assembler = RuntimeBundleAssembler()

    @Test("empty flags produce empty bundle")
    func emptyFlags() {
        let js = assembler.assemble(flags: .none)
        #expect(js.isEmpty)
    }

    @Test("signals module is included when requested")
    func signalsIncluded() {
        let js = assembler.assemble(flags: FeatureFlags(signals: true))
        #expect(js.contains("__score_signal"))
    }

    @Test("action bridge included when requested")
    func actionBridgeIncluded() {
        let js = assembler.assemble(flags: FeatureFlags(actionBridge: true))
        #expect(js.contains("__score_action"))
    }

    @Test("websocket module included when requested")
    func webSocketIncluded() {
        let js = assembler.assemble(flags: FeatureFlags(webSocket: true))
        #expect(js.contains("__score_ws"))
    }

    @Test("full flags includes all modules")
    func fullFlags() {
        let js = assembler.assemble(flags: .full)
        #expect(js.contains("__score_signal"))
        #expect(js.contains("__score_action"))
        #expect(js.contains("__score_ws"))
        #expect(js.contains("__score_crdt"))
    }

    @Test("minify reduces size")
    func minifyReducesSize() {
        let normal = assembler.assemble(flags: .full, minify: false)
        let minified = assembler.assemble(flags: .full, minify: true)
        #expect(minified.count < normal.count)
    }

    @Test("dev reload module included for development flags")
    func devReloadIncluded() {
        let js = assembler.assemble(flags: .development)
        #expect(js.contains("__score/dev"))
    }
}
