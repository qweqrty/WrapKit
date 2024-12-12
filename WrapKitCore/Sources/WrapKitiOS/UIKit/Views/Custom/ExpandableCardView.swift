//
//  ExpandableCardView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

import Foundation

public protocol ExpandableCardViewOutput: AnyObject {
    func display(model: SelectablePresentableModel<Pair<CardViewPresentableModel, CardViewPresentableModel>>)
}

#if canImport(UIKit)
import UIKit
import Combine

extension ExpandableCardView: ExpandableCardViewOutput {
    public func display(model: SelectablePresentableModel<Pair<CardViewPresentableModel, CardViewPresentableModel>>) {
        cancellables.removeAll()
        primeCardView.display(model: model.model.first)
        secondaryCardView.display(model: model.model.second)
        model
            .isSelected
            .publisher
            .sink { [weak self] isSelected in
                let isSelected = isSelected ?? false

                if isSelected {
                    self?.secondaryCardView.isHidden = false
                    self?.secondaryCardView.alpha = 0
                    self?.secondaryCardView.transform = CGAffineTransform(translationX: 0, y: -20)
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: { [weak self] in
                        guard let self = self else { return }
                        self.primeCardView.bottomSeparatorView.isHidden = model.model.first.bottomSeparator == nil ? true : false
                        self.secondaryCardView.alpha = 1
                        self.secondaryCardView.transform = .identity
                        self.layoutIfNeeded()
                    })
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: { [weak self] in
                        guard let self = self else { return }
                        self.secondaryCardView.alpha = 0
                        self.secondaryCardView.transform = CGAffineTransform(translationX: 0, y: -20)
                        self.primeCardView.bottomSeparatorView.isHidden = true
                        self.layoutIfNeeded()
                    }, completion: { [weak self] _ in
                        self?.secondaryCardView.isHidden = true
                    })
                }
            }
            .store(in: &cancellables)
    }
}

open class ExpandableCardView: View {
    public let stackView = StackView(axis: .vertical)
    public let primeCardView: CardView
    public let secondaryCardView: CardView
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        primeCardView = CardView()
        secondaryCardView = CardView()
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
    }
    
    public override init(frame: CGRect) {
        primeCardView = CardView()
        secondaryCardView = CardView()
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    public init(
        primeCardView: CardView,
        secondaryCardView: CardView
    ) {
        self.primeCardView = primeCardView
        self.secondaryCardView = secondaryCardView
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExpandableCardView {
    func setupSubviews() {
        secondaryCardView.isHidden = true
        addSubviews(stackView)
        
        stackView.addArrangedSubviews(primeCardView, secondaryCardView, UIView())
    }
    
    func setupConstraints() {
        stackView.anchor(
            .leading(leadingAnchor),
            .top(topAnchor),
            .trailing(trailingAnchor),
            .bottom(bottomAnchor)
        )
    }
}

//@available(iOS 13.0, *)
//struct ExpandableCardViewFullRepresentable: UIViewRepresentable {
//    func makeUIView(context: Context) -> ExpandableCardView {
//        let view = ExpandableCardView()
//        view.titleViews.keyLabel.text = "Key label"
//        view.titleViews.valueLabel.text = "Value label"
//        view.titleViews.valueLabel.isHidden = false
//        view.titleViews.stackView.spacing = 6
//        view.leadingImageView.image = UIImage(systemName: "mail")
//        view.trailingImageView.image = UIImage(systemName: "arrow.right")
//        view.trailingImageView.isHidden = false
//        view.subtitleLabel.isHidden = false
//        view.subtitleLabel.text = "Subtitle label"
//        return view
//    }
//
//    func updateUIView(_ uiView: ExpandableCardView, context: Context) {
//        // Leave this empty
//    }
//}
//
//@available(iOS 13.0, *)
//struct ExpandableCardViewWithoutLeadingImageRepresentable: UIViewRepresentable {
//    func makeUIView(context: Context) -> ExpandableCardView {
//        let view = ExpandableCardView()
//        view.titleViews.keyLabel.text = "Key label"
//        view.titleViews.valueLabel.text = "Value label"
//        view.titleViews.valueLabel.isHidden = false
//        view.titleViews.stackView.spacing = 6
//        view.trailingImageView.image = UIImage(systemName: "arrow.right")
//        view.trailingImageWrapperView.isHidden = false
//        view.leadingImageWrapperView.isHidden = true
//        view.subtitleLabel.isHidden = false
//        view.subtitleLabel.text = "Subtitle label"
//        return view
//    }
//
//    func updateUIView(_ uiView: ExpandableCardView, context: Context) {
//        // Leave this empty
//    }
//}
//
//@available(iOS 13.0, *)
//struct ExpandableCardViewTitleViewKeyLabelTrailingImageRepresentable: UIViewRepresentable {
//    func makeUIView(context: Context) -> ExpandableCardView {
//        let view = ExpandableCardView()
//        view.titleViews.keyLabel.text = "Key label"
//        view.titleViews.stackView.spacing = 4
//        view.leadingImageWrapperView.isHidden = true
//        view.trailingImageView.image = UIImage(systemName: "arrow.right")
//        view.trailingImageWrapperView.isHidden = false
//        return view
//    }
//
//    func updateUIView(_ uiView: ExpandableCardView, context: Context) {
//        // Leave this empty
//    }
//}
//
//@available(iOS 13.0, *)
//struct ExpandableCardViewTitleViewKeyLabelSubtitleRepresentable: UIViewRepresentable {
//    func makeUIView(context: Context) -> ExpandableCardView {
//        let view = ExpandableCardView()
//        view.titleViews.keyLabel.text = "Key label"
//        view.leadingImageView.image = UIImage(systemName: "mail")
//        view.titleViews.stackView.spacing = 4
//        view.trailingImageWrapperView.isHidden = true
//        view.subtitleLabel.isHidden = false
//        view.subtitleLabel.text = "Subtitle label"
//        return view
//    }
//
//    func updateUIView(_ uiView: ExpandableCardView, context: Context) {
//        // Leave this empty
//    }
//}
//
//@available(iOS 13.0, *)
//struct ExpandableCardViewTitleViewValueLabelRepresentable: UIViewRepresentable {
//    func makeUIView(context: Context) -> ExpandableCardView {
//        let view = ExpandableCardView()
//        view.titleViews.valueLabel.isHidden = false
//        view.titleViews.valueLabel.text = "Value label"
//        view.titleViews.stackView.spacing = 4
//        view.leadingImageWrapperView.isHidden = true
//        view.trailingImageView.image = UIImage(systemName: "arrow.right")
//        view.trailingImageView.isHidden = false
//        return view
//    }
//
//    func updateUIView(_ uiView: ExpandableCardView, context: Context) {
//        // Leave this empty
//    }
//}
//
//@available(iOS 13.0, *)
//struct ExpandableCardViewTitleViewValueLabelSubtitleRepresentable: UIViewRepresentable {
//    func makeUIView(context: Context) -> ExpandableCardView {
//        let view = ExpandableCardView()
//        view.leadingImageView.image = UIImage(systemName: "mail")
//        view.trailingImageWrapperView.isHidden = true
//        view.titleViews.valueLabel.isHidden = false
//        view.titleViews.valueLabel.text = "Value label"
//        view.titleViews.stackView.spacing = 4
//        view.subtitleLabel.isHidden = false
//        view.subtitleLabel.text = "Subtitle label"
//        return view
//    }
//
//    func updateUIView(_ uiView: ExpandableCardView, context: Context) {
//        // Leave this empty
//    }
//}
//
//@available(iOS 13.0, *)
//struct ExpandableCardView_Previews: PreviewProvider {
//    static var previews: some SwiftUI.View {
//            VStack {
//                ExpandableCardViewFullRepresentable()
//                    .frame(height: 80)
//                    .padding()
//                    .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//                    .previewDisplayName("iPhone SE (2nd generation)")
//
//                ExpandableCardViewWithoutLeadingImageRepresentable()
//                    .frame(height: 80)
//                    .padding()
//                    .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//                    .previewDisplayName("iPhone SE (2nd generation)")
//
//                ExpandableCardViewTitleViewKeyLabelTrailingImageRepresentable()
//                    .frame(height: 40)
//                    .padding()
//                    .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
//                    .previewDisplayName("iPhone 12 Pro Max")
//
//                ExpandableCardViewTitleViewKeyLabelSubtitleRepresentable()
//                    .frame(height: 40)
//                    .padding()
//                    .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
//                    .previewDisplayName("iPad Pro (9.7-inch)")
//
//                ExpandableCardViewTitleViewValueLabelRepresentable()
//                    .frame(height: 50)
//                    .padding()
//                    .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//                    .previewDisplayName("iPhone SE (2nd generation)")
//
//                ExpandableCardViewTitleViewValueLabelSubtitleRepresentable()
//                    .frame(height: 50)
//                    .padding()
//                    .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//                    .previewDisplayName("iPhone SE (2nd generation)")
//                Spacer()
//            }
//    }
//}
#endif
