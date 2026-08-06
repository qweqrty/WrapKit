//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation

#if targetEnvironment(simulator)
#if canImport(UIKit)
import UIKit

public class SimulatedCameraContentView: ViewUIKit {

    lazy var fakeImage = {
        /// Generate a fake image
        let size = CGSize(width: 800, height: 600)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let text = "Simulated Photo"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 36)
            ]
            let textSize = text.size(withAttributes: attributes)
            let textPoint = CGPoint(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2
            )
            text.draw(at: textPoint, withAttributes: attributes)
        }
        return image
    }()

    lazy var previewView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    lazy var shutterButton = Button(style: .init(backgroundColor: .red, cornerRadius: 35))
    lazy var cancelButton = Button(
        style: .init(backgroundColor: .black, titleColor: .white),
        title: "Cancel"
    )
    
    public init() {
        super.init(frame: .zero)
        
        backgroundColor = .black
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SimulatedCameraContentView {
    private func setupView() {
        addSubviews(previewView, shutterButton, cancelButton)
    }
    
    private func setupConstraints() {
        previewView.anchor(
            .top(topAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor),
            .bottom(bottomAnchor, constant: 120)
        )
        
        shutterButton.anchor(
            .centerX(centerXAnchor),
            .height(70),
            .width(70),
            .bottom(bottomAnchor, constant: 44)
        )
        
        cancelButton.anchor(
            .centerY(shutterButton.centerYAnchor),
            .leading(leadingAnchor, constant: 16),
            .height(32)
        )
    }
}
#endif
#endif
