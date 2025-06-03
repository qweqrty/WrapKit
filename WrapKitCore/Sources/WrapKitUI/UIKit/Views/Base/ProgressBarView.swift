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
    public lazy var progressView = {
        let view = UIProgressView()
        view.progressTintColor = .clear
        view.trackTintColor = .clear
        view.clipsToBounds = true
        return view
    }()
    private var progressViewAnchoredConstraints: AnchoredConstraints?
    
    public init(style: ProgressBarStyle?) {
        super.init(frame: .zero)
        layer.cornerRadius = 4
        self.style = style
        progressView.layer.cornerRadius = 4
        setupSubviews()
        setupConstraints()
        applyStyle()
    }
    
    public var style: ProgressBarStyle? {
        didSet {
            applyStyle()
        }
    }
    
    public func applyProgress(percentage: CGFloat, animated: Bool = true) {
        progressView.progress = Float(percentage * 0.01)
    }
    
    private func applyStyle() {
        backgroundColor = style?.backgroundColor
        progressView.progressTintColor = style?.progressBarColor
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
        let view = ProgressBarView(style: .init(backgroundColor: .lightGray, progressBarColor: .green))
        view.applyProgress(percentage: 40)
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
