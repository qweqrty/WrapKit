#if canImport(SwiftUI)
@testable import WrapKit
import XCTest

final class SUIStackViewStateModelTests: XCTestCase {
    func test_premountFullModelAndGranularOutputsHonorFinalWriteInEitherOrder() {
        let modelLastAdapter = StackViewOutputSwiftUIAdapter()
        applyGranularValues(to: modelLastAdapter, variant: .old)
        modelLastAdapter.display(model: model(variant: .latest))

        let granularLastAdapter = StackViewOutputSwiftUIAdapter()
        granularLastAdapter.display(model: model(variant: .old))
        applyGranularValues(to: granularLastAdapter, variant: .latest)

        assert(makeSUT(adapter: modelLastAdapter), matches: .latest)
        assert(makeSUT(adapter: granularLastAdapter), matches: .latest)
    }

    func test_premountNilFullModelFieldsPreserveGranularValues() {
        let adapter = StackViewOutputSwiftUIAdapter()
        applyGranularValues(to: adapter, variant: .latest)
        adapter.display(model: .init(
            axis: nil,
            distribution: nil,
            alignment: nil,
            spacing: nil,
            layoutMargins: nil
        ))

        assert(makeSUT(adapter: adapter), matches: .latest)
    }

    func test_premountNilGranularSpacingPreservesFullModelSpacing() {
        let adapter = StackViewOutputSwiftUIAdapter()
        adapter.display(model: model(variant: .latest))
        adapter.display(spacing: nil)

        XCTAssertEqual(makeSUT(adapter: adapter).spacing, Variant.latest.spacing)
    }

    func test_fullModelDoesNotChangeIndependentVisibility() {
        let adapter = StackViewOutputSwiftUIAdapter()
        adapter.display(isHidden: true)
        adapter.display(model: model(variant: .latest))

        XCTAssertTrue(makeSUT(adapter: adapter).isHidden)
    }

    private func makeSUT(
        adapter: StackViewOutputSwiftUIAdapter
    ) -> SUIStackViewStateModel {
        SUIStackViewStateModel(
            adapter: adapter,
            axis: .horizontal,
            distribution: .fill,
            alignment: .fill,
            spacing: 0,
            layoutMargins: .zero,
            isHidden: false
        )
    }

    private func applyGranularValues(
        to adapter: StackViewOutputSwiftUIAdapter,
        variant: Variant
    ) {
        adapter.display(axis: variant.axis)
        adapter.display(distribution: variant.distribution)
        adapter.display(alignment: variant.alignment)
        adapter.display(spacing: variant.spacing)
        adapter.display(layoutMargins: variant.layoutMargins)
    }

    private func model(variant: Variant) -> StackViewPresentableModel {
        .init(
            axis: variant.axis,
            distribution: variant.distribution,
            alignment: variant.alignment,
            spacing: variant.spacing,
            layoutMargins: variant.layoutMargins
        )
    }

    private func assert(
        _ sut: SUIStackViewStateModel,
        matches variant: Variant,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.axis, variant.axis, file: file, line: line)
        XCTAssertEqual(sut.distribution, variant.distribution, file: file, line: line)
        XCTAssertEqual(sut.alignment, variant.alignment, file: file, line: line)
        XCTAssertEqual(sut.spacing, variant.spacing, file: file, line: line)
        XCTAssertEqual(sut.layoutMargins, variant.layoutMargins, file: file, line: line)
    }
}

private enum Variant {
    case old
    case latest

    var axis: StackViewAxis {
        switch self {
        case .old: .horizontal
        case .latest: .vertical
        }
    }

    var distribution: StackViewDistribution {
        switch self {
        case .old: .fill
        case .latest: .equalSpacing
        }
    }

    var alignment: StackViewAlignment {
        switch self {
        case .old: .leading
        case .latest: .trailing
        }
    }

    var spacing: CGFloat {
        switch self {
        case .old: 3
        case .latest: 17
        }
    }

    var layoutMargins: EdgeInsets {
        switch self {
        case .old: .init(all: 2)
        case .latest: .init(top: 4, leading: 6, bottom: 8, trailing: 10)
        }
    }
}
#endif
