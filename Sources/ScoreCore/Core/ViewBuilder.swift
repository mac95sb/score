/// `@resultBuilder` that assembles heterogeneous `View` children into a single
/// composite view.
@resultBuilder
public struct ViewBuilder {

    // MARK: - Empty block

    public static func buildBlock() -> EmptyView { EmptyView() }

    // MARK: - Single-child block (identity)

    public static func buildBlock<C: View>(_ c: C) -> C { c }

    // MARK: - Multi-child blocks

    public static func buildBlock<C0: View, C1: View>(
        _ c0: C0, _ c1: C1
    ) -> TupleView2<C0, C1> {
        TupleView2(c0, c1)
    }

    public static func buildBlock<C0: View, C1: View, C2: View>(
        _ c0: C0, _ c1: C1, _ c2: C2
    ) -> TupleView3<C0, C1, C2> {
        TupleView3(c0, c1, c2)
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3
    ) -> TupleView4<C0, C1, C2, C3> {
        TupleView4(c0, c1, c2, c3)
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4
    ) -> TupleView5<C0, C1, C2, C3, C4> {
        TupleView5(c0, c1, c2, c3, c4)
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5
    ) -> TupleView6<C0, C1, C2, C3, C4, C5> {
        TupleView6(c0, c1, c2, c3, c4, c5)
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6
    ) -> TupleView7<C0, C1, C2, C3, C4, C5, C6> {
        TupleView7(c0, c1, c2, c3, c4, c5, c6)
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7
    ) -> TupleView8<C0, C1, C2, C3, C4, C5, C6, C7> {
        TupleView8(c0, c1, c2, c3, c4, c5, c6, c7)
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8
    ) -> TupleView9<C0, C1, C2, C3, C4, C5, C6, C7, C8> {
        TupleView9(c0, c1, c2, c3, c4, c5, c6, c7, c8)
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9
    ) -> TupleView10<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9> {
        TupleView10(c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)
    }

    // MARK: - Control flow

    public static func buildOptional<C: View>(_ c: C?) -> _OptionalView<C> {
        _OptionalView(c)
    }

    public static func buildEither<T: View, F: View>(first c: T) -> _ConditionalView<T, F> {
        _ConditionalView(storage: .first(c))
    }

    public static func buildEither<T: View, F: View>(second c: F) -> _ConditionalView<T, F> {
        _ConditionalView(storage: .second(c))
    }

    public static func buildArray<C: View>(_ components: [C]) -> _ArrayView<C> {
        _ArrayView(components)
    }

    // MARK: - Expression overloads

    public static func buildExpression<E: View>(_ expression: E) -> E { expression }

    public static func buildExpression(_ expression: String) -> _StringView {
        _StringView(text: expression)
    }

    public static func buildExpression(_ expression: CustomStringConvertible) -> _StringView {
        _StringView(text: expression.description)
    }

    public static func buildExpression<N: Numeric & CustomStringConvertible>(_ expression: N) -> _StringView {
        _StringView(text: expression.description)
    }
}
