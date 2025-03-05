//
//  View.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import SwiftUI

public struct LifeCycleView<Content: View>: View {
    private let content: () -> Content
    private let lifeCycleInput: LifeCycleViewOutput?
    private let ApplicationLifecycleOutput: ApplicationLifecycleOutput?

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme // For userInterfaceStyle change
    @State private var didAppear = false
    @State private var lastColorScheme: ColorScheme?

    public init(
        lifeCycleInput: LifeCycleViewOutput? = nil,
        ApplicationLifecycleOutput: ApplicationLifecycleOutput? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.lifeCycleInput = lifeCycleInput
        self.ApplicationLifecycleOutput = ApplicationLifecycleOutput
        self.content = content
    }

    public var body: some View {
        content()
            .onAppear {
                lifeCycleInput?.viewWillAppear()
                if !didAppear {
                    lifeCycleInput?.viewDidLoad()
                    didAppear = true
                }
                lifeCycleInput?.viewDidAppear()
            }
            .onDisappear {
                lifeCycleInput?.viewWillDisappear()
                lifeCycleInput?.viewDidDisappear()
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .active:
                    ApplicationLifecycleOutput?.applicationDidBecomeActive()
                case .inactive:
                    ApplicationLifecycleOutput?.applicationWillResignActive()
                case .background:
                    ApplicationLifecycleOutput?.applicationDidEnterBackground()
                @unknown default:
                    break
                }
            }
            .onChange(of: colorScheme) { newColorScheme in
                guard let lastColorScheme = lastColorScheme else {
                    self.lastColorScheme = newColorScheme
                    return
                }
                
                if newColorScheme != lastColorScheme {
                    let style: UserInterfaceStyle = (newColorScheme == .dark) ? .dark : .light
                    ApplicationLifecycleOutput?.applicationDidChange(userInterfaceStyle: style)
                    self.lastColorScheme = newColorScheme
                }
            }
    }
}

#if canImport(UIKit)
import UIKit

open class ViewUIKit: UIView {
    public enum Animation: HashableWithReflection {
        case gradientBorder([Color])
        case shrink
        case alphaTouch
    }
    
    public var animations: Set<Animation> = [] { didSet { applyAnimations() } }
    private lazy var gradientBorderLayer = makeGradientBorderLayer()

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
extension ViewUIKit: CAAnimationDelegate {
    private func startGradientBorderAnimation(with colors: [UIColor]) {
        guard gradientBorderLayer.superlayer == nil else { return }
        gradientBorderLayer.locations = (0..<colors.count).map {
            NSNumber(value: Double($0) / Double(colors.count))
        }
        gradientBorderLayer.colors = colors
        gradientBorderLayer.cornerRadius = cornerRadius
        layer.addSublayer(gradientBorderLayer)
        updateGradientBorderAnimation()
    }
    
    private func updateGradientBorderAnimation() {
        gradientBorderLayer.removeAnimation(forKey: "gradientBorderAnimation")
        
        guard let previousColors = gradientBorderLayer.colors else { return }
        guard var newColors = gradientBorderLayer.colors else { return }
        let lastColor = newColors.removeLast()
        newColors.insert(lastColor, at: 0)
        gradientBorderLayer.colors = newColors
        
        let colorsAnimation = CABasicAnimation(keyPath: "colors")
        colorsAnimation.fromValue = previousColors.map { ($0 as? UIColor)?.cgColor }
        colorsAnimation.toValue = newColors.map { ($0 as? UIColor)?.cgColor }
        colorsAnimation.repeatCount = 1
        colorsAnimation.duration = 0.3
        colorsAnimation.isRemovedOnCompletion = false
        colorsAnimation.fillMode = .both
        colorsAnimation.delegate = self
        
        gradientBorderLayer.add(colorsAnimation, forKey: "gradientBorderAnimation")
        
        gradientBorderLayer.frame = CGRect(
            origin: CGPoint.zero,
            size: CGSize(
                width: frame.width,
                height: frame.height
            )
        )
        (gradientBorderLayer.mask as? CAShapeLayer)?.path = UIBezierPath(
            roundedRect: CGRect(
                x: 0,
                y: 0,
                width: frame.width,
                height: frame.height
            ),
            cornerRadius: cornerRadius
        ).cgPath
    }

    private func stopGradientBorderAnimation() {
        gradientBorderLayer.removeAnimation(forKey: "gradientBorderAnimation")
        gradientBorderLayer.removeFromSuperlayer()
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return }
        updateGradientBorderAnimation()
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
}

#endif
