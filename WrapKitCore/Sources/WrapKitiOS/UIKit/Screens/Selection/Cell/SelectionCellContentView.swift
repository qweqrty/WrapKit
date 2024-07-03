//
//  SelectionCellContentView.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import UIKit

class SelectionCellContentView: View {
    lazy var titleLabel = makeTitleLabel()
    lazy var trailingLabel = makeTrailingLabel()
    lazy var trailingStackView = makeTrailingStackView()
    let leadingImageContainerView = View(isHidden: true)
    let leadingImageView = ImageView()
    let trailingImageContainerView = View(isHidden: true)
    let trailingImageView = ImageView()
    let leadingStackView = StackView(axis: .horizontal, spacing: 8)
    let lineView = View(backgroundColor: .gray)
    
    private(set) var leadingImageViewConstraints: AnchoredConstraints?
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectionCellContentView {
    private func makeTrailingStackView() -> StackView {
        let trailingStackView = StackView(
            axis: .horizontal,
            spacing: 8,
            contentInset: .init(top: 0, left: 0, bottom: 0, right: 4)
        )
        return trailingStackView
    }
    
    private func makeTitleLabel() -> Label {
        let titleLabel = Label(
            font: .systemFont(ofSize: 16),
            textColor: UIColor.black,
            numberOfLines: 1
        )
        return titleLabel
    }
    
    private func makeTrailingLabel() -> Label {
        let trailingLabel = Label(
            font: .systemFont(ofSize: 16),
            textColor: UIColor.gray,
            textAlignment: .center
        )
        return trailingLabel
    }
}

extension SelectionCellContentView {
    func setupSubviews() {
        addSubviews(leadingStackView, trailingStackView, lineView)
        leadingImageContainerView.addSubview(leadingImageView)
        trailingImageContainerView.addSubview(trailingImageView)
        leadingStackView.constrainHeight(56)
        leadingStackView.addArrangedSubviews(
            leadingImageContainerView,
            titleLabel
        )
        trailingStackView.addArrangedSubviews(
            trailingLabel,
            trailingImageContainerView
        )
    }
    
    func setupConstraints() {
        leadingImageViewConstraints = leadingImageView.anchor(
            .centerY(leadingImageContainerView.centerYAnchor),
            .centerX(leadingImageContainerView.centerXAnchor),
            .height(20),
            .width(20)
        )
        trailingImageView.anchor(
            .centerY(trailingImageContainerView.centerYAnchor),
            .centerX(trailingImageContainerView.centerXAnchor)
        )
        trailingImageContainerView.constrainWidth(24)
        leadingImageContainerView.constrainWidth(24)
        
        leadingStackView.anchor(
            .top(topAnchor),
            .leading(leadingAnchor)
        )
        
        trailingStackView.anchor(
            .centerY(leadingStackView.centerYAnchor),
            .trailing(trailingAnchor)
        )
        
        lineView.anchor(
            .top(leadingStackView.bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor),
            .height(1),
            .bottom(bottomAnchor)
        )
    }
}
