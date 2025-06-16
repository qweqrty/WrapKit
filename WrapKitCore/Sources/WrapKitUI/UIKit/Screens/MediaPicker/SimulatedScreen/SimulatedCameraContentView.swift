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

    var onCapture: ((UIImage) -> Void)?

    lazy var previewView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    lazy var shutterButton = Button(style: .init(backgroundColor: .red, cornerRadius: 35))
    lazy var cancelButton = Button(
        style: .init(backgroundColor: .black, titleColor: .white),
        title: "NurStrings.cancel"
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
            .bottom(bottomAnchor, constant: -120)
        )
        
        shutterButton.anchor(
            .centerX(centerXAnchor),
            .height(70),
            .width(70),
            .bottom(bottomAnchor, constant: -30)
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
