//
//  CountingLabelAnimation.swift
//  WrapKit
//
//  Created by Бегайым Акунова on 17/4/25.
//

import Foundation

#if canImport(UIKit)
import UIKit

final class CountingLabelAnimation {
    private weak var label: Label?
    private var paymentFormat: String = ""
    private var progressView: CircularProgressView?
    private var originalClipsToBounds: Bool?
    
    public required init(label: Label) {
        self.label = label
    }
    
    private var startNumber: Decimal = 0.0
    private var endNumber: Decimal = 0.0
    private var mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?
    private let counterVelocity: Float = 5

    private var duration: TimeInterval = 1
    private var lastUpdate: TimeInterval!
    private var completion: (() -> Void)? // Added for completion closure
    
    private var timer: DisplayLinkManager = .init()
    
    public private(set) var animatedTextMaxWidth: CGFloat?
    
    public func setupPaymentFormat(format: String) {
        paymentFormat = format
    }
    
    public func startAnimation(
        id: String? = nil,
        fromValue: Decimal,
        to toValue: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        self.startNumber = fromValue
        self.endNumber = toValue
        self.mapToString = mapToString
        self.duration = duration
        self.completion = completion
        self.lastUpdate = Date.timeIntervalSinceReferenceDate

        if let label {
            let initialText = mapToString?(fromValue).text ?? fromValue.asString()
            label.display(text: initialText)
        }

        if let label, let mapToString {
            let integerDigits = String(Int(max(fromValue.doubleValue, toValue.doubleValue))).count
            let widestString = String(repeating: "8", count: integerDigits) + ".88"
            let widestNumber = Double(widestString) ?? .zero
                
            animatedTextMaxWidth = max(
                mapToString(fromValue).width(usingFont: label.font),
                mapToString(toValue).width(usingFont: label.font),
                mapToString(Decimal(widestNumber)).width(usingFont: label.font)
            )
            label.invalidateIntrinsicContentSize()
        }

        if case .circle(let lineColor) = animationStyle, let label {
            originalClipsToBounds = label.clipsToBounds
            label.clipsToBounds = false

            let progressView = CircularProgressView(
                lineColor: lineColor,
                frame: label.bounds.insetBy(dx: -8, dy: -8)
            )
            self.progressView = progressView
            label.addSubview(progressView)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                progressView.centerXAnchor.constraint(equalTo: label.centerXAnchor),
                progressView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
                progressView.widthAnchor.constraint(equalTo: label.widthAnchor, constant: 16),
                progressView.heightAnchor.constraint(equalTo: label.heightAnchor, constant: 16)
            ])
            progressView.animateProgress(from: 1.0, to: 0.0, duration: duration, completion: nil)
        }

        timer.startAnimation(duration: duration, onUpdateProgress: { [unowned self] progress in
            let currentValue = self.startNumber + (progress * (self.endNumber - self.startNumber))
            let view = mapToString?(currentValue) ?? .text("")
            self.label?.display(text: view.text)
        }, completion: completion)
    }
    
    func invalidate() {
        timer.stopAnimation()
        progressView?.removeFromSuperview()
    }

    func resetAnimatedTextMaxWidth() {
        animatedTextMaxWidth = nil
        label?.invalidateIntrinsicContentSize()
    }
    
    func cancel() {
        timer.stopAnimation()
        progressView?.removeFromSuperview()
        progressView = nil
        if let originalClipsToBounds {
            label?.clipsToBounds = originalClipsToBounds
            self.originalClipsToBounds = nil
        }
        completion = nil
    }

    deinit { cancel() }
}
#endif
