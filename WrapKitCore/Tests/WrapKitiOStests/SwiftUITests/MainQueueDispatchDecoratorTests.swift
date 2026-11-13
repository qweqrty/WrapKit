import Foundation
@testable import WrapKit
import XCTest

final class MainQueueDispatchDecoratorTests: XCTestCase {
    func test_pickerPropertySetters_areDeliveredOnMainQueue() {
        let delivered = expectation(description: "Picker properties delivered")
        delivered.expectedFulfillmentCount = 4
        let spy = PickerViewOutputThreadSpy {
            delivered.fulfill()
        }
        let sut: any PickerViewOutput = spy.mainQueueDispatched

        DispatchQueue.global(qos: .userInitiated).async {
            sut.componentsCount = { 1 }
            sut.rowsCount = { 2 }
            sut.titleForRowAt = { "Row \($0)" }
            sut.didSelectAt = { _ in }
        }

        wait(for: [delivered], timeout: 1)
        XCTAssertEqual(spy.setterWasOnMainThread, [true, true, true, true])
    }

    func test_sharedPropertySetters_areDeliveredOnMainQueue() {
        let delivered = expectation(description: "Shared output properties delivered")
        delivered.expectedFulfillmentCount = 3
        let loadingSpy = LoadingOutputThreadSpy { delivered.fulfill() }
        let lottieSpy = LottieViewOutputThreadSpy { delivered.fulfill() }
        let refreshSpy = RefreshControlOutputThreadSpy { delivered.fulfill() }
        let loading: any LoadingOutput = loadingSpy.mainQueueDispatched
        let lottie: any LottieViewOutput = lottieSpy.mainQueueDispatched
        let refresh: any RefreshControlOutput = refreshSpy.mainQueueDispatched

        DispatchQueue.global(qos: .userInitiated).async {
            loading.isLoading = true
            lottie.currentAnimationName = "CatalogAnimation"
            refresh.onRefresh = []
        }

        wait(for: [delivered], timeout: 1)
        XCTAssertTrue(loadingSpy.setterWasOnMainThread)
        XCTAssertTrue(lottieSpy.setterWasOnMainThread)
        XCTAssertTrue(refreshSpy.setterWasOnMainThread)
    }

    func test_propertyGetter_isReadSynchronouslyOnMainQueue() {
        let delivered = expectation(description: "Property read delivered")
        let spy = PickerViewOutputGetterSpy()
        let sut: any PickerViewOutput = spy.mainQueueDispatched
        var result: Int?

        DispatchQueue.global(qos: .userInitiated).async {
            result = sut.componentsCount?()
            delivered.fulfill()
        }

        wait(for: [delivered], timeout: 1)
        XCTAssertEqual(result, 1)
        XCTAssertTrue(spy.getterWasOnMainThread)
    }
}

private final class PickerViewOutputThreadSpy: PickerViewOutput {
    var componentsCount: (() -> Int?)? {
        didSet { recordSetterThread() }
    }
    var rowsCount: (() -> Int)? {
        didSet { recordSetterThread() }
    }
    var titleForRowAt: ((Int) -> String?)? {
        didSet { recordSetterThread() }
    }
    var didSelectAt: ((Int) -> Void)? {
        didSet { recordSetterThread() }
    }

    private(set) var setterWasOnMainThread: [Bool] = []
    private let onSetter: () -> Void

    init(onSetter: @escaping () -> Void) {
        self.onSetter = onSetter
    }

    func display(model _: PickerViewPresentableModel?) {}

    func display(selectedRow _: PickerViewPresentableModel.SelectedRow?) {}

    private func recordSetterThread() {
        setterWasOnMainThread.append(Thread.isMainThread)
        onSetter()
    }
}

private final class PickerViewOutputGetterSpy: PickerViewOutput {
    var componentsCount: (() -> Int?)? {
        get {
            getterWasOnMainThread = Thread.isMainThread
            return { 1 }
        }
        set { _ = newValue }
    }
    var rowsCount: (() -> Int)?
    var titleForRowAt: ((Int) -> String?)?
    var didSelectAt: ((Int) -> Void)?

    private(set) var getterWasOnMainThread = false

    func display(model _: PickerViewPresentableModel?) {}
    func display(selectedRow _: PickerViewPresentableModel.SelectedRow?) {}
}

private final class LoadingOutputThreadSpy: LoadingOutput {
    var isLoading: Bool? {
        didSet { recordSetterThread() }
    }

    private(set) var setterWasOnMainThread = false
    private let onSetter: () -> Void

    init(onSetter: @escaping () -> Void) {
        self.onSetter = onSetter
    }

    func display(isLoading _: Bool) {}

    private func recordSetterThread() {
        setterWasOnMainThread = Thread.isMainThread
        onSetter()
    }
}

private final class LottieViewOutputThreadSpy: LottieViewOutput {
    var currentAnimationName: String? {
        didSet { recordSetterThread() }
    }

    private(set) var setterWasOnMainThread = false
    private let onSetter: () -> Void

    init(onSetter: @escaping () -> Void) {
        self.onSetter = onSetter
    }

    func display(model _: LottieViewPresentableModel) {}

    private func recordSetterThread() {
        setterWasOnMainThread = Thread.isMainThread
        onSetter()
    }
}

private final class RefreshControlOutputThreadSpy: RefreshControlOutput {
    var onRefresh: [(() -> Void)?]? {
        didSet { recordSetterThread() }
    }

    private(set) var setterWasOnMainThread = false
    private let onSetter: () -> Void

    init(onSetter: @escaping () -> Void) {
        self.onSetter = onSetter
    }

    func display(model _: RefreshControlPresentableModel?) {}
    func display(style _: RefreshControlPresentableModel.Style) {}
    func display(onRefresh _: (() -> Void)?) {}
    func display(appendingOnRefresh _: (() -> Void)?) {}
    func display(isLoading _: Bool) {}

    private func recordSetterThread() {
        setterWasOnMainThread = Thread.isMainThread
        onSetter()
    }
}
