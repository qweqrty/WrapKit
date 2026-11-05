//
//  View.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import SwiftUI
import CoreGraphics

public protocol HiddableOutput: AnyObject {
    func display(isHidden: Bool)
}

public struct LifeCycleView<Content: View>: View {
    private let content: () -> Content
    private let lifeCycleOutput: LifeCycleViewOutput?
    private let applicationLifecycleOutput: ApplicationLifecycleOutput?

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme // For userInterfaceStyle change
    @State private var didAppear = false
    @State private var lastColorScheme: ColorScheme?

    public init(
        lifeCycleOutput: LifeCycleViewOutput? = nil,
        applicationLifecycleOutput: ApplicationLifecycleOutput? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.lifeCycleOutput = lifeCycleOutput
        self.applicationLifecycleOutput = applicationLifecycleOutput
        self.content = content
    }

    public var body: some View {
        content()
            .onAppear {
                lifeCycleOutput?.viewWillAppear()
                if !didAppear {
                    lifeCycleOutput?.viewDidLoad()
                    didAppear = true
                    // Initial check of the color scheme
                    checkColorSchemeChange()
                }
                lifeCycleOutput?.viewDidAppear()
            }
            .onDisappear {
                lifeCycleOutput?.viewWillDisappear()
                lifeCycleOutput?.viewDidDisappear()
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .active:
                    applicationLifecycleOutput?.applicationWillEnterForeground()
                    applicationLifecycleOutput?.applicationDidBecomeActive()
                case .inactive:
                    applicationLifecycleOutput?.applicationWillResignActive()
                case .background:
                    applicationLifecycleOutput?.applicationDidEnterBackground()
                @unknown default:
                    break
                }
            }
            .onChange(of: colorScheme) { _ in
                checkColorSchemeChange()
            }
    }
    
    // MARK: - Color Scheme Check
    private func checkColorSchemeChange() {
        guard let lastColorScheme = lastColorScheme else {
            self.lastColorScheme = colorScheme
            return
        }
        if colorScheme != lastColorScheme {
            let style: UserInterfaceStyle = (colorScheme == .dark) ? .dark : .light
            applicationLifecycleOutput?.applicationDidChange(userInterfaceStyle: style)
            self.lastColorScheme = colorScheme
        }
    }
}

// MARK: - Custom Modifier for Color Scheme Changes
struct ColorSchemeChangeModifier: ViewModifier {
    let colorScheme: ColorScheme
    @Binding var lastColorScheme: ColorScheme?
    let applicationLifecycleOutput: ApplicationLifecycleOutput?
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(ColorSchemePreferenceKey.self) { newColorScheme in
                guard let lastColorScheme = lastColorScheme else {
                    self.lastColorScheme = newColorScheme
                    return
                }
                
                if newColorScheme != lastColorScheme {
                    let style: UserInterfaceStyle = (newColorScheme == .dark) ? .dark : .light
                    applicationLifecycleOutput?.applicationDidChange(userInterfaceStyle: style)
                    self.lastColorScheme = newColorScheme
                }
            }
            .preference(key: ColorSchemePreferenceKey.self, value: colorScheme)
    }
}

// MARK: - Preference Key for Color Scheme
struct ColorSchemePreferenceKey: PreferenceKey {
    static var defaultValue: ColorScheme = .light
    
    static func reduce(value: inout ColorScheme, nextValue: () -> ColorScheme) {
        value = nextValue()
    }
}

#if canImport(UIKit)
import UIKit

extension ViewUIKit: HiddableOutput {
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
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

open class ViewUIKit: UIView {
    public enum Animation: HashableWithReflection {
        case gradientBorder([Color])
        case shrink
        case alphaTouch
        
        var isGradientBorder: Bool {
            return if case .gradientBorder = self { true } else { false }
        }
    }
    
    public var animations: Set<Animation> = [] { didSet { applyAnimations() } }
    private lazy var gradientBorderLayer = makeGradientBorderLayer()
    private var gradientBorderColors: [UIColor] = []
    private var isObservingApplicationLifecycle = false
    private let gradientBorderAnimationKey = "gradientBorderAnimation"
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

    open override var canBecomeFirstResponder: Bool {
        tooltipModel != nil || super.canBecomeFirstResponder
    }
    private let gradientBorderWidth: CGFloat = 2

    private func applyAnimations() {
        if !isContainsGradientBorder {
            stopGradientBorderAnimation()
        }
        animations.forEach {
            switch $0 {
            case .gradientBorder(let colors):
                startGradientBorderAnimation(with: colors)
            default:
                break
            }
        }
    }
    
    private var isContainsGradientBorder: Bool {
        animations.contains(where: \.isGradientBorder)
    }

    public var onPress: (() -> Void)? {
        didSet {
            removeGestureRecognizer(tapGestureRecognizer)
            guard onPress != nil else { return }
            addGestureRecognizer(tapGestureRecognizer)
        }
    }
  
    public var onLongPress: (() -> Void)? {
        didSet {
            removeGestureRecognizer(longPressRecognizer)
            guard onLongPress != nil else { return }
            addGestureRecognizer(longPressRecognizer)
        }
    }

    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()

    lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        recognizer.minimumPressDuration = 1
        return recognizer
    }()

    @objc private func didTap() {
        // Play the animations corresponding to the current set of animations
        animations.forEach { animation in
            switch animation {
            case .shrink:
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction]) { [weak self] in
                    self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                } completion: { [weak self] _ in
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction]) {
                        self?.transform = .identity
                    }
                }
                
            case .alphaTouch:
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction]) { [weak self] in
                    self?.alpha = 0.5
                } completion: { [weak self] _ in
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction]) {
                        self?.alpha = 1.0
                    }
                }
            default:
                break
            }
        }
        onPress?()
    }

    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onLongPress?()
        }
    }
    
    public init(
        backgroundColor: UIColor? = nil,
        isHidden: Bool = false,
        translatesAutoresizingMaskIntoConstraints: Bool = true
    ) {
        super.init(frame: .zero)
        
        self.isHidden = isHidden
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        Self.tooltipLegacyMenuOwnership.release(self)
        if let tooltipMenuDidHideObserver {
            NotificationCenter.default.removeObserver(tooltipMenuDidHideObserver)
        }
        unregisterFromApplicationLifecycle()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if isContainsGradientBorder {
            updateGradientBorderLayerFrame()
        } else {
            stopGradientBorderAnimation()
        }
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            presentPendingTooltipIfNeeded()
        }

        guard !gradientBorderColors.isEmpty else { return }
        if window == nil {
            gradientBorderLayer.removeAnimation(forKey: gradientBorderAnimationKey)
            return
        }
        updateGradientBorderAnimation()
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.animations.forEach {
                switch $0 {
                case .shrink:
                    self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                default:
                    break
                }
            }
        }
        super.touchesBegan(touches, with: event)
        guard onLongPress != nil || onPress != nil || animations.contains(.alphaTouch) else { return }
        self.alpha = 0.5
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        super.touchesEnded(touches, with: event)
        guard onLongPress != nil || onPress != nil || animations.contains(.alphaTouch) else { return }

        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) {
            self.alpha = 1.0
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .allowUserInteraction) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        super.touchesCancelled(touches, with: event)
        guard onLongPress != nil || onPress != nil || animations.contains(.alphaTouch) else { return }

        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) {
            self.alpha = 1.0
        }
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
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
        showTooltip(at: gestureRecognizer.location(in: self))
    }

    @objc private func handleTooltipLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        showTooltip(at: gestureRecognizer.location(in: self))
    }

    private func showTooltip(at point: CGPoint? = nil) {
        guard let model = tooltipModel,
              !model.items.isEmpty,
              let tooltipPresentationIdentifier,
              window != nil else { return }
        if #available(iOS 16.0, *) {
            let interaction: UIEditMenuInteraction
            if let tooltipEditMenuInteraction = tooltipEditMenuInteraction as? UIEditMenuInteraction {
                interaction = tooltipEditMenuInteraction
            } else {
                let newInteraction = UIEditMenuInteraction(delegate: self)
                addInteraction(newInteraction)
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
        menuController.showMenu(from: self, rect: CGRect(origin: anchorPoint, size: .zero))
    }

    private func presentPendingTooltipIfNeeded(identifier: NSString? = nil) {
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
            removeGestureRecognizer(tapGesture)
        }
        if let longPressGesture = tooltipLongPressGestureRecognizer {
            removeGestureRecognizer(longPressGesture)
        }
        tooltipTapGestureRecognizer = nil
        tooltipLongPressGestureRecognizer = nil
    }
}

extension ViewUIKit: TooltipLegacyMenuOwner {
    func tooltipLegacyMenuWasReplaced() {
        guard isTooltipMenuPresented else { return }
        isTooltipMenuPresented = false
        unregisterTooltipMenuObserver()
        UIMenuController.shared.hideMenu()
        handleTooltipDidDismiss()
    }
}

extension ViewUIKit: TooltipViewOutput {
    public func display(tooltipModel: TooltipViewPresentableModel?) {
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
            addGestureRecognizer(tapGesture)
            tooltipTapGestureRecognizer = tapGesture
        case .longPress(let minimumPressDuration):
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTooltipLongPress(_:)))
            longPressGesture.minimumPressDuration = minimumPressDuration
            addGestureRecognizer(longPressGesture)
            tooltipLongPressGestureRecognizer = longPressGesture
        }
    }
}

@available(iOS 16.0, *)
extension ViewUIKit: UIEditMenuInteractionDelegate {
    public func editMenuInteraction(
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

    public func editMenuInteraction(
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

// Animation: Gradient border
extension ViewUIKit {
    private func startGradientBorderAnimation(with colors: [UIColor]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.startGradientBorderAnimation(with: colors)
            }
            return
        }

        guard !colors.isEmpty else {
            stopGradientBorderAnimation()
            return
        }

        gradientBorderColors = colors
        gradientBorderLayer.locations = makeGradientLocations(for: colors.count)
        gradientBorderLayer.colors = colors.map(\.cgColor)
        updateGradientBorderLayerFrame()

        if gradientBorderLayer.superlayer == nil {
            layer.addSublayer(gradientBorderLayer)
        }

        registerForApplicationLifecycleIfNeeded()
        updateGradientBorderAnimation()
    }
    
    private func updateGradientBorderAnimation() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.updateGradientBorderAnimation()
            }
            return
        }

        guard !gradientBorderColors.isEmpty else { return }

        gradientBorderLayer.removeAnimation(forKey: gradientBorderAnimationKey)

        let previousColors = gradientBorderColors.map(\.cgColor)
        let frames = makeGradientAnimationFrames(from: previousColors)
        guard frames.count > 1 else { return }

        gradientBorderLayer.colors = previousColors

        let colorsAnimation = CAKeyframeAnimation(keyPath: "colors")
        colorsAnimation.values = frames
        colorsAnimation.keyTimes = makeGradientAnimationKeyTimes(for: frames.count)
        colorsAnimation.repeatCount = .infinity
        colorsAnimation.duration = 0.3 * Double(max(gradientBorderColors.count, 1))
        colorsAnimation.isRemovedOnCompletion = false
        colorsAnimation.fillMode = .forwards
        colorsAnimation.calculationMode = .linear

        gradientBorderLayer.add(colorsAnimation, forKey: gradientBorderAnimationKey)
        updateGradientBorderLayerFrame()
    }

    private func stopGradientBorderAnimation() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.stopGradientBorderAnimation()
            }
            return
        }

        gradientBorderColors.removeAll()
        gradientBorderLayer.removeAnimation(forKey: gradientBorderAnimationKey)
        gradientBorderLayer.removeFromSuperlayer()
        unregisterFromApplicationLifecycle()
    }
    
    func makeGradientBorderLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.type = .conic
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.mask = makeUniformGradientBorderMask()
        return gradient
    }

    private func updateGradientBorderLayerFrame() {
        gradientBorderLayer.frame = bounds

        let cornerRadii = cornerRadiiValue()
        if cornerRadii.hasDifferentPositiveValues {
            updateAsymmetricGradientBorderMask(cornerRadii: cornerRadii)
        } else {
            updateUniformGradientBorderMask()
        }
    }

    private func makeUniformGradientBorderMask() -> CALayer {
        let mask = CALayer()
        // The mask reads alpha only; CALayer's default border is opaque in every theme.
        mask.borderWidth = gradientBorderWidth
        return mask
    }

    private func updateUniformGradientBorderMask() {
        let mask: CALayer
        if let currentMask = gradientBorderLayer.mask, !(currentMask is CAShapeLayer) {
            mask = currentMask
        } else {
            mask = makeUniformGradientBorderMask()
            gradientBorderLayer.mask = mask
        }

        mask.frame = gradientBorderLayer.bounds
        mask.cornerRadius = cornerRadiusValue()
        mask.cornerCurve = layer.cornerCurve
        mask.maskedCorners = maskedCornersValue()
    }

    private func updateAsymmetricGradientBorderMask(cornerRadii: CornerStyle.Corners) {
        let mask = (gradientBorderLayer.mask as? CAShapeLayer) ?? CAShapeLayer()
        mask.frame = gradientBorderLayer.bounds
        mask.fillColor = nil
        mask.strokeColor = CGColor(gray: 0, alpha: 1)
        mask.lineWidth = gradientBorderWidth
        mask.path = gradientBorderPath(cornerRadii: cornerRadii)
        gradientBorderLayer.mask = mask
    }

    private func gradientBorderPath(cornerRadii: CornerStyle.Corners) -> CGPath {
        let inset = gradientBorderWidth / 2
        let rect = gradientBorderLayer.bounds.insetBy(dx: inset, dy: inset)
        let maximumRadius = max(min(rect.width, rect.height) / 2, .zero)
        let topLeft = min(max(cornerRadii.topLeft - inset, .zero), maximumRadius)
        let topRight = min(max(cornerRadii.topRight - inset, .zero), maximumRadius)
        let bottomLeft = min(max(cornerRadii.bottomLeft - inset, .zero), maximumRadius)
        let bottomRight = min(max(cornerRadii.bottomRight - inset, .zero), maximumRadius)
        let path = UIBezierPath()

        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        if topRight > .zero {
            path.addArc(
                withCenter: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
                radius: topRight,
                startAngle: -.pi / 2,
                endAngle: .zero,
                clockwise: true
            )
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        if bottomRight > .zero {
            path.addArc(
                withCenter: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
                radius: bottomRight,
                startAngle: .zero,
                endAngle: .pi / 2,
                clockwise: true
            )
        }
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        if bottomLeft > .zero {
            path.addArc(
                withCenter: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
                radius: bottomLeft,
                startAngle: .pi / 2,
                endAngle: .pi,
                clockwise: true
            )
        }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        if topLeft > .zero {
            path.addArc(
                withCenter: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
                radius: topLeft,
                startAngle: .pi,
                endAngle: .pi * 1.5,
                clockwise: true
            )
        }
        path.close()
        return path.cgPath
    }

    private func makeGradientLocations(for count: Int) -> [NSNumber] {
        guard count > 1 else { return [0] }
        return (0..<count).map { index in
            NSNumber(value: Double(index) / Double(count - 1))
        }
    }

    private func rotatedCGColors(_ colors: [CGColor]) -> [CGColor] {
        guard colors.count > 1 else { return colors }
        var rotated = colors
        let lastColor = rotated.removeLast()
        rotated.insert(lastColor, at: 0)
        return rotated
    }

    private func makeGradientAnimationFrames(from colors: [CGColor]) -> [[CGColor]] {
        guard !colors.isEmpty else { return [] }

        var frames: [[CGColor]] = [colors]
        var currentColors = colors
        for _ in 0..<max(colors.count, 1) {
            currentColors = rotatedCGColors(currentColors)
            frames.append(currentColors)
        }
        return frames
    }

    private func makeGradientAnimationKeyTimes(for count: Int) -> [NSNumber] {
        guard count > 1 else { return [0] }
        return (0..<count).map { index in
            NSNumber(value: Double(index) / Double(count - 1))
        }
    }

    @objc private func handleAppDidBecomeActive() {
        guard !gradientBorderColors.isEmpty else { return }
        updateGradientBorderAnimation()
    }

    @objc private func handleAppDidEnterBackground() {
        gradientBorderLayer.removeAnimation(forKey: gradientBorderAnimationKey)
    }

    private func registerForApplicationLifecycleIfNeeded() {
        guard !isObservingApplicationLifecycle else { return }
        isObservingApplicationLifecycle = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    private func unregisterFromApplicationLifecycle() {
        guard isObservingApplicationLifecycle else { return }
        isObservingApplicationLifecycle = false
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
}

private extension CornerStyle.Corners {
    var hasDifferentPositiveValues: Bool {
        let values = [topLeft, topRight, bottomLeft, bottomRight].filter { $0 > .zero }
        guard let first = values.first else { return false }
        return values.dropFirst().contains { $0 != first }
    }
}

#endif
