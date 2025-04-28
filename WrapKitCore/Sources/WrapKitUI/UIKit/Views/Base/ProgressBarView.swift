//
//  ProgressBarView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public protocol ProgressBarOutput: AnyObject {
    func display(model: ProgressBarPresentableModel?)
    func display(progress: CGFloat)
    func display(style: ProgressBarStyle?)
    func display(isHidden: Bool)
}

public struct ProgressBarStyle {
    public let backgroundColor: Color?
    public let progressBarColor: Color?
    public let height: CGFloat?
    public let cornerRadius: CGFloat?
    
    public init(
        backgroundColor: Color? = nil,
        progressBarColor: Color? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.progressBarColor = progressBarColor
        self.height = height
        self.cornerRadius = cornerRadius
    }
}

public struct ProgressBarPresentableModel {
    public let progress: CGFloat // 0-100
    public let style: ProgressBarStyle?
    
    public init(progress: CGFloat = 100, style: ProgressBarStyle?) {
        self.progress = progress
        self.style = style
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUI

open class ProgressBarView: UIView {
    public let progressView = ViewUIKit(backgroundColor: .green)
    
    private var progressViewAnchoredConstraints: AnchoredConstraints?
    private var pendingProgressPercentage: CGFloat?
    
    public init() {
        super.init(frame: .zero)
        layer.cornerRadius = 4
        progressView.layer.cornerRadius = 4
        setupSubviews()
        setupConstraints()
    }
    
    public var style: ProgressBarStyle? {
        didSet {
            self.backgroundColor = style?.backgroundColor
            self.progressView.backgroundColor = style?.progressBarColor
            if let progressViewAnchoredConstraints = progressViewAnchoredConstraints, let height = style?.height {
                progressViewAnchoredConstraints.height?.constant = height
            } else if let height = style?.height {
                progressViewAnchoredConstraints = anchor(.height(height))
            }
            if let cornerRadius = style?.cornerRadius {
                layer.cornerRadius = cornerRadius
                progressView.layer.cornerRadius = cornerRadius
            }
        }
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
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if let percentage = pendingProgressPercentage {
            applyProgress(percentage: percentage, animated: false)
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
            .trailingLessThanEqual(trailingAnchor),
            .bottom(bottomAnchor),
            .height(0),
            .width(0)
        )
    }
}

extension ProgressBarView: ProgressBarOutput {
    public func display(model: ProgressBarPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        if let style = model.style {
            display(style: style)
        }
        applyProgress(percentage: model.progress)
    }
    
    public func display(progress: CGFloat) {
        applyProgress(percentage: progress)
    }
    
    public func display(style: ProgressBarStyle?) {
        self.style = style
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
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
