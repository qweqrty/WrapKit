#if canImport(SwiftUI)
@testable import WrapKit
import XCTest

final class SUIEmptyViewStateModelTests: XCTestCase {
    func test_premountModelAndIncrementalOutputsHonorFinalWriteInEitherOrder() {
        let modelLastAdapter = EmptyViewOutputSwiftUIAdapter()
        modelLastAdapter.display(title: .text("Old incremental title"))
        modelLastAdapter.display(isHidden: true)
        modelLastAdapter.display(model: .init(title: .text("Latest model title")))

        let incrementalLastAdapter = EmptyViewOutputSwiftUIAdapter()
        incrementalLastAdapter.display(model: .init(title: .text("Old model title")))
        incrementalLastAdapter.display(title: .text("Latest incremental title"))
        incrementalLastAdapter.display(isHidden: true)

        let modelLast = SUIEmptyViewStateModel(adapter: modelLastAdapter)
        let incrementalLast = SUIEmptyViewStateModel(adapter: incrementalLastAdapter)

        XCTAssertEqual(modelLast.title?.plainText, "Latest model title")
        XCTAssertFalse(modelLast.isHidden)
        XCTAssertEqual(incrementalLast.title?.plainText, "Latest incremental title")
        XCTAssertTrue(incrementalLast.isHidden)
    }

    func test_buttonOutput_preservesFullPresentableModel() {
        let adapter = EmptyViewOutputSwiftUIAdapter()
        let sut = SUIEmptyViewStateModel(adapter: adapter)
        let image = ImageFactory.systemImage(named: "star.fill")

        adapter.display(buttonModel: .init(
            accessibilityIdentifier: "empty.action",
            accessibility: .init(label: "Try again", hint: "Retries the request"),
            title: "Retry",
            image: image,
            spacing: 7,
            height: 44,
            width: 180,
            style: .init(backgroundColor: .systemBlue),
            enabled: false,
            onPress: {}
        ))

        XCTAssertEqual(sut.buttonModel?.accessibilityIdentifier, "empty.action")
        XCTAssertEqual(sut.buttonModel?.accessibility?.label, "Try again")
        XCTAssertEqual(sut.buttonModel?.accessibility?.hint, "Retries the request")
        XCTAssertEqual(sut.buttonModel?.title, "Retry")
        XCTAssertNotNil(sut.buttonModel?.image)
        XCTAssertEqual(sut.buttonModel?.spacing, 7)
        XCTAssertEqual(sut.buttonModel?.height, 44)
        XCTAssertEqual(sut.buttonModel?.width, 180)
        XCTAssertNotNil(sut.buttonModel?.style)
        XCTAssertEqual(sut.buttonModel?.enabled, false)
        XCTAssertNotNil(sut.buttonModel?.onPress)
    }

    func test_nilButtonOutput_clearsVisibleModel() {
        let adapter = EmptyViewOutputSwiftUIAdapter()
        let sut = SUIEmptyViewStateModel(adapter: adapter)
        adapter.display(buttonModel: .init(title: "Retry"))

        adapter.display(buttonModel: nil)

        XCTAssertNil(sut.buttonModel)
        XCTAssertTrue(sut.isButtonHidden)
    }

    func test_incrementalButtonModel_preservesUIKitLayoutAndEnabledState() {
        let adapter = EmptyViewOutputSwiftUIAdapter()
        let sut = SUIEmptyViewStateModel(adapter: adapter)

        adapter.display(buttonModel: .init(
            title: "Initial",
            height: 44,
            width: 180,
            style: .init(backgroundColor: .systemBlue),
            enabled: false
        ))
        adapter.display(buttonModel: .init(title: "Updated"))

        XCTAssertEqual(sut.buttonModel?.title, "Updated")
        XCTAssertEqual(sut.buttonModel?.height, 44)
        XCTAssertEqual(sut.buttonModel?.width, 180)
        XCTAssertNotNil(sut.buttonModel?.style)
        XCTAssertEqual(sut.buttonModel?.enabled, false)
    }

    func test_uiKitEmptyView_usesCenteredDefaultLabelsAndFullButtonSemantics() {
        let sut = EmptyView()
        let image = ImageFactory.systemImage(named: "star.fill")

        sut.display(buttonModel: .init(
            accessibilityIdentifier: "empty.action",
            accessibility: .init(label: "Try again", hint: "Retries the request"),
            title: "Retry",
            image: image,
            height: 44,
            enabled: false,
            onPress: {}
        ))

        XCTAssertEqual(sut.titleLabel.textAlignment, .center)
        XCTAssertEqual(sut.subTitleLabel.textAlignment, .center)
        XCTAssertFalse(sut.button.isEnabled)
        XCTAssertNotNil(sut.button.image(for: .normal))
        XCTAssertEqual(sut.button.accessibilityIdentifier, "empty.action")
        XCTAssertEqual(sut.button.accessibilityLabel, "Try again")
        XCTAssertEqual(sut.button.accessibilityHint, "Retries the request")
        XCTAssertEqual(
            sut.button.constraints.first(where: { $0.firstAttribute == .height })?.constant,
            44
        )
    }
}

private extension TextOutputPresentableModel {
    var plainText: String? {
        guard case let .text(value) = model else { return nil }
        return value
    }
}
#endif
