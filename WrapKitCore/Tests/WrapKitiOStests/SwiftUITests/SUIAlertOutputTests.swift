#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)
@testable import WrapKit
import SwiftUI
import UIKit
import XCTest

@MainActor
final class SUIAlertOutputTests: XCTestCase {
    func test_nilModelsDoNotPresentAnAlert() {
        let adapter = AlertOutputSwiftUIAdapter()
        let host = AlertTestHost(adapter: adapter)

        adapter.showAlert(model: nil)
        adapter.showActionSheet(model: nil)
        adapter.showTextFieldAlert(model: nil)
        host.settle()

        XCTAssertNil(host.alert)
    }

    func test_alertUsesExistingActionStylesAccessibilityIdentifiersAndCancel() throws {
        let adapter = AlertOutputSwiftUIAdapter()
        let host = AlertTestHost(adapter: adapter)

        adapter.showAlert(model: .init(title: "Confirm", text: "Message", actions: [
            .init(accessibilityIdentifier: "confirm_action", title: "Delete", style: .destructive)
        ], cancelText: "Cancel"))
        host.waitForAlert()
        let alert = try XCTUnwrap(host.alert)

        XCTAssertEqual(alert.preferredStyle, .alert)
        XCTAssertEqual(alert.title, "Confirm")
        XCTAssertEqual(alert.message, "Message")
        XCTAssertEqual(alert.actions.first?.style, .destructive)
        XCTAssertEqual(alert.actions.first?.accessibilityIdentifier, "confirm_action")
        XCTAssertEqual(alert.actions.last?.title, "Cancel")
        XCTAssertEqual(alert.actions.last?.style, .cancel)
        XCTAssertNil(adapter.showAlertModelState)
    }

    func test_compactActionSheetPreservesActionsWithoutForcingPopoverAnchor() throws {
        let adapter = AlertOutputSwiftUIAdapter()
        let host = AlertTestHost(adapter: adapter)

        adapter.showActionSheet(model: .init(title: "Format", actions: [
            .init(accessibilityIdentifier: "pdf_action", title: "PDF")
        ], cancelText: "Cancel"))
        host.waitForAlert()
        let alert = try XCTUnwrap(host.alert)

        XCTAssertEqual(alert.preferredStyle, .actionSheet)
        XCTAssertEqual(alert.actions.first?.accessibilityIdentifier, "pdf_action")
        XCTAssertEqual(alert.actions.last?.style, .cancel)
        XCTAssertTrue(host.alertPresentationSource === host.sceneController)
        XCTAssertEqual(host.sceneController.traitCollection.horizontalSizeClass, .compact)
        XCTAssertNil(host.popoverSourceAtPresentation)
        XCTAssertNil(adapter.showActionSheetModelState)
    }

    func test_regularScenePreservesActionSheetAndAnchorsAvailableNativePopover() throws {
        let adapter = AlertOutputSwiftUIAdapter()
        let host = AlertTestHost(
            adapter: adapter,
            size: CGSize(width: 1024, height: 768),
            horizontalSizeClass: .regular
        )

        adapter.showActionSheet(model: .init(title: "Format", actions: [
            .init(accessibilityIdentifier: "pdf_action", title: "PDF")
        ], cancelText: "Cancel"))
        host.waitForAlert()
        let alert = try XCTUnwrap(host.alert)

        XCTAssertEqual(alert.preferredStyle, .actionSheet)
        XCTAssertEqual(alert.actions.first?.accessibilityIdentifier, "pdf_action")
        XCTAssertEqual(alert.actions.last?.style, .cancel)
        XCTAssertEqual(host.sceneController.traitCollection.horizontalSizeClass, .regular)
        XCTAssertTrue(host.alertPresentationSource === host.sceneController)
        // This is an iPhone unit host with a regular trait, not an iPad/Duo runtime.
        // UIKit may adapt and release the popover after present(), so inspect its entry values.
        if host.hasPopoverAtPresentation {
            XCTAssertTrue(host.popoverSourceAtPresentation === host.sceneController.view)
            let sourceRect = try XCTUnwrap(host.popoverSourceRectAtPresentation)
            XCTAssertEqual(sourceRect.midX, host.sceneController.view.bounds.midX)
            XCTAssertEqual(sourceRect.midY, host.sceneController.view.bounds.midY)
        } else {
            XCTAssertNil(host.popoverSourceAtPresentation)
            XCTAssertNil(host.popoverSourceRectAtPresentation)
        }
        XCTAssertNil(adapter.showActionSheetModelState)
    }

    func test_textFieldAlertPreservesPlaceholderAndActionIdentifier() throws {
        let adapter = AlertOutputSwiftUIAdapter()
        let host = AlertTestHost(adapter: adapter)

        adapter.showTextFieldAlert(model: .init(title: "Name", placeholder: "Enter name", actions: [
            .init(accessibilityIdentifier: "save_name", title: "Save", inputHandler: { _ in })
        ], cancelText: "Cancel"))
        host.waitForAlert()
        let alert = try XCTUnwrap(host.alert)

        XCTAssertEqual(alert.textFields?.count, 1)
        XCTAssertEqual(alert.textFields?.first?.placeholder, "Enter name")
        XCTAssertEqual(alert.actions.first?.accessibilityIdentifier, "save_name")
        XCTAssertNil(adapter.showTextFieldAlertModelState)
    }

    func test_alertBeforeFirstAppearanceIsPresentedOnceAndNotReplayedAfterRemount() throws {
        let adapter = AlertOutputSwiftUIAdapter()
        adapter.showAlert(model: .init(title: "Before appearance", actions: [.init(title: "OK")]))
        var host: AlertTestHost? = AlertTestHost(adapter: adapter, showImmediately: false)
        host?.settle()
        XCTAssertNil(host?.alert)

        host?.show()
        host?.waitForAlert()
        XCTAssertEqual(try XCTUnwrap(host?.alert).title, "Before appearance")
        XCTAssertNil(adapter.showAlertModelState)
        host?.dismissAlert()
        host = nil

        let remountedHost = AlertTestHost(adapter: adapter)
        remountedHost.settle()
        XCTAssertNil(remountedHost.alert)
    }

    func test_alertFromCoveredSceneIsNotPresentedOrReplayedWhenReturning() {
        let adapter = AlertOutputSwiftUIAdapter()
        let host = AlertTestHost(adapter: adapter)
        host.navigation.pushViewController(UIViewController(), animated: false)
        host.settle()

        adapter.showAlert(model: .init(title: "Old scene", actions: [.init(title: "OK")]))
        host.settle()
        XCTAssertNil(host.alert)

        host.navigation.popViewController(animated: false)
        host.settle()
        XCTAssertNil(host.alert)
    }

    func test_alertFromModalCallbackWaitsForDismissalAndIsPresentedOnce() throws {
        let adapter = AlertOutputSwiftUIAdapter()
        let host = AlertTestHost(adapter: adapter)
        let modal = UIViewController()
        modal.modalPresentationStyle = .fullScreen
        host.navigation.present(modal, animated: false)
        host.settle()

        // DatePeriodPickerPresenter calls its callback first, then dismisses the picker.
        adapter.showAlert(model: .init(title: "Selected period is too long", actions: [.init(title: "OK")]))
        host.navigation.dismiss(animated: true)
        host.waitForAlert()

        XCTAssertEqual(try XCTUnwrap(host.alert).title, "Selected period is too long")
        XCTAssertNil(adapter.showAlertModelState)
        host.dismissAlert()
        host.settle()
        XCTAssertNil(host.alert)
    }
}

@MainActor
private final class AlertTestHost {
    let navigation: UINavigationController
    private let hosting: AlertHostingController
    private let window: UIWindow
    private weak var previousKeyWindow: UIWindow?

    init(
        adapter: AlertOutputSwiftUIAdapter,
        showImmediately: Bool = true,
        size: CGSize = CGSize(width: 390, height: 844),
        horizontalSizeClass: UIUserInterfaceSizeClass = .compact
    ) {
        // A plain hosting controller proves the modifier is independent of SUIHostingController.
        hosting = AlertHostingController(rootView: AnyView(Text("Scene").alertOutput(adapter: adapter)))
        navigation = UINavigationController(rootViewController: hosting)
        navigation.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: horizontalSizeClass), forChild: hosting)
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        if let scene {
            previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
            window = UIWindow(windowScene: scene)
            window.frame = CGRect(origin: .zero, size: size)
        } else {
            window = UIWindow(frame: CGRect(origin: .zero, size: size))
        }
        window.rootViewController = navigation
        hosting.loadViewIfNeeded()
        hosting.view.frame = window.bounds
        if showImmediately { show() }
    }

    deinit {
        window.isHidden = true
        previousKeyWindow?.makeKeyAndVisible()
    }

    var alert: UIAlertController? {
        findAlert(in: navigation)
    }

    var sceneController: UIViewController { hosting }
    var hasPopoverAtPresentation: Bool { hosting.hasPopoverAtPresentation }
    var popoverSourceAtPresentation: UIView? { hosting.popoverSourceAtPresentation }
    var popoverSourceRectAtPresentation: CGRect? { hosting.popoverSourceRectAtPresentation }

    var alertPresentationSource: UIViewController? {
        guard let alert, hosting.lastPresentedController === alert else { return nil }
        return hosting
    }

    func show() {
        window.makeKeyAndVisible()
        settle()
    }

    func settle() {
        window.layoutIfNeeded()
        hosting.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }

    func waitForAlert() {
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            if let alert, !alert.isBeingPresented, !alert.isBeingDismissed, alert.viewIfLoaded?.window != nil {
                return
            }
            settle()
        }
    }

    func dismissAlert() {
        navigation.dismiss(animated: false)
        settle()
    }

    private func findAlert(in controller: UIViewController) -> UIAlertController? {
        if let alert = controller as? UIAlertController { return alert }
        if let presented = controller.presentedViewController, let alert = findAlert(in: presented) { return alert }
        return controller.children.lazy.compactMap(findAlert).first
    }

    private final class AlertHostingController: UIHostingController<AnyView> {
        private(set) var lastPresentedController: UIViewController?
        private(set) var hasPopoverAtPresentation = false
        private(set) var popoverSourceAtPresentation: UIView?
        private(set) var popoverSourceRectAtPresentation: CGRect?

        override func present(_ controller: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
            lastPresentedController = controller
            let popover = controller.popoverPresentationController
            hasPopoverAtPresentation = popover != nil
            popoverSourceAtPresentation = popover?.sourceView
            popoverSourceRectAtPresentation = popover?.sourceRect
            super.present(controller, animated: animated, completion: completion)
        }
    }
}
#endif
