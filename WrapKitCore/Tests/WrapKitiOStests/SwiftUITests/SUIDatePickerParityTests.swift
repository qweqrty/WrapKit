#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import SwiftUI
import UIKit
import XCTest

@MainActor
final class SUIDatePickerParityTests: XCTestCase {
    func test_outputsBeforeStateModelHonorFinalWriteOrderLikeUIKit() {
        let adapter = DatePickerViewOutputSwiftUIAdapter()
        let oldDate = Date(timeIntervalSince1970: 1_700_000_000)
        let latestDate = Date(timeIntervalSince1970: 1_800_000_000)
        var oldCallbackCount = 0
        var latestCallbackCount = 0

        adapter.display(date: oldDate)
        adapter.display(dateChanged: { _ in oldCallbackCount += 1 })
        adapter.display(model: .init(
            value: latestDate,
            minimumDate: nil,
            maximumDate: nil,
            mode: .dateAndTime,
            dateChanged: { _ in latestCallbackCount += 1 }
        ))

        let sut = SUIDatePickerStateModel(adapter: adapter)
        sut.dateChanged?(latestDate)

        XCTAssertEqual(sut.date, latestDate)
        XCTAssertEqual(sut.mode, .dateAndTime)
        XCTAssertEqual(oldCallbackCount, 0)
        XCTAssertEqual(latestCallbackCount, 1)
    }

    func test_uikitAnimatedDateOutput_usesProvidedDate() {
        let sut = DatePickerView()
        let initialDate = Date(timeIntervalSince1970: 1_800_000_000)
        let displayedDate = initialDate.addingTimeInterval(86_400)
        sut.date = initialDate

        sut.display(setDate: displayedDate, animated: false)

        XCTAssertEqual(sut.date, displayedDate)
    }

    func test_countDownTimerMode_usesNativeCountDownPickerAndForwardsChanges() throws {
        let initialDate = Date(timeIntervalSince1970: 1_800_000_000)
        var receivedDate: Date?
        let host = DatePickerTestHost(rootView: SUIDatePickerView(
            date: initialDate,
            mode: .countDownTimer,
            dateChanged: { receivedDate = $0 }
        ))
        let picker = try XCTUnwrap(host.firstSubview(of: UIDatePicker.self))

        XCTAssertEqual(picker.datePickerMode, .countDownTimer)

        let changedDate = initialDate.addingTimeInterval(3_600)
        picker.date = changedDate
        picker.sendActions(for: .valueChanged)

        XCTAssertEqual(receivedDate, picker.date)
    }
}

@MainActor
private final class DatePickerTestHost {
    private let window: UIWindow
    private let hostingController: UIHostingController<AnyView>

    init<Content: View>(rootView: Content) {
        hostingController = UIHostingController(rootView: AnyView(rootView))
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        hostingController.view.frame = window.bounds
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }

    deinit {
        window.isHidden = true
    }

    func firstSubview<ViewType: UIView>(of type: ViewType.Type) -> ViewType? {
        flattenedSubviews(of: hostingController.view).compactMap { $0 as? ViewType }.first
    }

    private func flattenedSubviews(of view: UIView) -> [UIView] {
        [view] + view.subviews.flatMap(flattenedSubviews)
    }
}
#endif
