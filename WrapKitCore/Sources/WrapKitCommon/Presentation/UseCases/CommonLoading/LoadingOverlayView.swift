//
//  LoadingOverlayView.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 26/3/26.
//

import UIKit

public final class LoadingOverlayView: UIView {
    private let leftInteractiveInset: CGFloat
    private let dimView = UIView()

    init(
        dimColor: UIColor = UIColor.black.withAlphaComponent(0.10),
        leftInteractiveInset: CGFloat = 24
    ) {
        self.leftInteractiveInset = leftInteractiveInset
        super.init(frame: .zero)

        backgroundColor = .clear
        isUserInteractionEnabled = true

        addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = dimColor
        dimView.isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard bounds.contains(point) else { return false }

        ///display(isLoading: Bool) { Левая кромка экрана остается "прозрачной" для swipe back
        if point.x <= leftInteractiveInset {
            return false
        }

        return true
    }
}
