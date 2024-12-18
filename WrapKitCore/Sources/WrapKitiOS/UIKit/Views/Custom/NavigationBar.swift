//
//  NavigationBar.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class NavigationBar: UIView {
    public lazy var leadingStackWrapperView = UIView()
    public lazy var leadingStackView = StackView(axis: .horizontal, spacing: 12)
    
    public lazy var centerView = UIView()
    public lazy var centerTitledImageView = makeTitledLogoView()
    
    public lazy var trailingStackWrapperView = UIView()
    public lazy var trailingStackView = StackView(axis: .horizontal, spacing: 12)
    public lazy var mainStackView = StackView(axis: .horizontal, spacing: 8)
    
    public lazy var leadingCardView = makeLeadingCardView()
    public lazy var titleViews = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 18), textColor: .black, textAlignment: .center, numberOfLines: 1),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 14), textColor: .black, numberOfLines: 1)
    )
    public lazy var primeTrailingImageWrapperView = makeWrappedImageView()
    public lazy var secondaryTrailingImageWrapperView = makeWrappedImageView()
    public lazy var tertiaryTrailingImageWrapperView = makeWrappedImageView()
    
    public var mainStackViewConstraints: AnchoredConstraints?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        addSubviews(mainStackView)
        leadingStackWrapperView.addSubview(leadingStackView)
        trailingStackWrapperView.addSubview(trailingStackView)
        
        mainStackView.addArrangedSubview(leadingStackWrapperView)
        mainStackView.addArrangedSubview(centerView)
        mainStackView.addArrangedSubview(trailingStackWrapperView)
        leadingStackView.addArrangedSubview(leadingCardView)
        centerView.addSubview(titleViews)
        centerView.addSubview(centerTitledImageView)
        trailingStackView.addArrangedSubview(primeTrailingImageWrapperView)
        trailingStackView.addArrangedSubview(secondaryTrailingImageWrapperView)
        trailingStackView.addArrangedSubview(tertiaryTrailingImageWrapperView)
    }
    
    private func setupConstraints() {
        leadingStackView.anchor(
            .top(leadingStackWrapperView.topAnchor),
            .leading(leadingStackWrapperView.leadingAnchor),
            .trailingLessThanEqual(leadingStackWrapperView.trailingAnchor),
            .bottom(leadingStackWrapperView.bottomAnchor)
        )
        
        trailingStackView.anchor(
            .top(trailingStackWrapperView.topAnchor),
            .leadingGreaterThanEqual(trailingStackWrapperView.leadingAnchor),
            .trailing(trailingStackWrapperView.trailingAnchor),
            .bottom(trailingStackWrapperView.bottomAnchor)
        )
        
        mainStackViewConstraints = mainStackView.anchor(
            .top(safeAreaLayoutGuide.topAnchor),
            .leading(leadingAnchor, constant: 12),
            .trailing(trailingAnchor, constant: 12),
            .height(52),
            .bottom(bottomAnchor)
        )

        trailingStackWrapperView.setContentCompressionResistancePriority(.required, for: .horizontal)
        leadingStackWrapperView.setContentCompressionResistancePriority(.required, for: .horizontal)
        leadingStackWrapperView.anchor(.widthTo(trailingStackWrapperView.widthAnchor, 1, priority: .defaultLow))
        
        titleViews.fillSuperview()
        
        centerTitledImageView.anchor(
            .top(topAnchor),
            .bottom(bottomAnchor),
            .centerX(centerXAnchor)
        )
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NavigationBar {
    func makeLeadingCardView() -> CardView {
        let view = CardView()
        view.vStackView.layoutMargins = .zero
        view.hStackView.spacing = 8
        view.bottomSeparatorView.isHidden = true
        view.trailingImageWrapperView.isHidden = true
        view.subtitleLabel.isHidden = true
        return view
    }
    
    func makeTitledLogoView() -> TitledView<ImageView> {
        let view = TitledView(contentView: ImageView())
        view.isHidden = true
        view.closingTitleVFieldView.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.closingTitleVFieldView.keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.closingTitleVFieldView.keyLabel.textAlignment = .center
        view.closingTitleVFieldView.isHidden = false
        return view
    }
    
    func makeWrappedImageView() -> WrapperView<Button> {
        return WrapperView(
            contentView: Button(),
            isHidden: true,
            contentViewConstraints: {
                $0.anchor(
                    .topGreaterThanEqual($1.topAnchor),
                    .leading($1.leadingAnchor),
                    .trailing($1.trailingAnchor),
                    .bottomLessThanEqual($1.bottomAnchor),
                    .centerY($1.centerYAnchor)
                )
            }
        )
    }
}
#endif
