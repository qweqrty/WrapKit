#if canImport(SwiftUI)
@testable import WrapKit
import Combine
import Foundation
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

    func test_repeatedFullModelsBeforeMount_preserveEarlierWidthLikeUIKit() {
        let adapter = ButtonOutputSwiftUIAdapter()
        adapter.display(model: .init(title: "Initial", width: 180))
        adapter.display(model: .init(title: "Updated"))

        let sut = SUIButtonStateModel(adapter: adapter)

        XCTAssertEqual(sut.presentable.title, "Updated")
        XCTAssertEqual(sut.presentable.width, 180)
    }

    func test_remount_replaysCompletePremountHistoryWithoutRetainingFirstStateModel() {
        let adapter = ButtonOutputSwiftUIAdapter()
        adapter.display(model: .init(title: "Initial", width: 180))
        adapter.display(model: .init(title: "Updated"))

        weak var firstStateModel: SUIButtonStateModel?
        autoreleasepool {
            let sut = SUIButtonStateModel(adapter: adapter)
            firstStateModel = sut

            XCTAssertEqual(sut.presentable.title, "Updated")
            XCTAssertEqual(sut.presentable.width, 180)
        }
        XCTAssertNil(firstStateModel)

        let remountedSUT = SUIButtonStateModel(adapter: adapter)

        XCTAssertEqual(remountedSUT.presentable.title, "Updated")
        XCTAssertEqual(remountedSUT.presentable.width, 180)
    }

    func test_outputPublishedAfterUnmountReplaysOnRemount() {
        let adapter = ButtonOutputSwiftUIAdapter()
        weak var firstStateModel: SUIButtonStateModel?

        autoreleasepool {
            let sut = SUIButtonStateModel(adapter: adapter)
            firstStateModel = sut
            adapter.display(title: "First mount")

            XCTAssertEqual(sut.presentable.title, "First mount")
        }
        XCTAssertNil(firstStateModel)

        adapter.display(title: "Published while unmounted")
        let remountedSUT = SUIButtonStateModel(adapter: adapter)

        XCTAssertEqual(remountedSUT.presentable.title, "Published while unmounted")
    }

    func test_replayCheckpoint_doesNotRetainSupersededAction() throws {
        final class ActionOwner {}

        let adapter = ButtonOutputSwiftUIAdapter()
        var calls = 0
        weak var weakOwner: ActionOwner?
        var action: (() -> Void)?
        do {
            let owner = ActionOwner()
            weakOwner = owner
            action = {
                _ = owner
                calls += 1
            }
        }
        adapter.display(model: .init(onPress: action))
        let retainedAction = try XCTUnwrap(adapter.displayModelState?.model?.onPress)

        XCTAssertNotNil(weakOwner)
        retainedAction()
        XCTAssertEqual(calls, 1)

        action = nil
        adapter.display(model: .init(title: "Updated"))

        let sut = SUIButtonStateModel(adapter: adapter)

        XCTAssertNil(weakOwner)
        XCTAssertNil(sut.presentable.onPress)
        retainedAction()
        XCTAssertEqual(calls, 1)
    }

    func test_newMountTakesLeaseAndMakesEarlierStateModelInert() {
        let adapter = ButtonOutputSwiftUIAdapter()
        let firstStateModel = SUIButtonStateModel(adapter: adapter)
        adapter.display(title: "First owner")

        let secondStateModel = SUIButtonStateModel(adapter: adapter)
        adapter.display(title: "Second owner")

        XCTAssertEqual(firstStateModel.presentable.title, "First owner")
        XCTAssertEqual(secondStateModel.presentable.title, "Second owner")
    }

    func test_mountDoesNotClearLastPublishedOutputState() {
        let adapter = ButtonOutputSwiftUIAdapter()
        adapter.display(title: "Last public output")

        _ = SUIButtonStateModel(adapter: adapter)

        XCTAssertEqual(adapter.displayTitleState?.title, "Last public output")
    }

    func test_mountReplaysInitialOutputWithoutRepublishingAdapterState() {
        let adapter = ButtonOutputSwiftUIAdapter()
        var publishedTitles: [String] = []
        var objectWillChangeCount = 0
        let titleCancellable = adapter.$displayTitleState
            .dropFirst()
            .compactMap { $0?.title }
            .sink { publishedTitles.append($0) }
        let objectWillChangeCancellable = adapter.objectWillChange
            .sink { objectWillChangeCount += 1 }

        adapter.display(title: "Initial output")
        let outputObjectWillChangeCount = objectWillChangeCount

        let sut = SUIButtonStateModel(adapter: adapter)

        XCTAssertEqual(sut.presentable.title, "Initial output")
        XCTAssertEqual(publishedTitles, ["Initial output"])
        XCTAssertGreaterThan(outputObjectWillChangeCount, 0)
        XCTAssertEqual(objectWillChangeCount, outputObjectWillChangeCount)
        withExtendedLifetime((titleCancellable, objectWillChangeCancellable)) {}
    }

    func test_replayInfrastructure_doesNotRetainActionSupersededByGranularOutput() throws {
        final class ActionOwner {}

        let adapter = ButtonOutputSwiftUIAdapter()
        var calls = 0
        weak var weakOwner: ActionOwner?
        var action: (() -> Void)?
        do {
            let owner = ActionOwner()
            weakOwner = owner
            action = {
                _ = owner
                calls += 1
            }
        }
        adapter.display(model: .init(onPress: action))
        action = nil
        let sut = SUIButtonStateModel(adapter: adapter)
        let retainedAction = try XCTUnwrap(sut.presentable.onPress)

        XCTAssertNotNil(weakOwner)
        retainedAction()
        XCTAssertEqual(calls, 1)

        adapter.display(onPress: nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))

        XCTAssertNil(weakOwner)
        XCTAssertNil(sut.presentable.onPress)
        retainedAction()
        XCTAssertEqual(calls, 1)
    }

    func test_remount_replaysRuntimeFullModelHistoryAfterInitialMount() {
        let adapter = ButtonOutputSwiftUIAdapter()
        var mountedSUT: SUIButtonStateModel? = SUIButtonStateModel(adapter: adapter)

        adapter.display(model: .init(title: "Initial", width: 220))
        adapter.display(model: .init(title: "Runtime updated"))
        XCTAssertEqual(mountedSUT?.presentable.width, 220)

        mountedSUT = nil
        let remountedSUT = SUIButtonStateModel(adapter: adapter)

        XCTAssertEqual(remountedSUT.presentable.title, "Runtime updated")
        XCTAssertEqual(remountedSUT.presentable.width, 220)
    }

    func test_premountHeightAndFullModelHonorFinalWriteInEitherOrder() {
        let modelLastAdapter = ButtonOutputSwiftUIAdapter()
        modelLastAdapter.display(height: 60)
        modelLastAdapter.display(model: .init(height: 100))

        let heightLastAdapter = ButtonOutputSwiftUIAdapter()
        heightLastAdapter.display(model: .init(height: 100))
        heightLastAdapter.display(height: 60)

        XCTAssertEqual(
            SUIButtonStateModel(adapter: modelLastAdapter).presentable.height,
            100
        )
        XCTAssertEqual(
            SUIButtonStateModel(adapter: heightLastAdapter).presentable.height,
            60
        )
    }

    func test_incrementalStyle_preservesFullModelContentAndConfiguration() {
        let adapter = ButtonOutputSwiftUIAdapter()
        let sut = SUIButtonStateModel(adapter: adapter)
        let image = ImageFactory.systemImage(named: "star")

        adapter.display(model: .init(
            title: "BUTTON WITH height",
            image: image,
            spacing: 50,
            height: 100,
            style: .init(backgroundColor: .red)
        ))
        adapter.display(style: .init(backgroundColor: .cyan))

        XCTAssertEqual(sut.presentable.title, "BUTTON WITH height")
        XCTAssertNotNil(sut.presentable.image)
        XCTAssertEqual(sut.presentable.spacing, 50)
        XCTAssertEqual(sut.presentable.height, 100)
        XCTAssertEqual(sut.presentable.style?.backgroundColor, .cyan)
    }
}
#endif
