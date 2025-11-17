//
//  NavigationBar.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public protocol HeaderOutput: AnyObject {
    func display(model: HeaderPresentableModel?)
    func display(style: HeaderPresentableModel.Style?)
    func display(centerView: HeaderPresentableModel.CenterView?)
    func display(leadingCard: CardViewPresentableModel?)
    func display(primeTrailingImage: ButtonPresentableModel?)
    func display(secondaryTrailingImage: ButtonPresentableModel?)
    func display(tertiaryTrailingImage: ButtonPresentableModel?)
    func display(isHidden: Bool)
}

public struct HeaderPresentableModel {
    public struct Style {
        public let backgroundColor: Color
        public let horizontalSpacing: CGFloat
        public let primeFont: Font
        public let primeColor: Color
        public let secondaryFont: Font
        public let secondaryColor: Color
        public let numberOfLines: Int
        
        public init(
            backgroundColor: Color,
            horizontalSpacing: CGFloat,
            primeFont: Font,
            primeColor: Color,
            secondaryFont: Font,
            secondaryColor: Color,
            numberOfLines: Int = 1
        ) {
            self.backgroundColor = backgroundColor
            self.horizontalSpacing = horizontalSpacing
            self.primeFont = primeFont
            self.primeColor = primeColor
            self.secondaryFont = secondaryFont
            self.secondaryColor = secondaryColor
            self.numberOfLines = numberOfLines
        }
    }
    
    public enum CenterView {
        case keyValue(Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
        case titledImage(Pair<ImageViewPresentableModel?, TextOutputPresentableModel?>)
    }
    
    public let style: Style?
    public let centerView: CenterView?
    public let leadingCard: CardViewPresentableModel?
    public let primeTrailingImage: ButtonPresentableModel?
    public let secondaryTrailingImage: ButtonPresentableModel?
    public let tertiaryTrailingImage: ButtonPresentableModel?
    
    public init(
        style: Style? = nil,
        centerView: CenterView? = nil,
        leadingCard: CardViewPresentableModel? = nil,
        primeTrailingImage: ButtonPresentableModel? = nil,
        secondaryTrailingImage: ButtonPresentableModel? = nil,
        tertiaryTrailingImage: ButtonPresentableModel? = nil
    ) {
        self.style = style
        self.centerView = centerView
        self.leadingCard = leadingCard
        self.primeTrailingImage = primeTrailingImage
        self.secondaryTrailingImage = secondaryTrailingImage
        self.tertiaryTrailingImage = tertiaryTrailingImage
    }
}

#if canImport(UIKit)
import UIKit

extension NavigationBar: HeaderOutput {
    public func display(model: HeaderPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        display(centerView: model.centerView)
        display(style: model.style)
        display(leadingCard: model.leadingCard)
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
            centerTitledImageView.closingTitleVFieldView.keyLabel.display(model: pair.second)
            centerTitledImageView.contentView.contentView.display(model: pair.first)
        default:
            titleViews.isHidden = true
            centerTitledImageView.isHidden = true
        }
    }
    
    public func display(style: HeaderPresentableModel.Style?) {
        if let style = style {
            backgroundColor = style.backgroundColor
            leadingStackView.spacing = style.horizontalSpacing
            trailingStackView.spacing = style.horizontalSpacing * 1.5
            
            leadingCardView.leadingImageView.tintColor = style.primeColor
            primeTrailingImageWrapperView.contentView.tintColor = style.primeColor
            secondaryTrailingImageWrapperView.contentView.tintColor = style.primeColor
            tertiaryTrailingImageWrapperView.contentView.tintColor = style.primeColor
            
            leadingCardView.titleViews.keyLabel.font = style.primeFont
            leadingCardView.titleViews.keyLabel.textColor = style.primeColor
            titleViews.keyLabel.font = style.primeFont
            titleViews.keyLabel.textColor = style.primeColor
            titleViews.keyLabel.numberOfLines = style.numberOfLines
            centerTitledImageView.closingTitleVFieldView.keyLabel.textColor = style.secondaryColor
            centerTitledImageView.closingTitleVFieldView.keyLabel.font = style.secondaryFont
        }
    }
    
    public func display(leadingCard: CardViewPresentableModel?) {
        leadingCardGlassEffectView.isHidden = leadingCard == nil
        leadingCardView.display(model: leadingCard)
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
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
}

open class NavigationBar: UIView {
    public lazy var leadingStackWrapperView = UIView()
    public lazy var leadingStackView = StackView(axis: .horizontal, spacing: 12)
    
    public lazy var centerView = UIView()
    public lazy var centerTitledImageView = makeTitledLogoView()
    
    public lazy var trailingStackWrapperView = UIView()
    public lazy var trailingStackView = StackView(axis: .horizontal, spacing: 12)
    public lazy var mainStackView = StackView(axis: .horizontal, spacing: 8)
    
    public lazy var leadingCardGlassEffectView = makeLeadingCardGlassEffectView()
    public lazy var leadingCardView = makeLeadingCardView(isHidden: true)
    public lazy var secondaryLeadingCardView = makeLeadingCardView(isHidden: true)
    public lazy var titleViews = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 18), textColor: .black, textAlignment: .center, numberOfLines: 1),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)
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
    
    public init(style: HeaderPresentableModel.Style) {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        display(style: style)
    }
    
    private func setupSubviews() {
        layer.zPosition = 100
        addSubviews(mainStackView)
        leadingStackWrapperView.addSubview(leadingStackView)
        trailingStackWrapperView.addSubview(trailingStackView)
        
        mainStackView.addArrangedSubview(leadingStackWrapperView)
        mainStackView.addArrangedSubview(centerView)
        mainStackView.addArrangedSubview(trailingStackWrapperView)
        leadingStackView.addArrangedSubview(leadingCardGlassEffectView)
        if let leadingCardGlassEffectView = (leadingCardGlassEffectView as? UIVisualEffectView) {
            leadingCardGlassEffectView.contentView.addSubview(leadingCardView)
        } else {
            leadingCardGlassEffectView.addSubview(leadingCardView)
        }
        
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
        
        leadingCardView.fillSuperview()
        
        trailingStackView.anchor(
            .top(trailingStackWrapperView.topAnchor),
            .leadingGreaterThanEqual(trailingStackWrapperView.leadingAnchor),
            .trailing(trailingStackWrapperView.trailingAnchor),
            .bottom(trailingStackWrapperView.bottomAnchor)
        )
        
        mainStackViewConstraints = mainStackView.anchor(
            .top(safeAreaLayoutGuide.topAnchor, constant: 4),
            .leading(leadingAnchor, constant: 8),
            .trailing(trailingAnchor, constant: 8),
            .height(44),
            .bottom(bottomAnchor, constant: 8)
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
    func makeLeadingCardGlassEffectView() -> UIView {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
            let glassEffect = UIGlassEffect(style: .regular)
            glassEffect.isInteractive = true
            let glassEffectView = UIVisualEffectView(effect: glassEffect)
            glassEffectView.layer.cornerRadius = 22
            glassEffectView.layer.cornerCurve = .continuous
            glassEffectView.isHidden = true
            return glassEffectView
        } else {
            return UIView()
        }
    }
    
    func makeLeadingCardView(isHidden: Bool) -> CardView {
        let view = CardView()
        view.isHidden = isHidden
        view.vStackView.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
        view.hStackView.spacing = 8
        view.bottomSeparatorView.isHidden = true
        view.trailingImageWrapperView.isHidden = true
        view.subtitleLabel.isHidden = true
        return view
    }
    
    func makeTitledLogoView() -> TitledView<WrapperView<ImageView>> {
        let view = TitledView(contentView: WrapperView(
            contentView: ImageView(),
            contentViewConstraints: { contentView, _ in
                contentView.centerInSuperview()
            }
        ))
        view.isHidden = true
        view.closingTitleVFieldView.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.closingTitleVFieldView.keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.closingTitleVFieldView.valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.closingTitleVFieldView.keyLabel.textAlignment = .center
        view.closingTitleVFieldView.valueLabel.textAlignment = .center
        view.closingTitleVFieldView.isHidden = false
        return view
    }
    
    func makeWrappedImageView() -> WrapperView<Button> {
        let view = WrapperView(
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
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
            view.contentView.configuration = .glass()
        }
        return view
    }
}
#endif

