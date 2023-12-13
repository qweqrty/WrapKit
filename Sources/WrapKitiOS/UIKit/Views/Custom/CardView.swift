//
//  CardView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit

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
            .leading(leadingAnchor, constant: 8),
            .top(topAnchor),
            .trailing(trailingAnchor, constant: 8),
            .bottom(bottomAnchor)
        )
        
        trailingImageViewConstraints = trailingImageView.anchor(.width(6.25))
        bottomSeparatorView.anchor(.height(1))
    }
}
#endif
