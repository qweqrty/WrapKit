import Foundation

#if canImport(SwiftUI)
import Combine
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

final class SUIToastViewStateModel: ObservableObject {
    struct ToastItem: Identifiable {
        let id = UUID()
        let position: CommonToast.Position
        let duration: TimeInterval?
        let shadowColor: Color?
    }

    @Published var currentItem: ToastItem?
    @Published var dragOffset: CGSize = .zero
    @Published var keyboardHeight: CGFloat = 0
    @Published var opacity: Double = 1
    @Published var scale: CGFloat = 1
    @Published private(set) var currentCardModel: CardViewPresentableModel?

    let cardAdapter = CardViewOutputSwiftUIAdapter()

    private enum DragDirection {
        case horizontal
        case vertical
    }

    private var queue: [CommonToast] = []
    private var cancellables: Set<AnyCancellable> = []
    private var hideWorkItem: DispatchWorkItem?
    private var remainingTime: TimeInterval?
    private var scheduledAt: Date?
    private var gestureDirection: DragDirection?
    private var isHoldingForA11y = false
    private let velocityThreshold: CGFloat = 500
    private var estimatedToastWidth: CGFloat {
        #if canImport(UIKit)
        return max(UIScreen.main.bounds.width - 16, 1)
        #else
        return 320
        #endif
    }
    private let estimatedToastHeight: CGFloat = 52

    init(adapter: CommonToastOutputSwiftUIAdapter) {
        adapter.$displayToastState
            .sink { [weak self] state in
                guard let toast = state?.toast else { return }
                self?.enqueue(toast)
            }
            .store(in: &cancellables)

        adapter.$hideState
            .sink { [weak self] state in
                guard state != nil else { return }
                self?.dismissCurrent()
            }
            .store(in: &cancellables)

        observeKeyboard()
        observeApplicationLifecycle()
        observeAccessibility()
    }

    func pauseTimer() {
        guard hideWorkItem != nil, let scheduledAt, let remainingTime else { return }
        let elapsed = Date().timeIntervalSince(scheduledAt)
        self.remainingTime = max(remainingTime - elapsed, 0)
        hideWorkItem?.cancel()
        hideWorkItem = nil
        self.scheduledAt = nil
    }

    func resumeTimer() {
        scheduleHide(after: remainingTime)
    }

    func beginLongPress() {
        pauseTimer()
        withAnimation(.easeInOut(duration: 0.2)) {
            scale = 1.05
            opacity = 1
        }
    }

    func endLongPress() {
        resumeTimer()
        withAnimation(.easeInOut(duration: 0.2)) {
            scale = 1
        }
    }

    func displayCurrentCardModel() {
        guard let currentCardModel else { return }
        cardAdapter.display(model: currentCardModel)
    }

    func updateDrag(_ translation: CGSize) {
        guard let currentItem else { return }

        if gestureDirection == nil {
            gestureDirection = abs(translation.width) > abs(translation.height) ? .horizontal : .vertical
        }

        switch gestureDirection {
        case .horizontal:
            dragOffset = CGSize(width: translation.width, height: 0)
            opacity = Double(max(CGFloat(1) - abs(translation.width) / estimatedToastWidth, 0))
        case .vertical:
            switch currentItem.position {
            case .top where translation.height > 0:
                return
            case .bottom where translation.height < 0:
                return
            default:
                dragOffset = CGSize(width: 0, height: translation.height)
                opacity = Double(max(CGFloat(1) - abs(translation.height) / estimatedToastHeight, 0))
            }
        case .none:
            break
        }
    }

    func finishDrag(_ translation: CGSize, velocity: CGSize) {
        guard let currentItem else { return }

        let shouldDismiss: Bool
        switch gestureDirection {
        case .horizontal:
            shouldDismiss = abs(translation.width) > estimatedToastWidth / 3 || abs(velocity.width) > velocityThreshold
        case .vertical:
            let positionDismiss: Bool
            switch currentItem.position {
            case .top:
                positionDismiss = abs(translation.height) > estimatedToastHeight / 3 && translation.height < 0
            case .bottom:
                positionDismiss = translation.height > estimatedToastHeight / 3
            }
            shouldDismiss = positionDismiss || abs(velocity.height) > velocityThreshold
        case .none:
            shouldDismiss = false
        }

        gestureDirection = nil

        if shouldDismiss {
            dismissCurrent()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                dragOffset = .zero
                opacity = 1
                scale = 1
            }
            resumeTimer()
        }
    }

    func dismissCurrent() {
        hideWorkItem?.cancel()
        remainingTime = nil
        scheduledAt = nil
        gestureDirection = nil
        isHoldingForA11y = false

        withAnimation(.easeInOut(duration: 0.15)) {
            currentItem = nil
            dragOffset = .zero
            opacity = 0
            scale = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.opacity = 1
            self?.showNextToastIfNeeded()
        }
    }

    private func enqueue(_ toast: CommonToast) {
        queue.append(toast)
        showNextToastIfNeeded()
    }

    private func showNextToastIfNeeded() {
        guard currentItem == nil, !queue.isEmpty else { return }

        let toast = queue.removeFirst()
        configureCard(for: toast)

        let item = ToastItem(
            position: toast.position,
            duration: toast.duration,
            shadowColor: toast.shadowColor
        )

        remainingTime = item.duration
        resetInteractionState()

        withAnimation(.easeInOut(duration: 0.15)) {
            currentItem = item
            opacity = 1
        }

        scheduleHide(after: item.duration)
        postVoiceOverScreenChanged()
    }

    private func scheduleHide(after duration: TimeInterval?) {
        hideWorkItem?.cancel()
        guard let duration else { return }

        let workItem = DispatchWorkItem { [weak self] in
            self?.dismissCurrent()
        }
        hideWorkItem = workItem
        remainingTime = duration
        scheduledAt = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    private func configureCard(for toast: CommonToast) {
        switch toast {
        case .error(let model), .success(let model), .warning(let model):
            configureToast(model)
        case .custom(let model):
            configureCustomToast(model)
        }
    }

    private func configureToast(_ toast: CommonToast.Toast) {
        var model = toast.cardViewModel
        model.leadingImage = .init(
            size: .init(width: 32, height: 32),
            image: .asset(toastIconImage())
        )
        currentCardModel = model
        cardAdapter.display(model: model)
    }

    private func configureCustomToast(_ toast: CommonToast.CustomToast) {
        var model = toast.common.cardViewModel

        if let image = toast.image {
            model.leadingImage = .init(
                size: .init(width: 32, height: 32),
                image: image
            )
        }

        if let backgroundColor = toast.backgroundColor {
            model.style?.backgroundColor = backgroundColor
        }

        currentCardModel = model
        cardAdapter.display(model: model)
    }

    private func resetInteractionState() {
        dragOffset = .zero
        opacity = 1
        scale = 1
        gestureDirection = nil
    }

    private func observeKeyboard() {
        #if canImport(UIKit)
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map(\.height)
            .sink { [weak self] height in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.keyboardHeight = height
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.keyboardHeight = 0
                }
            }
            .store(in: &cancellables)
        #endif
    }

    private func observeApplicationLifecycle() {
        #if canImport(UIKit)
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.pauseTimer()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.resumeTimer()
            }
            .store(in: &cancellables)
        #endif
    }

    private func observeAccessibility() {
        #if canImport(UIKit)
        NotificationCenter.default.publisher(for: UIAccessibility.announcementDidFinishNotification)
            .sink { [weak self] _ in
                self?.releaseA11yHold()
            }
            .store(in: &cancellables)
        #endif
    }

    private func postVoiceOverScreenChanged() {
        #if canImport(UIKit)
        guard UIAccessibility.isVoiceOverRunning else { return }
        holdForA11y()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            UIAccessibility.post(notification: .screenChanged, argument: nil)
        }
        #endif
    }

    private func holdForA11y() {
        guard !isHoldingForA11y else { return }
        isHoldingForA11y = true
        pauseTimer()
    }

    private func releaseA11yHold() {
        guard isHoldingForA11y else { return }
        isHoldingForA11y = false
        resumeTimer()
    }

    private func toastIconImage() -> Image? {
        ImageFactory.systemImage(named: "checkmark.circle.fill")
    }
}

private extension CommonToast {
    var position: CommonToast.Position {
        switch self {
        case .error(let toast), .success(let toast), .warning(let toast):
            return toast.position
        case .custom(let toast):
            return toast.common.position
        }
    }

    var shadowColor: Color? {
        switch self {
        case .error(let toast), .success(let toast), .warning(let toast):
            return toast.shadowColor
        case .custom(let toast):
            return toast.common.shadowColor
        }
    }
}

#endif
