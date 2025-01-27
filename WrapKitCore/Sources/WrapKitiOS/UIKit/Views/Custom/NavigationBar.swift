//
//  NavigationBar.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol HeaderOutput: AnyObject {
    func display(model: HeaderPresentableModel?)
    func display(style: HeaderPresentableModel.Style?)
    func display(centerView: HeaderPresentableModel.CenterView?)
    func display(leadingImage: ImageViewPresentableModel?)
    func display(primeTrailingImage: ButtonPresentableModel?)
    func display(secondaryTrailingImage: ButtonPresentableModel?)
    func display(tertiaryTrailingImage: ButtonPresentableModel?)
}

public struct HeaderPresentableModel {
    public struct Style {
        public let horizontalSpacing: CGFloat
        public let primeFont: Font
        public let primeTextColor: Color
        public let secondaryFont: Font
        public let secondaryTextColor: Color
        
        public init(
            horizontalSpacing: CGFloat,
            primeFont: Font,
            primeTextColor: Color,
            secondaryFont: Font,
            secondaryTextColor: Color
        ) {
            self.horizontalSpacing = horizontalSpacing
            self.primeFont = primeFont
            self.primeTextColor = primeTextColor
            self.secondaryFont = secondaryFont
            self.secondaryTextColor = secondaryTextColor
        }
    }
    
    public enum CenterView {
        case keyValue(Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
        case titledImage(Pair<ImageViewPresentableModel?, TextOutputPresentableModel?>)
    }
    
    public let style: Style?
    public let centerView: CenterView?
    public let leadingImage: ImageViewPresentableModel?
    public let primeTrailingImage: ButtonPresentableModel?
    public let secondaryTrailingImage: ButtonPresentableModel?
    public let tertiaryTrailingImage: ButtonPresentableModel?
    
    public init(
        style: Style? = nil,
        centerView: CenterView? = nil,
        leadingImage: ImageViewPresentableModel? = nil,
        primeTrailingImage: ButtonPresentableModel? = nil,
        secondaryTrailingImage: ButtonPresentableModel? = nil,
        tertiaryTrailingImage: ButtonPresentableModel? = nil
    ) {
        self.style = style
        self.centerView = centerView
        self.leadingImage = leadingImage
        self.primeTrailingImage = primeTrailingImage
        self.secondaryTrailingImage = secondaryTrailingImage
        self.tertiaryTrailingImage = tertiaryTrailingImage
    }
}

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
    
    public lazy var leadingCardView = makeLeadingCardView(isHidden: false)
    public lazy var secondaryLeadingCardView = makeLeadingCardView(isHidden: true)
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
    func makeLeadingCardView(isHidden: Bool) -> CardView {
        let view = CardView()
        view.isHidden = isHidden
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

extension NavigationBar: HeaderOutput {
    public func display(model: HeaderPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        display(centerView: model.centerView)
        display(style: model.style)
        display(leadingImage: model.leadingImage)
        display(primeTrailingImage: model.primeTrailingImage)
        display(secondaryTrailingImage: model.secondaryTrailingImage)
        display(tertiaryTrailingImage: model.tertiaryTrailingImage)
    }
    
    public func display(centerView: HeaderPresentableModel.CenterView?) {
        switch centerView {
        case .keyValue(let pair):
            titleViews.display(model: pair)
            centerTitledImageView.isHidden = true
        case .titledImage(let pair):
            titleViews.isHidden = true
            centerTitledImageView.isHidden = pair.first == nil && pair.second == nil
            centerTitledImageView.titlesView.keyLabel.display(model: pair.second)
            centerTitledImageView.contentView.display(model: pair.first)
        default:
            titleViews.isHidden = true
            centerTitledImageView.isHidden = true
        }
    }
    
    public func display(style: HeaderPresentableModel.Style?) {
        if let style = style {
            leadingStackView.spacing = style.horizontalSpacing
            trailingStackView.spacing = style.horizontalSpacing * 1.5
            mainStackViewConstraints?.leading?.constant = 8
            mainStackViewConstraints?.trailing?.constant = -8
            
            leadingCardView.titleViews.keyLabel.font = style.primeFont
            leadingCardView.titleViews.keyLabel.textColor = style.primeTextColor
            titleViews.keyLabel.font = style.primeFont
            titleViews.keyLabel.textColor = style.primeTextColor
            centerTitledImageView.closingTitleVFieldView.keyLabel.textColor = style.secondaryTextColor
            centerTitledImageView.closingTitleVFieldView.keyLabel.font = style.secondaryFont
        }
    }
    
    public func display(leadingImage: ImageViewPresentableModel?) {
        leadingCardView.display(leadingImage: leadingImage)
    }
    
    public func display(primeTrailingImage: ButtonPresentableModel?) {
        primeTrailingImageWrapperView.isHidden = primeTrailingImage == nil
        primeTrailingImageWrapperView.contentView.display(model: primeTrailingImage)
    }
    
    public func display(secondaryTrailingImage: ButtonPresentableModel?) {
        secondaryTrailingImageWrapperView.isHidden = secondaryTrailingImage == nil
        secondaryTrailingImageWrapperView.contentView.display(model: secondaryTrailingImage)
    }
    
    public func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        tertiaryTrailingImageWrapperView.isHidden = tertiaryTrailingImage == nil
        tertiaryTrailingImageWrapperView.contentView.display(model: tertiaryTrailingImage)
    }
}
#endif
