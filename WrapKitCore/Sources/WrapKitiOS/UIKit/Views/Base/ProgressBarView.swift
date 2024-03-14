//
//  ProgressBarView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

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
#endif
