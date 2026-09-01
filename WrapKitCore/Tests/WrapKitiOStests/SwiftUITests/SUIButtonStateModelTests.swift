#if canImport(SwiftUI)
@testable import WrapKit
import XCTest

final class SUIButtonStateModelTests: XCTestCase {
    func test_init_replaysLoadingStateConfiguredBeforeSubscription() {
        let buttonAdapter = ButtonOutputSwiftUIAdapter()
        let loadingAdapter = LoadingOutputSwiftUIAdapter()
        loadingAdapter.display(isLoading: true)

        let sut = SUIButtonStateModel(
            adapter: buttonAdapter,
            loadingAdapter: loadingAdapter
        )

        XCTAssertTrue(sut.isLoading)
    }

    func test_loadingOutput_updatesExistingButtonStateModel() {
        let loadingAdapter = LoadingOutputSwiftUIAdapter()
        let sut = SUIButtonStateModel(
            adapter: ButtonOutputSwiftUIAdapter(),
            loadingAdapter: loadingAdapter
        )

        loadingAdapter.display(isLoading: true)
        XCTAssertTrue(sut.isLoading)

        loadingAdapter.display(isLoading: false)
        XCTAssertFalse(sut.isLoading)
    }

    func test_premountLoadingUsesFinalPublicWriteInEitherOrder() {
        let propertyLastAdapter = LoadingOutputSwiftUIAdapter()
        propertyLastAdapter.display(isLoading: true)
        propertyLastAdapter.isLoading = false

        let displayLastAdapter = LoadingOutputSwiftUIAdapter()
        displayLastAdapter.isLoading = false
        displayLastAdapter.display(isLoading: true)

        XCTAssertFalse(SUIButtonStateModel(
            adapter: ButtonOutputSwiftUIAdapter(),
            loadingAdapter: propertyLastAdapter
        ).isLoading)
        XCTAssertTrue(SUIButtonStateModel(
            adapter: ButtonOutputSwiftUIAdapter(),
            loadingAdapter: displayLastAdapter
        ).isLoading)
    }

    func test_fullModel_withoutWidth_preservesUIKitConstraintSemantics() {
        let adapter = ButtonOutputSwiftUIAdapter()
        let sut = SUIButtonStateModel(adapter: adapter)

        adapter.display(model: .init(title: "Initial", width: 180))
        adapter.display(model: .init(title: "Updated"))

        XCTAssertEqual(sut.presentable.title, "Updated")
        XCTAssertEqual(sut.presentable.width, 180)
    }
}
#endif
