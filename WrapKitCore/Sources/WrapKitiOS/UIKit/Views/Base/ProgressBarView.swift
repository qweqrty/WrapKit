//
//  ProgressBarView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public protocol ProgressBarOutput: AnyObject {
    func display(model: ProgressBarPresentableModel?)
    func display(color: Color)
    func display(progress: CGFloat)
}

public struct ProgressBarPresentableModel {
    public let color: Color
    public let progress: CGFloat // 0-100
    
    public init(color: Color = .magenta, progress: CGFloat = 100) {
        self.color = color
        self.progress = progress
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUI

open class ProgressBarView: UIView {
    public let progressView = View(backgroundColor: .green)
    
    private var progressViewAnchoredConstraints: AnchoredConstraints?
    
    public init() {
        super.init(frame: .zero)
        layer.cornerRadius = 4
        progressView.layer.cornerRadius = 4
        setupSubviews()
        setupConstraints()
    }
    
    public func applyProgress(width: CGFloat) {
        progressViewAnchoredConstraints?.width?.constant = width
    }
    
    public func applyProgress(percentage: CGFloat, animated: Bool = true) {
        layoutIfNeeded()
        let maxWidth = bounds.width
        let newWidth = maxWidth * (percentage / 100.0)
        progressViewAnchoredConstraints?.width?.constant = newWidth
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProgressBarView {
    func setupSubviews() {
        addSubview(progressView)
    }
    
    func setupConstraints() {
        progressViewAnchoredConstraints = progressView.anchor(
            .top(topAnchor),
            .leading(leadingAnchor),
            .bottom(bottomAnchor),
            .width(0)
        )
    }
}

extension ProgressBarView: ProgressBarOutput {
    public func display(model: ProgressBarPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        progressView.backgroundColor = model.color
        applyProgress(percentage: model.progress)
    }
    
    public func display(color: Color) {
        progressView.backgroundColor = color
    }
    
    public func display(progress: CGFloat) {
        applyProgress(percentage: progress)
    }
}

@available(iOS 13.0, *)
struct ProgressBarViewFullRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ProgressBarView {
        let view = ProgressBarView()
        view.applyProgress(width: 340)
        return view
    }

    func updateUIView(_ uiView: ProgressBarView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        VStack {
            ProgressBarViewFullRepresentable()
                .frame(height: 20)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
        }
    }
}
#endif
