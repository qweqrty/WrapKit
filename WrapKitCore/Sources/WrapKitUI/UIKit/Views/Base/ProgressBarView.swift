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
    public let progressView = UIView()
    
    private var progress: CGFloat = 0
    private var barCornerRadius: CGFloat = 0
    private var heightConstraint: NSLayoutConstraint?
    
    public init(style: ProgressBarStyle? = nil) {
        super.init(frame: .zero)
        addSubview(progressView)
        self.style = style
        applyStyle()
    }
    
    public var style: ProgressBarStyle? {
        didSet {
            applyStyle()
        }
    }
    
    public func applyProgress(percentage: CGFloat, animated: Bool = true) {
        progress = max(0, min(1, percentage / 100))
        setNeedsLayout()
        if animated {
            UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
        } else {
            layoutIfNeeded()
        }
    }
    
    private func applyStyle() {
        backgroundColor = style?.backgroundColor
        progressView.backgroundColor = style?.progressBarColor
        
        barCornerRadius = style?.cornerRadius ?? 0
        layer.cornerRadius = barCornerRadius
        layer.masksToBounds = barCornerRadius > 0
        progressView.layer.cornerRadius = barCornerRadius
        progressView.layer.masksToBounds = barCornerRadius > 0
        
        if let height = style?.height {
            if let heightConstraint { heightConstraint.constant = height }
            else { heightConstraint = heightAnchor.constraint(equalToConstant: height); heightConstraint?.isActive = true }
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: style?.height ?? 4)
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
        progressView.anchor(
            .top(topAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor),
            .bottom(bottomAnchor)
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
        applyProgress(percentage: model.progress, animated: false)
    }
    
    public func display(progress: CGFloat) {
        applyProgress(percentage: progress, animated: true)
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
        let view = ProgressBarView(style: .init(backgroundColor: .lightGray, progressBarColor: .green))
        view.applyProgress(percentage: 40)
        return view
    }
    
    func updateUIView(_ uiView: ProgressBarView, context: Context) {
        
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
