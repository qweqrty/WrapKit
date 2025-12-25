//
//  CircularProgressView.swift
//  WrapKit
//
//  Created by Stanislav Li on 11/6/25.
//

import Foundation

#if canImport(UIKit)
import UIKit

final class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    
    init(lineColor: UIColor, frame: CGRect) {
        super.init(frame: frame)
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                        radius: bounds.width / 2,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 1.5 * CGFloat.pi,
                                        clockwise: true)
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = lineColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 2 // Customize thickness
        progressLayer.strokeEnd = 1.0
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateProgress(from: CGFloat, to: CGFloat, duration: TimeInterval, completion: (() -> Void)?) {
        progressLayer.strokeStart = from
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.fromValue = to
        animation.toValue = from
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.add(animation, forKey: "\(String(describing: self))progressAnimation")
        
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
