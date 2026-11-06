#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)
import UIKit
import SwiftUI
import Combine

public extension SwiftUI.View {
    /// Presents the existing AlertOutput models from this scene, independently of its hosting controller.
    func alertOutput(adapter: AlertOutputSwiftUIAdapter) -> some SwiftUI.View {
        background(AlertOutputPresenter(adapter: adapter).frame(width: 0, height: 0))
    }
}

private struct AlertOutputPresenter: UIViewControllerRepresentable {
    let adapter: AlertOutputSwiftUIAdapter

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> AlertPresenterViewController {
        let controller = AlertPresenterViewController()
        context.coordinator.connect(adapter: adapter, controller: controller)
        return controller
    }

    func updateUIViewController(_ controller: AlertPresenterViewController, context: Context) {
        context.coordinator.connect(adapter: adapter, controller: controller)
    }

    static func dismantleUIViewController(_ controller: AlertPresenterViewController, coordinator: Coordinator) {
        coordinator.disconnect()
        controller.removePendingPresentation()
    }

    final class Coordinator {
        private var adapter: AlertOutputSwiftUIAdapter?
        private var subscriptions = Set<AnyCancellable>()

        func connect(adapter: AlertOutputSwiftUIAdapter, controller: AlertPresenterViewController) {
            guard self.adapter !== adapter else { return }
            disconnect()
            self.adapter = adapter

            adapter.$showAlertModelState
                .receive(on: RunLoop.main)
                .sink { [weak adapter, weak controller] state in
                    guard let model = state?.model else { return }
                    adapter?.showAlertModelState = nil
                    controller?.showWhenVisible(.alert(model))
                }
                .store(in: &subscriptions)

            adapter.$showActionSheetModelState
                .receive(on: RunLoop.main)
                .sink { [weak adapter, weak controller] state in
                    guard let model = state?.model else { return }
                    adapter?.showActionSheetModelState = nil
                    controller?.showWhenVisible(.actionSheet(model))
                }
                .store(in: &subscriptions)

            adapter.$showTextFieldAlertModelState
                .receive(on: RunLoop.main)
                .sink { [weak adapter, weak controller] state in
                    guard let model = state?.model else { return }
                    adapter?.showTextFieldAlertModelState = nil
                    controller?.showWhenVisible(.textField(model))
                }
                .store(in: &subscriptions)
        }

        func disconnect() {
            subscriptions.removeAll()
            adapter = nil
        }
    }
}

private final class AlertPresenterViewController: UIViewController {
    enum Presentation {
        case alert(AlertPresentableModel)
        case actionSheet(AlertPresentableModel)
        case textField(AlertPresentableModel)
    }

    private var hasAppeared = false
    private var isVisible = false
    private var pendingPresentation: Presentation?

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasAppeared = true
        isVisible = true
        showPendingPresentation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        pendingPresentation = nil
    }

    func showWhenVisible(_ presentation: Presentation) {
        guard isCurrentScene else { return }
        guard hasAppeared else {
            pendingPresentation = presentation
            return
        }
        if let coordinator = modalDismissalCoordinator {
            // A modal can publish an alert from its callback before dismiss(animated:) finishes.
            pendingPresentation = presentation
            coordinator.animate(alongsideTransition: nil) { [weak self] context in
                guard !context.isCancelled else {
                    self?.pendingPresentation = nil
                    return
                }
                // UIKit clears presentedViewController after the transition completion callbacks.
                DispatchQueue.main.async { [weak self] in self?.showPendingPresentation() }
            }
            return
        }
        guard isVisible, viewIfLoaded?.window != nil else { return }

        // Reuse AlertOutput for action styles, accessibility identifiers and handlers.
        switch presentation {
        case let .alert(model): showAlert(model: model)
        case let .actionSheet(model): showActionSheet(model: model)
        case let .textField(model): showTextFieldAlert(model: model)
        }
    }

    func removePendingPresentation() {
        pendingPresentation = nil
        isVisible = false
    }

    private func showPendingPresentation() {
        guard let pendingPresentation else { return }
        self.pendingPresentation = nil
        showWhenVisible(pendingPresentation)
    }

    private var isCurrentScene: Bool {
        let controller = sceneController
        if let navigation = controller.navigationController {
            return navigation.topViewController === controller && !controller.isBeingDismissed
        }
        return !controller.isBeingDismissed
    }

    private var sceneController: UIViewController {
        var controller: UIViewController = self
        while let parent = controller.parent {
            if parent is UINavigationController { break }
            controller = parent
        }
        return controller
    }

    private var modalDismissalCoordinator: UIViewControllerTransitionCoordinator? {
        var controller: UIViewController? = self
        while let current = controller {
            if let presented = current.presentedViewController, presented.isBeingDismissed {
                return presented.transitionCoordinator ?? current.transitionCoordinator
            }
            controller = current.parent
        }
        return nil
    }

    override func present(_ controller: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        // AlertOutput schedules presentation on the run loop; the scene may have left since the request.
        guard isCurrentScene else {
            completion?()
            return
        }
        if let coordinator = modalDismissalCoordinator {
            coordinator.animate(alongsideTransition: nil) { [weak self] context in
                guard !context.isCancelled else {
                    completion?()
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        completion?()
                        return
                    }
                    self.present(controller, animated: animated, completion: completion)
                }
            }
            return
        }
        let scene = sceneController
        guard isVisible, viewIfLoaded?.window != nil, scene.presentedViewController == nil else {
            completion?()
            return
        }
        if scene.traitCollection.horizontalSizeClass == .regular,
           let popover = controller.popoverPresentationController,
           let sourceView = scene.viewIfLoaded {
            popover.sourceView = sourceView
            popover.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        // The representable only transports outputs. The full-size scene owns UIKit presentation.
        scene.present(controller, animated: animated, completion: completion)
    }
}
#endif
