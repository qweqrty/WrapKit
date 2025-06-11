//
//  CountingLabelAnimation.swift
//  WrapKit
//
//  Created by Бегайым Акунова on 17/4/25.
//

import Foundation

#if canImport(UIKit)
import UIKit

class CountingLabelAnimation {
    private weak var label: Label?
    private var paymentFormat: String = ""
    public var model: TextOutputPresentableModel? // Added to store model
    private var progressView: CircularProgressView? // For circular animation
    
    public required init(label: Label) {
        self.label = label
    }
    
    public var floatLimit: Float? = nil
    
    var startNumber: Float? = 0.0
    var endNumber: Float? = 0.0
    var mapToString: ((Float) -> TextOutputPresentableModel)?
    let counterVelocity: Float = 5
    
    var progress: TimeInterval!
    var duration: TimeInterval = 1
    var lastUpdate: TimeInterval!
    var completion: (() -> Void)? // Added for completion closure
    
    var timer: Timer?
    
    func getCurrentCounterValue() -> TextOutputPresentableModel {
        let startNumber = startNumber ?? 0
        let endNumber = endNumber ?? 0
        if progress >= duration {
            return mapToString?(endNumber) ?? .text("")
        }
        let percentage = Float(progress / duration)
        // Linear interpolation (remove easing for linear animation)
        let currentValue = startNumber + (percentage * (endNumber - startNumber))
        return mapToString?(currentValue) ?? .text("")
    }
    
    func getEndCounterValue() -> TextOutputPresentableModel {
        let endNumber = endNumber ?? 0
        return mapToString?(endNumber) ?? .text("")
    }
    
    public func setupPaymentFormat(format: String) {
        paymentFormat = format
    }
    
    public func startAnimation(
        fromValue: Float,
        to toValue: Float,
        mapToString: ((Float) -> TextOutputPresentableModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        self.startNumber = fromValue
        self.endNumber = toValue
        self.mapToString = mapToString
        self.progress = 0
        self.duration = duration
        self.completion = completion
        self.model = .animated(fromValue, toValue, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion)
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        // Set up circular progress view if needed
        if case .circle(let lineColor) = animationStyle, let label = label {
            progressView = CircularProgressView(lineColor: lineColor, frame: label.bounds.insetBy(dx: -8, dy: -8))
            if let progressView {
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
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(updateValue),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        let timeStep: TimeInterval = 0.01
        progress = min(progress + timeStep, duration)
        lastUpdate = now
        
        if progress >= duration {
            timer?.invalidate()
            timer = nil
            progressView?.removeFromSuperview()
            progressView = nil
            model = nil
            label?.display(model: getEndCounterValue())
            completion?()
            return
        }
        
        label?.display(model: getCurrentCounterValue())
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        progressView?.removeFromSuperview()
    }
}
#endif
