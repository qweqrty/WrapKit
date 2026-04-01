//
//  NVActivityIndicatorAnimationIndefiniteAnimatedSpin.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 26/3/26.
//

#if canImport(UIKit)
import UIKit

final class NVActivityIndicatorAnimationIndefiniteAnimatedSpin: NVActivityIndicatorAnimationDelegate {

    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let resolvedColor = color.resolvedColor(with: UIScreen.main.traitCollection)

        let strokeThickness: CGFloat = 2.2
        let inset: CGFloat = 1.0
        let radius: CGFloat = min(size.width, size.height) / 2 - strokeThickness / 2 - inset

        guard radius > 0 else { return }

        let arcCenter = CGPoint(
            x: radius + strokeThickness / 2 + inset,
            y: radius + strokeThickness / 2 + inset
        )

        let spinnerSide = arcCenter.x * 2

        // Рисуем не полный круг, а дугу, чтобы не было шва
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + CGFloat.pi * 1.9

        let path = UIBezierPath(
            arcCenter: arcCenter,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.main.scale
        shapeLayer.frame = CGRect(
            x: (layer.bounds.width - spinnerSide) / 2,
            y: (layer.bounds.height - spinnerSide) / 2,
            width: spinnerSide,
            height: spinnerSide
        )
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = resolvedColor.cgColor
        shapeLayer.lineWidth = strokeThickness
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.path = path.cgPath

        let maskLayer = makeCodeAngleMask(frame: shapeLayer.bounds)
        shapeLayer.mask = maskLayer

        layer.addSublayer(shapeLayer)

        let animationDuration: CFTimeInterval = 1.0
        let linearCurve = CAMediaTimingFunction(name: .linear)

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.byValue = CGFloat.pi * 2
        rotationAnimation.duration = animationDuration
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = linearCurve
        rotationAnimation.isAdditive = true
        rotationAnimation.isRemovedOnCompletion = false

        shapeLayer.add(rotationAnimation, forKey: "rotate")
    }

    private func makeCodeAngleMask(frame: CGRect) -> CALayer {
        let container = CALayer()
        container.frame = frame
        container.contentsScale = UIScreen.main.scale

        if #available(iOS 12.0, *) {
            let gradient = CAGradientLayer()
            gradient.type = .conic
            gradient.frame = container.bounds
            gradient.contentsScale = UIScreen.main.scale
            gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)

            gradient.colors = [
                UIColor.white.withAlphaComponent(1.00).cgColor,
                UIColor.white.withAlphaComponent(1.00).cgColor,
                UIColor.white.withAlphaComponent(0.98).cgColor,
                UIColor.white.withAlphaComponent(0.92).cgColor,
                UIColor.white.withAlphaComponent(0.82).cgColor,
                UIColor.white.withAlphaComponent(0.68).cgColor,
                UIColor.white.withAlphaComponent(0.52).cgColor,
                UIColor.white.withAlphaComponent(0.38).cgColor,
                UIColor.white.withAlphaComponent(0.24).cgColor,
                UIColor.white.withAlphaComponent(0.12).cgColor,
                UIColor.white.withAlphaComponent(0.05).cgColor,
                UIColor.clear.cgColor,
                UIColor.clear.cgColor
            ]

            gradient.locations = [
                0.00,
                0.05,
                0.12,
                0.20,
                0.30,
                0.42,
                0.54,
                0.66,
                0.76,
                0.84,
                0.90,
                0.94,
                1.00
            ] as [NSNumber]

            container.addSublayer(gradient)
        } else {
            let fallback = CALayer()
            fallback.frame = container.bounds
            fallback.backgroundColor = UIColor.white.cgColor
            container.addSublayer(fallback)
        }

        return container
    }
}
#endif
