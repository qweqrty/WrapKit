//
//  CircularProgressView.swift
//  WrapKit
//
//  Created by Stanislav Li on 11/6/25.
//

import Foundation

#if canImport(UIKit)
import UIKit

class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupProgressLayer()
    }
    
    private func setupProgressLayer() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                        radius: bounds.width / 2,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 1.5 * CGFloat.pi,
                                        clockwise: true)
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.blue.cgColor // Customize as needed
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 4 // Customize thickness
        progressLayer.strokeEnd = 1.0
        layer.addSublayer(progressLayer)
    }
    
    func animateProgress(from: CGFloat, to: CGFloat, duration: TimeInterval, completion: (() -> Void)?) {
        progressLayer.strokeEnd = from
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.add(animation, forKey: "progressAnimation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion?()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - progressLayer.lineWidth / 2
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 1.5 * CGFloat.pi,
                                        clockwise: true)
        progressLayer.path = circularPath.cgPath
    }
}
#endif
