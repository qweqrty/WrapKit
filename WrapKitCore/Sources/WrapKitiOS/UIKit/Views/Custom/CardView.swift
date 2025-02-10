//
//  CardView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

import Foundation

public protocol CardViewOutput: AnyObject {
    func display(model: CardViewPresentableModel?)
    func display(style: CardViewPresentableModel.Style?)
    func display(title: TextOutputPresentableModel?)
    func display(leadingImage: ImageViewPresentableModel?)
    func display(secondaryLeadingImage: ImageViewPresentableModel?)
    func display(trailingImage: ImageViewPresentableModel?)
    func display(secondaryTrailingImage: ImageViewPresentableModel?)
    func display(subTitle: TextOutputPresentableModel?)
    func display(valueTitle: TextOutputPresentableModel?)
    func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?)
    func display(switchControl: SwitchControlPresentableModel?)
    func display(onPress: (() -> Void)?)
    func display(onLongPress: (() -> Void)?)
}

public struct CardViewPresentableModel: HashableWithReflection {
    public struct Style {
        public let backgroundColor: Color
        public let vStacklayoutMargins: EdgeInsets
        public let hStacklayoutMargins: EdgeInsets
        public let titleKeyTextColor: Color
        public let titleValueTextColor: Color
        public let subTitleTextColor: Color
        public let titleKeyLabelFont: Font
        public let titleValueLabelFont: Font
        public let subTitleLabelFont: Font
        public let cornerRadius: CGFloat
        public let stackSpace: CGFloat
        public let hStackViewSpacing: CGFloat
        
        public init(
            backgroundColor: Color,
            vStacklayoutMargins: EdgeInsets,
            hStacklayoutMargins: EdgeInsets,
            titleKeyTextColor: Color,
            titleValueTextColor: Color,
            subTitleTextColor: Color,
            titleKeyLabelFont: Font,
            titleValueLabelFont: Font,
            subTitleLabelFont: Font,
            cornerRadius: CGFloat,
            stackSpace: CGFloat,
            hStackViewSpacing: CGFloat
        ) {
            self.backgroundColor = backgroundColor
            self.vStacklayoutMargins = vStacklayoutMargins
            self.hStacklayoutMargins = hStacklayoutMargins
            self.titleKeyTextColor = titleKeyTextColor
            self.titleValueTextColor = titleValueTextColor
            self.subTitleTextColor = subTitleTextColor
            self.titleKeyLabelFont = titleKeyLabelFont
            self.titleValueLabelFont = titleValueLabelFont
            self.subTitleLabelFont = subTitleLabelFont
            self.cornerRadius = cornerRadius
            self.stackSpace = stackSpace
            self.hStackViewSpacing = hStackViewSpacing
        }
    }

    public struct BottomSeparator {
        public let color: Color
        public let padding: EdgeInsets
        public let height: CGFloat

        public init(color: Color, padding: EdgeInsets = .zero, height: CGFloat = 1) {
            self.color = color
            self.padding = padding
            self.height = height
        }
    }

    public let style: Style?
    public let title: TextOutputPresentableModel?
    public let leadingImage: ImageViewPresentableModel?
    public let secondaryLeadingImage: ImageViewPresentableModel?
    public let trailingImage: ImageViewPresentableModel?
    public let secondaryTrailingImage: ImageViewPresentableModel?
    public let subTitle: TextOutputPresentableModel?
    public let valueTitle: TextOutputPresentableModel?
    public let bottomImage: ImageViewPresentableModel?
    public let bottomSeparator: BottomSeparator?
    public let switchControl: SwitchControlPresentableModel?
    public let onPress: (() -> Void)?
    public let onLongPress: (() -> Void)?
    
    public init(
        style: Style? = nil,
        title: TextOutputPresentableModel? = nil,
        leadingImage: ImageViewPresentableModel? = nil,
        secondaryLeadingImage: ImageViewPresentableModel? = nil,
        trailingImage: ImageViewPresentableModel? = nil,
        secondaryTrailingImage: ImageViewPresentableModel? = nil,
        subTitle: TextOutputPresentableModel? = nil,
        valueTitle: TextOutputPresentableModel? = nil,
        bottomImage: ImageViewPresentableModel? = nil,
        bottomSeparator: BottomSeparator? = nil,
        switchControl: SwitchControlPresentableModel? = nil,
        onPress: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self.leadingImage = leadingImage
        self.secondaryLeadingImage = secondaryLeadingImage
        self.trailingImage = trailingImage
        self.secondaryTrailingImage = secondaryTrailingImage
        self.subTitle = subTitle
        self.valueTitle = valueTitle
        self.bottomImage = bottomImage
        self.bottomSeparator = bottomSeparator
        self.switchControl = switchControl
        self.onPress = onPress
        self.onLongPress = onLongPress
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUI

extension CardView: CardViewOutput {
    public func display(style: CardViewPresentableModel.Style?) {
        guard let style = style else { return }
        hStackView.spacing = style.hStackViewSpacing
        backgroundColor = style.backgroundColor
        vStackView.layoutMargins = style.vStacklayoutMargins.asUIEdgeInsets
        hStackView.layoutMargins = style.hStacklayoutMargins.asUIEdgeInsets
        titleViews.stackView.spacing = style.stackSpace

        titleViews.keyLabel.font = style.titleKeyLabelFont
        subtitleLabel.textColor = style.subTitleTextColor
        subtitleLabel.font = style.subTitleLabelFont
        titleViews.keyLabel.textColor = style.titleKeyTextColor
        titleViews.valueLabel.textColor = style.titleValueTextColor
        titleViews.valueLabel.font = style.titleValueLabelFont
        cornerRadius = style.cornerRadius
    }
    
    public func display(onPress: (() -> Void)?) {
        self.onPress = onPress
    }
    
    public func display(onLongPress: (() -> Void)?) {
        self.onLongPress = onLongPress
    }
    
    public func display(title: TextOutputPresentableModel?) {
        titleViews.keyLabel.display(model: title)
    }
    
    public func display(leadingImage: ImageViewPresentableModel?) {
        leadingImageWrapperView.isHidden = leadingImage == nil
        leadingImageView.display(model: leadingImage)
    }
    
    public func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        secondaryLeadingImageWrapperView.isHidden = secondaryLeadingImage == nil
        secondaryLeadingImageView.display(model: secondaryLeadingImage)
    }
    
    public func display(trailingImage: ImageViewPresentableModel?) {
        trailingImageWrapperView.isHidden = trailingImage == nil
        trailingImageView.display(model: trailingImage)
    }
    
    public func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        secondaryTrailingImageWrapperView.isHidden = secondaryTrailingImage == nil
        secondaryTrailingImageView.display(model: secondaryTrailingImage)
    }
    
    public func display(subTitle: TextOutputPresentableModel?) {
        subtitleLabel.display(model: subTitle)
    }
    
    public func display(valueTitle: TextOutputPresentableModel?) {
        titleViews.valueLabel.display(model: valueTitle)
    }
    
    public func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        bottomSeparatorView.isHidden = bottomSeparator == nil
        if let bottomSeparator = bottomSeparator {
            bottomSeparatorView.contentView.backgroundColor = bottomSeparator.color
            bottomSeparatorView.contentViewConstraints?.top?.constant = bottomSeparator.padding.top
            bottomSeparatorView.contentViewConstraints?.leading?.constant = bottomSeparator.padding.left
            bottomSeparatorView.contentViewConstraints?.trailing?.constant = bottomSeparator.padding.right
            bottomSeparatorView.contentViewConstraints?.bottom?.constant = bottomSeparator.padding.bottom
            bottomSeparatorViewConstraints?.height?.constant = bottomSeparator.height
        }
    }
    
    public func display(switchControl: SwitchControlPresentableModel?) {
        switchWrapperView.isHidden = switchControl == nil
        if let switchControl = switchControl {
            self.switchControl.display(model: switchControl)
        }
    }
    
    public func display(model: CardViewPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        // Style
        display(style: model.style)
        
        // Key title
        display(title: model.title)
        
        // Value title
        display(valueTitle: model.valueTitle)
        
        // Subtitle
        display(subTitle: model.subTitle)
        
        // LeadingImage
        display(leadingImage: model.leadingImage)
        
        // SecondaryLeadingImage
        display(secondaryLeadingImage: model.secondaryLeadingImage)
        
        // TrailingImage
        display(trailingImage: model.trailingImage)
        
        // SecondaryTrailingImage
        display(secondaryTrailingImage: model.secondaryTrailingImage)
        
        // bottomSeparatorView
        display(bottomSeparator: model.bottomSeparator)
        
        //switchControl
        display(switchControl: model.switchControl)
        
        display(onPress: model.onPress)
        display(onLongPress: model.onLongPress)
    }
}

open class CardView: View {
    public let vStackView = StackView(axis: .vertical, contentInset: .init(top: 0, left: 8, bottom: 0, right: 8))
    public let hStackView = StackView(axis: .horizontal, spacing: 14)
    
    public let leadingImageWrapperView = UIView(isHidden: true)
    public let leadingImageView = ImageView(image: UIImage(named: "rightArrow"), tintColor: .black)
    
    public let secondaryLeadingImageWrapperView = UIView(isHidden: true)
    public let secondaryLeadingImageView = ImageView(tintColor: .black)
    
    public let titleViewsWrapperView = UIView()
    public let titleViews = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 16), textColor: .black),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 16), textColor: .black),
        spacing: 0
    )
    
    public let subtitleLabel = Label(font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 1)
    
    public let trailingImageWrapperView = View(isHidden: true)
    public let trailingImageView = ImageView(image: UIImage(named: "rightArrow"), tintColor: .black)
    
    public let secondaryTrailingImageWrapperView = UIView(isHidden: true)
    public let secondaryTrailingImageView = ImageView()
    
    public let switchWrapperView = UIView(isHidden: true)
    public lazy var switchControl = SwitchControl()
    
    public let bottomImageWrapperView = UIView(isHidden: true)
    public let bottomImageView = ImageView(tintColor: .black)
    
    public let bottomSeparatorView = WrapperView(
        contentView: View(backgroundColor: .gray),
        isHidden: true,
        contentViewConstraints: { contentView, superView in
            contentView.fillSuperview()
        }
    )
    
    public var titlesViewConstraints: AnchoredConstraints?
    public var leadingImageViewConstraints: AnchoredConstraints?
    public var secondaryLeadingImageViewConstraints: AnchoredConstraints?
    public var trailingImageViewConstraints: AnchoredConstraints?
    public var secondaryTrailingImageViewConstraints: AnchoredConstraints?
    public var switchControlConstraints: AnchoredConstraints?
    public var bottomSeparatorViewConstraints: AnchoredConstraints?
    
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
    
    public init(style: CardViewPresentableModel.Style) {
        super.init(frame: .zero)
        
        setupSubviews()
        setupConstraints()
        setupPriorities()
        display(style: style)
    }
    
    private func setupPriorities() {
        subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleViews.keyLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleViews.keyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleViews.keyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleViews.valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleViewsWrapperView.setContentCompressionResistancePriority(.required, for: .vertical)
        switchControl.setContentCompressionResistancePriority(.required, for: .horizontal)
        switchControl.setContentCompressionResistancePriority(.required, for: .vertical)
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
        vStackView.addArrangedSubview(bottomImageWrapperView)
        hStackView.addArrangedSubview(leadingImageWrapperView)
        hStackView.addArrangedSubview(secondaryLeadingImageWrapperView)
        hStackView.addArrangedSubview(titleViewsWrapperView)
        hStackView.addArrangedSubview(subtitleLabel)
        hStackView.addArrangedSubview(secondaryTrailingImageWrapperView)
        hStackView.addArrangedSubview(trailingImageWrapperView)
        hStackView.addArrangedSubview(switchWrapperView)
        
        leadingImageWrapperView.addSubview(leadingImageView)
        secondaryLeadingImageWrapperView.addSubview(secondaryLeadingImageView)
        trailingImageWrapperView.addSubview(trailingImageView)
        secondaryTrailingImageWrapperView.addSubview(secondaryTrailingImageView)
        
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
        
        leadingImageViewConstraints = leadingImageView.anchor(
            .topGreaterThanEqual(leadingImageWrapperView.topAnchor),
            .bottomLessThanEqual(leadingImageWrapperView.bottomAnchor),
            .top(leadingImageWrapperView.topAnchor, priority: .defaultHigh),
            .bottom(leadingImageWrapperView.bottomAnchor, priority: .defaultHigh),
            .leading(leadingImageWrapperView.leadingAnchor),
            .trailing(leadingImageWrapperView.trailingAnchor),
            .centerX(leadingImageWrapperView.centerXAnchor),
            .centerY(leadingImageWrapperView.centerYAnchor)
        )
        
        secondaryLeadingImageViewConstraints = secondaryLeadingImageView.anchor(
            .topGreaterThanEqual(secondaryLeadingImageWrapperView.topAnchor),
            .bottomLessThanEqual(secondaryLeadingImageWrapperView.bottomAnchor),
            .top(secondaryLeadingImageWrapperView.topAnchor, priority: .defaultHigh),
            .bottom(secondaryLeadingImageWrapperView.bottomAnchor, priority: .defaultHigh),
            .leading(secondaryLeadingImageWrapperView.leadingAnchor),
            .trailing(secondaryLeadingImageWrapperView.trailingAnchor),
            .centerX(secondaryLeadingImageWrapperView.centerXAnchor),
            .centerY(secondaryLeadingImageWrapperView.centerYAnchor)
        )
        
        secondaryTrailingImageViewConstraints = secondaryTrailingImageView.anchor(
            .topGreaterThanEqual(secondaryTrailingImageWrapperView.topAnchor),
            .bottomLessThanEqual(secondaryTrailingImageWrapperView.bottomAnchor),
            .top(secondaryTrailingImageWrapperView.topAnchor, priority: .defaultHigh),
            .bottom(secondaryTrailingImageWrapperView.bottomAnchor, priority: .defaultHigh),
            .leading(secondaryTrailingImageWrapperView.leadingAnchor),
            .trailing(secondaryTrailingImageWrapperView.trailingAnchor),
            .centerX(secondaryTrailingImageWrapperView.centerXAnchor),
            .centerY(secondaryTrailingImageWrapperView.centerYAnchor)
        )
        
        trailingImageViewConstraints = trailingImageView.anchor(
            .topGreaterThanEqual(trailingImageWrapperView.topAnchor),
            .bottomLessThanEqual(trailingImageWrapperView.bottomAnchor),
            .top(trailingImageWrapperView.topAnchor, priority: .defaultHigh),
            .bottom(trailingImageWrapperView.bottomAnchor, priority: .defaultHigh),
            .leading(trailingImageWrapperView.leadingAnchor),
            .trailing(trailingImageWrapperView.trailingAnchor),
            .centerX(trailingImageWrapperView.centerXAnchor),
            .centerY(trailingImageWrapperView.centerYAnchor)
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
        
        bottomSeparatorViewConstraints = bottomSeparatorView.anchor(.height(1))
    }
}

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
        view.trailingImageWrapperView.isHidden = false
        view.leadingImageWrapperView.isHidden = true
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
        view.leadingImageWrapperView.isHidden = true
        view.trailingImageView.image = UIImage(systemName: "arrow.right")
        view.trailingImageWrapperView.isHidden = false
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
        view.trailingImageWrapperView.isHidden = true
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
        view.leadingImageWrapperView.isHidden = true
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
        view.trailingImageWrapperView.isHidden = true
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
#endif
