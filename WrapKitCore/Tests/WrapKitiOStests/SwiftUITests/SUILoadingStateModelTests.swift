#if canImport(SwiftUI)
@testable import WrapKit
import XCTest

final class SUILoadingStateModelTests: XCTestCase {
    func test_replaysPropertyConfiguredBeforeSubscription() {
        let adapter = LoadingOutputSwiftUIAdapter()
        adapter.isLoading = true

        let sut = SUILoadingStateModel(adapter: adapter)

        XCTAssertTrue(sut.isLoading)
    }

    func test_displayAndPropertySetterShareTheSameLoadingState() {
        let adapter = LoadingOutputSwiftUIAdapter()
        let sut = SUILoadingStateModel(adapter: adapter)

        adapter.display(isLoading: true)
        XCTAssertTrue(sut.isLoading)

        adapter.isLoading = false
        XCTAssertFalse(sut.isLoading)
    }

    func test_premountLoadingUsesFinalPublicWriteInEitherOrder() {
        let propertyLastAdapter = LoadingOutputSwiftUIAdapter()
        propertyLastAdapter.display(isLoading: true)
        propertyLastAdapter.isLoading = false

        let displayLastAdapter = LoadingOutputSwiftUIAdapter()
        displayLastAdapter.isLoading = false
        displayLastAdapter.display(isLoading: true)

        XCTAssertFalse(SUILoadingStateModel(adapter: propertyLastAdapter).isLoading)
        XCTAssertTrue(SUILoadingStateModel(adapter: displayLastAdapter).isLoading)
    }
}
#endif
