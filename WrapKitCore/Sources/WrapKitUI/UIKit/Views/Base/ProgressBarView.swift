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
    public let cornerStyle: CornerStyle?
    public let trackHeight: CGFloat?
    
    public init(
        backgroundColor: Color? = nil,
        progressBarColor: Color? = nil,
        height: CGFloat? = nil,
        trackHeight: CGFloat? = nil,
        cornerRadius: CGFloat
    ) {
        self.init(
            backgroundColor: backgroundColor,
            progressBarColor: progressBarColor,
            height: height,
            trackHeight: trackHeight,
            cornerStyle: .fixed(cornerRadius)
        )
    }
    
    public init(
        backgroundColor: Color? = nil,
        progressBarColor: Color? = nil,
        height: CGFloat? = nil,
        trackHeight: CGFloat? = nil,
        cornerStyle: CornerStyle? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.progressBarColor = progressBarColor
        self.height = height
        self.trackHeight = trackHeight
        self.cornerStyle = cornerStyle
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

public final class ProgressBarView: UIView {
    public let trackView = UIView()
    public let progressView = UIView()

    private var progress: CGFloat = 0
    private var heightConstraint: NSLayoutConstraint?
    private var trackHeightConstraint: NSLayoutConstraint?

    public init(style: ProgressBarStyle? = nil) {
        super.init(frame: .zero)
        addSubview(trackView)
        addSubview(progressView)
        setupTrackConstraints()
        self.style = style
        applyStyle()
    }

    public var style: ProgressBarStyle? { didSet { applyStyle() } }

    public func applyProgress(percentage: CGFloat, animated: Bool = true) {
        progress = max(0, min(1, percentage / 100))
        setNeedsLayout()
        if animated {
            UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
        } else {
            layoutIfNeeded()
        }
    }

    private func setupTrackConstraints() {
        trackHeightConstraint = trackView.anchor(
            .leading(leadingAnchor),
            .trailing(trailingAnchor),
            .centerY(centerYAnchor),
            .height(0)
        ).height
    }

    private func applyStyle() {
        backgroundColor = .clear
        trackView.backgroundColor = style?.backgroundColor
        progressView.backgroundColor = style?.progressBarColor ?? tintColor

        let fillHeight = style?.height ?? 4
        trackHeightConstraint?.constant = style?.trackHeight ?? (fillHeight - (fillHeight / 3).rounded(.up))

        applyCornerStyles()

        if let height = style?.height {
            if let heightConstraint { heightConstraint.constant = height }
            else { heightConstraint = heightAnchor.constraint(equalToConstant: height); heightConstraint?.isActive = true }
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    private func applyCornerStyles() {
        let cornerStyle = style?.cornerStyle ?? .fixed(4) // was default 4
        trackView.applyCornerStyle(cornerStyle)
        progressView.applyCornerStyle(cornerStyle)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let fillWidth = bounds.width * progress
        progressView.isHidden = fillWidth <= 0
        progressView.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
        applyCornerStyles()
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: style?.height ?? 4)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
