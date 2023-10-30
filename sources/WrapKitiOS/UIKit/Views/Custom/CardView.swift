//
//  CardView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

open class CardView: View {
    public let vStackView = StackView(axis: .vertical)
    public let hStackView = StackView(axis: .horizontal, spacing: 14)
    public let leadingImageView = ImageView(tintColor: .black)
    public let titleViews = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 16), textColor: .black),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 16), textColor: .black),
        spacing: 0
    )
    public let subtitleLabel = Label(font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 1)
    public let trailingImageView: ImageView = ImageView(image: UIImage(named: "rightArrow"), tintColor: .black)
    public let bottomSeparatorView = View(backgroundColor: .gray)
    
    public var leadingImageViewConstraints: AnchoredConstraints?
    public var vStackViewConstraints: AnchoredConstraints?
    public var trailingImageViewConstraints: AnchoredConstraints?
    
    public init() {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        
        subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleViews.keyLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleViews.keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        
        subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleViews.keyLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleViews.keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardView {
    func setupSubviews() {
        addSubviews(vStackView)
        vStackView.addArrangedSubview(hStackView)
        vStackView.addArrangedSubview(bottomSeparatorView)
        hStackView.addArrangedSubview(leadingImageView)
        hStackView.addArrangedSubview(titleViews)
        hStackView.addArrangedSubview(subtitleLabel)
        hStackView.addArrangedSubview(trailingImageView)
    }
    
    func setupConstraints() {
        leadingImageViewConstraints = leadingImageView.anchor(
            .width(16)
        )
        
        vStackViewConstraints = vStackView.anchor(
            .leading(leadingAnchor),
            .top(topAnchor, constant: 20),
            .trailing(trailingAnchor),
            .bottom(bottomAnchor)
        )
        
        trailingImageViewConstraints = trailingImageView.anchor(.width(6.25))
        bottomSeparatorView.anchor(.height(1))
    }
}
#endif

@available(iOS 13.0, *)
struct CardViewFullRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CardView {
        let view = CardView()
        view.titleViews.keyLabel.text = "Key label"
        view.titleViews.valueLabel.text = "Value label"
        view.titleViews.valueLabel.isHidden = false
        view.titleViews.stackView.spacing = 6
        view.leadingImageView.image = UIImage(systemName: "mail")
        view.trailingImageView.image = UIImage(systemName: "arrow.right")
        view.trailingImageView.isHidden = false
        view.subtitleLabel.isHidden = false
        view.subtitleLabel.text = "Subtitle label"
        return view
    }
    
    func updateUIView(_ uiView: CardView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct CardViewWithoutLeadingImageRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CardView {
        let view = CardView()
        view.titleViews.keyLabel.text = "Key label"
        view.titleViews.valueLabel.text = "Value label"
        view.titleViews.valueLabel.isHidden = false
        view.titleViews.stackView.spacing = 6
        view.trailingImageView.image = UIImage(systemName: "arrow.right")
        view.trailingImageView.isHidden = false
        view.subtitleLabel.isHidden = false
        view.subtitleLabel.text = "Subtitle label"
        return view
    }
    
    func updateUIView(_ uiView: CardView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct CardViewTitleViewKeyLabelTrailingImageRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CardView {
        let view = CardView()
        view.titleViews.keyLabel.text = "Key label"
        view.titleViews.stackView.spacing = 4
        view.leadingImageView.isHidden = true
        view.trailingImageView.image = UIImage(systemName: "arrow.right")
        view.trailingImageView.isHidden = false
        return view
    }
    
    func updateUIView(_ uiView: CardView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct CardViewTitleViewKeyLabelSubtitleRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CardView {
        let view = CardView()
        view.titleViews.keyLabel.text = "Key label"
        view.leadingImageView.image = UIImage(systemName: "mail")
        view.titleViews.stackView.spacing = 4
        view.subtitleLabel.isHidden = false
        view.subtitleLabel.text = "Subtitle label"
        return view
    }
    
    func updateUIView(_ uiView: CardView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct CardViewTitleViewValueLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CardView {
        let view = CardView()
        view.titleViews.valueLabel.isHidden = false
        view.titleViews.valueLabel.text = "Value label"
        view.titleViews.stackView.spacing = 4
        view.trailingImageView.image = UIImage(systemName: "arrow.right")
        view.trailingImageView.isHidden = false
        return view
    }
    
    func updateUIView(_ uiView: CardView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct CardViewTitleViewValueLabelSubtitleRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CardView {
        let view = CardView()
        view.leadingImageView.image = UIImage(systemName: "mail")
        view.titleViews.valueLabel.isHidden = false
        view.titleViews.valueLabel.text = "Value label"
        view.titleViews.stackView.spacing = 4
        view.subtitleLabel.isHidden = false
        view.subtitleLabel.text = "Subtitle label"
        return view
    }
    
    func updateUIView(_ uiView: CardView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct CardView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
            VStack {
                CardViewFullRepresentable()
                    .frame(height: 80)
                    .padding()
                    .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                    .previewDisplayName("iPhone SE (2nd generation)")
                
                CardViewWithoutLeadingImageRepresentable()
                    .frame(height: 80)
                    .padding()
                    .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                    .previewDisplayName("iPhone SE (2nd generation)")
                
                CardViewTitleViewKeyLabelTrailingImageRepresentable()
                    .frame(height: 40)
                    .padding()
                    .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
                    .previewDisplayName("iPhone 12 Pro Max")
                
                CardViewTitleViewKeyLabelSubtitleRepresentable()
                    .frame(height: 40)
                    .padding()
                    .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
                    .previewDisplayName("iPad Pro (9.7-inch)")
                
                CardViewTitleViewValueLabelRepresentable()
                    .frame(height: 50)
                    .padding()
                    .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                    .previewDisplayName("iPhone SE (2nd generation)")
                
                CardViewTitleViewValueLabelSubtitleRepresentable()
                    .frame(height: 50)
                    .padding()
                    .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                    .previewDisplayName("iPhone SE (2nd generation)")
                Spacer()
            }
    }
}
