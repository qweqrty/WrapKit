#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import UIKit
import XCTest

final class SUISwitchControlStateModelTests: XCTestCase {
    func test_premountFullModelAndGranularOutputsHonorFinalWriteInEitherOrder() {
        var modelLastCallback = ""
        let modelLastAdapter = SwitchCotrolOutputSwiftUIAdapter()
        modelLastAdapter.display(isOn: false)
        modelLastAdapter.display(isEnabled: true)
        modelLastAdapter.display(style: oldStyle)
        modelLastAdapter.display(onPress: { _ in modelLastCallback = "old granular" })
        modelLastAdapter.display(isHidden: true)
        modelLastAdapter.display(model: .init(
            accessibilityIdentifier: "latest.model",
            onPress: { _ in modelLastCallback = "latest model" },
            isOn: true,
            isEnabled: false,
            style: latestStyle
        ))

        var granularLastCallback = ""
        let granularLastAdapter = SwitchCotrolOutputSwiftUIAdapter()
        granularLastAdapter.display(model: .init(
            accessibilityIdentifier: "old.model",
            onPress: { _ in granularLastCallback = "old model" },
            isOn: false,
            isEnabled: true,
            style: oldStyle
        ))
        granularLastAdapter.display(isOn: true)
        granularLastAdapter.display(isEnabled: false)
        granularLastAdapter.display(style: latestStyle)
        granularLastAdapter.display(onPress: { _ in granularLastCallback = "latest granular" })
        granularLastAdapter.display(isHidden: true)

        let modelLast = SUISwitchControlStateModel(adapter: modelLastAdapter)
        let granularLast = SUISwitchControlStateModel(adapter: granularLastAdapter)
        modelLast.onPress?(modelLastAdapter)
        granularLast.onPress?(granularLastAdapter)

        XCTAssertTrue(modelLast.isOn)
        XCTAssertFalse(modelLast.isEnabled)
        XCTAssertFalse(modelLast.isHidden)
        XCTAssertEqual(modelLast.style?.cornerRadius, latestStyle.cornerRadius)
        XCTAssertEqual(modelLast.accessibilityIdentifier, "latest.model")
        XCTAssertEqual(modelLastCallback, "latest model")
        XCTAssertTrue(granularLast.isOn)
        XCTAssertFalse(granularLast.isEnabled)
        XCTAssertTrue(granularLast.isHidden)
        XCTAssertEqual(granularLast.style?.cornerRadius, latestStyle.cornerRadius)
        XCTAssertEqual(granularLastCallback, "latest granular")
    }

    func test_premountNilModelHidesAndClearsActionButPreservesIndependentState() {
        var didPress = false
        let adapter = SwitchCotrolOutputSwiftUIAdapter()
        adapter.display(isOn: true)
        adapter.display(isEnabled: false)
        adapter.display(style: latestStyle)
        adapter.display(onPress: { _ in didPress = true })
        adapter.display(isLoading: true)
        adapter.display(model: nil)

        let sut = SUISwitchControlStateModel(adapter: adapter)
        sut.onPress?(adapter)

        XCTAssertTrue(sut.isHidden)
        XCTAssertTrue(sut.isOn)
        XCTAssertFalse(sut.isEnabled)
        XCTAssertEqual(sut.style?.cornerRadius, latestStyle.cornerRadius)
        XCTAssertNil(sut.onPress)
        XCTAssertFalse(didPress)
        XCTAssertTrue(sut.isLoading)
    }

    func test_nonNilModelPreservesNilOptionalFieldsAndReplacesAction() {
        let adapter = SwitchCotrolOutputSwiftUIAdapter()
        let sut = SUISwitchControlStateModel(adapter: adapter)
        adapter.display(model: .init(
            accessibilityIdentifier: "retained.id",
            onPress: { _ in },
            isOn: true,
            isEnabled: false,
            style: latestStyle
        ))

        adapter.display(model: .init(onPress: nil))

        XCTAssertFalse(sut.isHidden)
        XCTAssertTrue(sut.isOn)
        XCTAssertFalse(sut.isEnabled)
        XCTAssertEqual(sut.style?.cornerRadius, latestStyle.cornerRadius)
        XCTAssertEqual(sut.accessibilityIdentifier, "retained.id")
        XCTAssertNil(sut.onPress)
    }

    func test_nilModelPreservesFullModelStateAndAccessibilityWhileClearingAction() {
        let adapter = SwitchCotrolOutputSwiftUIAdapter()
        let sut = SUISwitchControlStateModel(adapter: adapter)
        adapter.display(model: .init(
            accessibilityIdentifier: "retained.id",
            onPress: { _ in },
            isOn: true,
            isEnabled: false,
            style: latestStyle
        ))

        adapter.display(model: nil)

        XCTAssertTrue(sut.isHidden)
        XCTAssertTrue(sut.isOn)
        XCTAssertFalse(sut.isEnabled)
        XCTAssertEqual(sut.style?.cornerRadius, latestStyle.cornerRadius)
        XCTAssertEqual(sut.accessibilityIdentifier, "retained.id")
        XCTAssertNil(sut.onPress)
    }

    func test_premountGranularNilStyleClearsFullModelStyle() {
        let adapter = SwitchCotrolOutputSwiftUIAdapter()
        adapter.display(model: .init(style: latestStyle))
        adapter.display(style: nil)

        XCTAssertNil(SUISwitchControlStateModel(adapter: adapter).style)
    }

    private var oldStyle: SwitchControlPresentableModel.Style {
        .init(
            tintColor: .systemBlue,
            thumbTintColor: .white,
            backgroundColor: .systemGray,
            cornerRadius: 4
        )
    }

    private var latestStyle: SwitchControlPresentableModel.Style {
        .init(
            tintColor: .systemGreen,
            thumbTintColor: .black,
            backgroundColor: .systemYellow,
            cornerRadius: 9
        )
    }
}
#endif
