//
//  TooltipView.swift
//  WrapKit
//
//  Created by Stanislav Li on 21/4/26.
//

import Foundation

public protocol TooltipViewOutput: AnyObject {
    func display(tooltipModel: TooltipViewPresentableModel?)
}

public struct TooltipViewPresentableModel {
    public enum Trigger: HashableWithReflection {
        case immediate(anchorPoint: CGPoint? = nil)
        case tap
        case longPress(minimumPressDuration: TimeInterval = 0.5)
    }

    public struct Item {
        public let title: String
        public let onTap: () -> Void

        public init(title: String, onTap: @escaping () -> Void) {
            self.title = title
            self.onTap = onTap
        }
    }

    public let items: [Item]
    public let trigger: Trigger
    public let onDismiss: (() -> Void)?

    public init(
        items: [Item],
        trigger: Trigger = .longPress(),
        onDismiss: (() -> Void)? = nil
    ) {
        self.items = items
        self.trigger = trigger
        self.onDismiss = onDismiss
    }
}

#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
import UIKit
import ObjectiveC

private var tooltipCoordinatorKey: UInt8 = 0

extension UIView: TooltipViewOutput {
    public func display(tooltipModel: TooltipViewPresentableModel?) {
        if let coordinator = objc_getAssociatedObject(self, &tooltipCoordinatorKey) as? TooltipCoordinator {
            coordinator.display(tooltipModel: tooltipModel)
            return
        }
        guard tooltipModel != nil else { return }
        let coordinator = TooltipCoordinator(anchor: self)
        objc_setAssociatedObject(self, &tooltipCoordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        coordinator.display(tooltipModel: tooltipModel)
    }

    func presentPendingTooltipIfNeeded() {
        (objc_getAssociatedObject(self, &tooltipCoordinatorKey) as? TooltipCoordinator)?.presentPendingTooltipIfNeeded()
    }
}

protocol TooltipLegacyMenuOwner: AnyObject {
    func tooltipLegacyMenuWasReplaced()
}

final class TooltipLegacyMenuOwnership {
    private weak var owner: TooltipLegacyMenuOwner?

    func claim(_ newOwner: TooltipLegacyMenuOwner) {
        guard owner !== newOwner else { return }
        let previousOwner = owner
        owner = newOwner
        previousOwner?.tooltipLegacyMenuWasReplaced()
    }

    func release(_ currentOwner: TooltipLegacyMenuOwner) {
        guard owner === currentOwner else { return }
        owner = nil
    }
}


private final class TooltipCoordinator: UIResponder {
    private weak var anchor: UIView?
    private var window: UIWindow? { anchor?.window }
    private var bounds: CGRect { anchor?.bounds ?? .zero }
    override var next: UIResponder? { anchor }
    private var tooltipModel: TooltipViewPresentableModel?
    private var tooltipTapGestureRecognizer: UITapGestureRecognizer?
    private var tooltipLongPressGestureRecognizer: UILongPressGestureRecognizer?
    private var tooltipEditMenuInteraction: NSObject?
    var tooltipEditMenuPresentation: (NSObject, NSString, CGPoint) -> Void = {
        interaction, identifier, point in
        guard #available(iOS 16.0, *),
              let interaction = interaction as? UIEditMenuInteraction else { return }
        let configuration = UIEditMenuConfiguration(
            identifier: identifier,
            sourcePoint: point
        )
        interaction.presentEditMenu(with: configuration)
    }
    private var tooltipDidDismiss: (() -> Void)?
    private var isTooltipItemActionTriggered = false
    private var tooltipMenuDidHideObserver: NSObjectProtocol?
    private var pendingTooltipImmediatePresentation: (identifier: NSString, point: CGPoint?)?
    private(set) var tooltipPresentationIdentifier: NSString?
    private(set) var isTooltipMenuPresented = false
    private static let tooltipLegacyMenuOwnership = TooltipLegacyMenuOwnership()
    private var menuSelectors: [Selector] {
        [
            #selector(handleTooltipAction0),
            #selector(handleTooltipAction1),
            #selector(handleTooltipAction2),
            #selector(handleTooltipAction3),
            #selector(handleTooltipAction4)
        ]
    }

    override var canBecomeFirstResponder: Bool {
        tooltipModel != nil || super.canBecomeFirstResponder
    }

    init(anchor: UIView) {
        self.anchor = anchor
        super.init()
    }

    deinit {
        Self.tooltipLegacyMenuOwnership.release(self)
        if let tooltipMenuDidHideObserver {
            NotificationCenter.default.removeObserver(tooltipMenuDidHideObserver)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let index = menuSelectors.firstIndex(of: action) {
            return (tooltipModel?.items.count ?? 0) > index
        }
        return super.canPerformAction(action, withSender: sender)
    }

    @objc private func handleTooltipAction0() { handleTooltipAction(at: 0) }
    @objc private func handleTooltipAction1() { handleTooltipAction(at: 1) }
    @objc private func handleTooltipAction2() { handleTooltipAction(at: 2) }
    @objc private func handleTooltipAction3() { handleTooltipAction(at: 3) }
    @objc private func handleTooltipAction4() { handleTooltipAction(at: 4) }

    private func handleTooltipAction(at index: Int) {
        guard let items = tooltipModel?.items, items.indices.contains(index) else { return }
        let item = items[index]
        isTooltipItemActionTriggered = true
        item.onTap()
    }

    @objc private func handleTooltipTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }
        showTooltip(at: gestureRecognizer.location(in: anchor))
    }

    @objc private func handleTooltipLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        showTooltip(at: gestureRecognizer.location(in: anchor))
    }

    private func showTooltip(at point: CGPoint? = nil) {
        guard let anchor, let model = tooltipModel,
              !model.items.isEmpty,
              let tooltipPresentationIdentifier,
              window != nil else { return }
        if #available(iOS 16.0, *) {
            let interaction: UIEditMenuInteraction
            if let tooltipEditMenuInteraction = tooltipEditMenuInteraction as? UIEditMenuInteraction {
                interaction = tooltipEditMenuInteraction
            } else {
                let newInteraction = UIEditMenuInteraction(delegate: self)
                anchor.addInteraction(newInteraction)
                tooltipEditMenuInteraction = newInteraction
                interaction = newInteraction
            }
            let anchorPoint = point ?? CGPoint(x: bounds.midX, y: bounds.midY)
            isTooltipMenuPresented = true
            tooltipEditMenuPresentation(
                interaction,
                tooltipPresentationIdentifier,
                anchorPoint
            )
            return
        }
        _ = becomeFirstResponder()
        let menuController = UIMenuController.shared
        let menuItems = makeLegacyTooltipMenuItems()
        guard !menuItems.isEmpty else { return }
        Self.tooltipLegacyMenuOwnership.claim(self)
        menuController.menuItems = menuItems
        let anchorPoint = point ?? CGPoint(x: bounds.midX, y: bounds.midY)
        isTooltipMenuPresented = true
        registerTooltipMenuObserver(for: tooltipPresentationIdentifier)
        menuController.showMenu(from: anchor, rect: CGRect(origin: anchorPoint, size: .zero))
    }

    func presentPendingTooltipIfNeeded(identifier: NSString? = nil) {
        guard let pendingTooltipImmediatePresentation,
              identifier == nil || pendingTooltipImmediatePresentation.identifier == identifier,
              pendingTooltipImmediatePresentation.identifier == tooltipPresentationIdentifier,
              window != nil else { return }
        self.pendingTooltipImmediatePresentation = nil
        showTooltip(at: pendingTooltipImmediatePresentation.point)
    }

    func makeLegacyTooltipMenuItems() -> [UIMenuItem] {
        guard let model = tooltipModel else { return [] }
        return model.items.enumerated().compactMap { index, item -> UIMenuItem? in
            guard index < menuSelectors.count else { return nil }
            return UIMenuItem(title: item.title, action: menuSelectors[index])
        }
    }

    private func registerTooltipMenuObserver(for identifier: NSString) {
        unregisterTooltipMenuObserver()
        tooltipMenuDidHideObserver = NotificationCenter.default.addObserver(
            forName: UIMenuController.didHideMenuNotification,
            object: UIMenuController.shared,
            queue: .main
        ) { [weak self] _ in
            guard let self,
                  self.isTooltipMenuPresented,
                  self.tooltipPresentationIdentifier == identifier else { return }
            self.isTooltipMenuPresented = false
            Self.tooltipLegacyMenuOwnership.release(self)
            self.unregisterTooltipMenuObserver()
            self.handleTooltipDidDismiss()
        }
    }

    private func unregisterTooltipMenuObserver() {
        if let tooltipMenuDidHideObserver {
            NotificationCenter.default.removeObserver(tooltipMenuDidHideObserver)
            self.tooltipMenuDidHideObserver = nil
        }
    }

    private func handleTooltipDidDismiss() {
        if isTooltipItemActionTriggered {
            isTooltipItemActionTriggered = false
            return
        }
        tooltipDidDismiss?()
    }

    private func dismissTooltipMenuWithoutCallback() {
        guard isTooltipMenuPresented else {
            unregisterTooltipMenuObserver()
            return
        }
        isTooltipMenuPresented = false
        Self.tooltipLegacyMenuOwnership.release(self)
        unregisterTooltipMenuObserver()
        if #available(iOS 16.0, *) {
            (tooltipEditMenuInteraction as? UIEditMenuInteraction)?.dismissMenu()
        } else {
            UIMenuController.shared.hideMenu()
        }
    }

    private func removeTooltipGestures() {
        if let tapGesture = tooltipTapGestureRecognizer {
            anchor?.removeGestureRecognizer(tapGesture)
        }
        if let longPressGesture = tooltipLongPressGestureRecognizer {
            anchor?.removeGestureRecognizer(longPressGesture)
        }
        tooltipTapGestureRecognizer = nil
        tooltipLongPressGestureRecognizer = nil
    }
}

extension TooltipCoordinator: TooltipLegacyMenuOwner {
    func tooltipLegacyMenuWasReplaced() {
        guard isTooltipMenuPresented else { return }
        isTooltipMenuPresented = false
        unregisterTooltipMenuObserver()
        UIMenuController.shared.hideMenu()
        handleTooltipDidDismiss()
    }
}

extension TooltipCoordinator: TooltipViewOutput {
    func display(tooltipModel: TooltipViewPresentableModel?) {
        removeTooltipGestures()
        dismissTooltipMenuWithoutCallback()
        pendingTooltipImmediatePresentation = nil
        tooltipPresentationIdentifier = nil
        tooltipDidDismiss = nil
        isTooltipItemActionTriggered = false

        guard let tooltipModel else {
            self.tooltipModel = nil
            return
        }

        anchor?.isUserInteractionEnabled = true
        let tooltipPresentationIdentifier = UUID().uuidString as NSString
        self.tooltipModel = tooltipModel
        tooltipDidDismiss = tooltipModel.onDismiss
        self.tooltipPresentationIdentifier = tooltipPresentationIdentifier

        switch tooltipModel.trigger {
        case .immediate(let anchorPoint):
            pendingTooltipImmediatePresentation = (
                identifier: tooltipPresentationIdentifier,
                point: anchorPoint
            )
            DispatchQueue.main.async { [weak self] in
                self?.presentPendingTooltipIfNeeded(identifier: tooltipPresentationIdentifier)
            }
        case .tap:
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTooltipTap(_:)))
            anchor?.addGestureRecognizer(tapGesture)
            tooltipTapGestureRecognizer = tapGesture
        case .longPress(let minimumPressDuration):
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTooltipLongPress(_:)))
            longPressGesture.minimumPressDuration = minimumPressDuration
            anchor?.addGestureRecognizer(longPressGesture)
            tooltipLongPressGestureRecognizer = longPressGesture
        }
    }
}

@available(iOS 16.0, *)
extension TooltipCoordinator: UIEditMenuInteractionDelegate {
    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        guard configuration.identifier as? NSString == tooltipPresentationIdentifier,
              let tooltipModel,
              !tooltipModel.items.isEmpty else { return nil }
        let menuItems = tooltipModel.items.map { item in
            UIAction(title: item.title) { [weak self] _ in
                guard let self else { return }
                self.isTooltipItemActionTriggered = true
                item.onTap()
            }
        }
        return UIMenu(children: menuItems)
    }

    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        willDismissMenuFor configuration: UIEditMenuConfiguration,
        animator: UIEditMenuInteractionAnimating?
    ) {
        guard isTooltipMenuPresented,
              configuration.identifier as? NSString == tooltipPresentationIdentifier else { return }
        isTooltipMenuPresented = false
        handleTooltipDidDismiss()
    }
}


#endif
