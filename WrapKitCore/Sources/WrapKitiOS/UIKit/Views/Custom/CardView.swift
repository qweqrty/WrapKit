//
//  CardView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit

open class CardView: View {
    public let vStackView = StackView(axis: .vertical, contentInset: .init(top: 0, left: 8, bottom: 0, right: 8))
    public let hStackView = StackView(axis: .horizontal, spacing: 14)
    
    public let leadingImageWrapperView = UIView()
    public let leadingImageView = ImageView(tintColor: .black)
    public let leadingShimmerView = ShimmerView()
    public let titleViewsWrapperView = UIView()
    public let titleViews = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 16), textColor: .black),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 16), textColor: .black),
        spacing: 0
    )
    
    public let subtitleLabel = Label(font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 1)
    
    public let trailingImageWrapperView = UIView()
    public let trailingImageView = ImageView(image: UIImage(named: "rightArrow"), tintColor: .black)
    
    public let switchWrapperView = UIView(isHidden: true)
    public lazy var switchControl = SwitchControl()
    
    public let bottomSeparatorView = View(backgroundColor: .gray)
    
    public var titlesViewConstraints: AnchoredConstraints?
    public var leadingImageViewConstraints: AnchoredConstraints?
    public var trailingImageViewConstraints: AnchoredConstraints?
    public var switchControlConstraints: AnchoredConstraints?
    
    public init() {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupPriorities()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        setupPriorities()
    }
    
    private func setupPriorities() {
        subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleViews.keyLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleViews.keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleViews.keyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleViews.valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        switchControl.setContentCompressionResistancePriority(.required, for: .horizontal)
        switchControl.setContentCompressionResistancePriority(.required, for: .vertical)
        leadingShimmerView.isHidden = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func runShimmer(showLeadingImageShimmer: Bool, showKeyLabelShimmer: Bool, showValueLabelShimmer: Bool) {
        leadingShimmerView.isHidden = false
        leadingShimmerView.startShimmering()
        titleViews.runShimmer(showKeyShimmer: showKeyLabelShimmer, showValueShimmer: showValueLabelShimmer)
    }
    
    public func stopShimmer() {
        leadingShimmerView.isHidden = true
        leadingShimmerView.stopShimmering()
        titleViews.stopShimmer()
    }
}

extension CardView {
    func setupSubviews() {
        addSubviews(vStackView)
        vStackView.addArrangedSubview(hStackView)
        vStackView.addArrangedSubview(bottomSeparatorView)
        hStackView.addArrangedSubview(leadingImageWrapperView)
        hStackView.addArrangedSubview(titleViewsWrapperView)
        hStackView.addArrangedSubview(subtitleLabel)
        hStackView.addArrangedSubview(trailingImageWrapperView)
        hStackView.addArrangedSubview(switchWrapperView)
        
        leadingImageWrapperView.addSubview(leadingImageView)
        leadingImageWrapperView.addSubview(leadingShimmerView)
        trailingImageWrapperView.addSubview(trailingImageView)
        titleViewsWrapperView.addSubview(titleViews)
        switchWrapperView.addSubview(switchControl)
    }
    
    func setupConstraints() {
        titlesViewConstraints = titleViews.anchor(
            .topGreaterThanEqual(titleViewsWrapperView.topAnchor),
            .bottomLessThanEqual(titleViewsWrapperView.bottomAnchor),
            .leading(titleViewsWrapperView.leadingAnchor),
            .trailing(titleViewsWrapperView.trailingAnchor),
            .centerY(titleViewsWrapperView.centerYAnchor)
        )
        
        leadingShimmerView.fillSuperview()
        
        leadingImageViewConstraints = leadingImageView.anchor(
            .topGreaterThanEqual(leadingImageWrapperView.topAnchor),
            .bottomLessThanEqual(leadingImageWrapperView.bottomAnchor),
            .top(leadingImageWrapperView.topAnchor, priority: .defaultHigh),
            .bottom(leadingImageWrapperView.bottomAnchor, priority: .defaultHigh),
            .leading(leadingImageWrapperView.leadingAnchor),
            .trailing(leadingImageWrapperView.trailingAnchor),
            .centerX(leadingImageWrapperView.centerXAnchor),
            .centerY(leadingImageWrapperView.centerYAnchor),
            .width(16),
            .height(16, priority: .defaultHigh)
        )
        
        trailingImageViewConstraints = trailingImageView.anchor(
            .topGreaterThanEqual(trailingImageWrapperView.topAnchor),
            .bottomLessThanEqual(trailingImageWrapperView.bottomAnchor),
            .top(trailingImageWrapperView.topAnchor, priority: .defaultHigh),
            .bottom(trailingImageWrapperView.bottomAnchor, priority: .defaultHigh),
            .leading(trailingImageWrapperView.leadingAnchor),
            .trailing(trailingImageWrapperView.trailingAnchor),
            .centerX(trailingImageWrapperView.centerXAnchor),
            .centerY(trailingImageWrapperView.centerYAnchor),
            .width(6.25),
            .height(10, priority: .defaultHigh)
        )
        
        switchControlConstraints = switchControl.anchor(
            .topGreaterThanEqual(switchWrapperView.topAnchor),
            .bottomLessThanEqual(switchWrapperView.bottomAnchor),
            .top(switchWrapperView.topAnchor, priority: .defaultHigh),
            .bottom(switchWrapperView.bottomAnchor, priority: .defaultHigh),
            .leading(switchWrapperView.leadingAnchor),
            .trailing(switchWrapperView.trailingAnchor),
            .centerX(switchWrapperView.centerXAnchor),
            .centerY(switchWrapperView.centerYAnchor)
        )
        
        vStackView.anchor(
            .leading(leadingAnchor),
            .top(topAnchor),
            .trailing(trailingAnchor),
            .bottom(bottomAnchor)
        )
        
        bottomSeparatorView.anchor(.height(1))
    }
}
#endif
