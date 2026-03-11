//
//  View.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import SwiftUI

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

open class ViewUIKit: UIView {
    public enum Animation: HashableWithReflection {
        case gradientBorder([Color])
        case shrink
        case alphaTouch
    }
    
    public var animations: Set<Animation> = [] { didSet { applyAnimations() } }
    private lazy var gradientBorderLayer = makeGradientBorderLayer()
    private var gradientBorderColors: [UIColor] = []
    private var isObservingApplicationLifecycle = false
    private let gradientBorderAnimationKey = "gradientBorderAnimation"

    private func applyAnimations() {
        stopGradientBorderAnimation()
        animations.forEach {
            switch $0 {
            case .gradientBorder(let colors):
                startGradientBorderAnimation(with: colors)
            default:
                break
            }
        }
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
        unregisterFromApplicationLifecycle()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        updateGradientBorderLayerFrame()
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
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
        gradientBorderLayer.cornerRadius = cornerRadius
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
        let shape = CAShapeLayer()
        shape.lineWidth = 4.0
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        return gradient
    }

    private func updateGradientBorderLayerFrame() {
        gradientBorderLayer.frame = CGRect(origin: .zero, size: bounds.size)
        (gradientBorderLayer.mask as? CAShapeLayer)?.path = UIBezierPath(
            roundedRect: CGRect(origin: .zero, size: bounds.size),
            cornerRadius: cornerRadius
        ).cgPath
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

#endif
