#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)
@testable import WrapKit
import SwiftUI
import UIKit
import XCTest

@MainActor
final class SUIHostingControllerTests: XCTestCase {
    func test_loadingViewUsesClearBackgroundAndInstallsKeyboardDismissalOnce() {
        let sut = SUIHostingController(rootView: Text("Scene"))

        sut.loadViewIfNeeded()
        let gestureCount = sut.view.gestureRecognizers?.count
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.view.backgroundColor, .clear)
        XCTAssertEqual(sut.view.gestureRecognizers?.count, gestureCount)
        XCTAssertTrue(sut.view.gestureRecognizers?.contains { $0 is UITapGestureRecognizer && !$0.cancelsTouchesInView } == true)
    }

    #if !os(tvOS)
    func test_appearanceHidesNativeBarAndRestoresInteractivePopDelegateOnExit() {
        let sut = SUIHostingController(rootView: Text("Scene"))
        let navigation = UINavigationController(rootViewController: sut)
        let delegate = GestureDelegate()
        navigation.loadViewIfNeeded()
        navigation.interactivePopGestureRecognizer?.delegate = delegate

        sut.viewWillAppear(false)

        XCTAssertTrue(navigation.isNavigationBarHidden)
        XCTAssertNil(navigation.interactivePopGestureRecognizer?.delegate)

        sut.viewWillDisappear(false)

        XCTAssertTrue(navigation.isNavigationBarHidden)
        XCTAssertTrue(navigation.interactivePopGestureRecognizer?.delegate === delegate)
    }

    private final class GestureDelegate: NSObject, UIGestureRecognizerDelegate {}
    #endif
}
#endif
