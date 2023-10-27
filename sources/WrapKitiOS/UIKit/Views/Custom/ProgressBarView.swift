//
//  ProgressBarView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

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
    
    public func applyProgress(percentage: CGFloat) {
        let maxWidth = bounds.width
        let newWidth = maxWidth * (percentage / 100.0)
        progressViewAnchoredConstraints?.width?.constant = newWidth
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
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
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
        }
    }
}
#endif
