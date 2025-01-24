//
//  CardView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

import Foundation

public protocol CardViewOutput: AnyObject {
    func display(model: CardViewPresentableModel?)
    func display(title: TextOutputPresentableModel?)
    func display(leadingImage: ImageViewPresentableModel?)
    func display(trailingImage: ImageViewPresentableModel?)
    func display(secondaryTrailingImage: ImageViewPresentableModel?)
    func display(subTitle: TextOutputPresentableModel?)
    func display(valueTitle: TextOutputPresentableModel?)
    func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?)
    func display(switchControl: SwitchControlPresentableModel?)
    func display(status: CardViewPresentableModel.Status?)
}

public struct CardViewPresentableModel: HashableWithReflection {
    public struct BottomSeparator {
        public let color: Color
        public let padding: EdgeInsets
        public let height: CGFloat

        public init(color: Color, padding: EdgeInsets = .init(), height: CGFloat = 1) {
            self.color = color
            self.padding = padding
            self.height = height
        }
    }
    
    public struct Status {
        public let title: TextOutputPresentableModel?
        public let leadingImage: ImageViewPresentableModel?
        
        public init(title: TextOutputPresentableModel? = nil, leadingImage: ImageViewPresentableModel? = nil) {
            self.title = title
            self.leadingImage = leadingImage
        }
    }

    public let title: TextOutputPresentableModel?
    public let leadingImage: ImageViewPresentableModel?
    public let trailingImage: ImageViewPresentableModel?
    public let secondaryTrailingImage: ImageViewPresentableModel?
    public let subTitle: TextOutputPresentableModel?
    public let valueTitle: TextOutputPresentableModel?
    public let bottomSeparator: BottomSeparator?
    public let switchControl: SwitchControlPresentableModel?
    public let status: Status?
    
    public init(
        title: TextOutputPresentableModel? = nil,
        leadingImage: ImageViewPresentableModel? = nil,
        trailingImage: ImageViewPresentableModel? = nil,
        secondaryTrailingImage: ImageViewPresentableModel? = nil,
        subTitle: TextOutputPresentableModel? = nil,
        valueTitle: TextOutputPresentableModel? = nil,
        bottomSeparator: BottomSeparator? = nil,
        switchControl: SwitchControlPresentableModel? = nil,
        status: Status? = nil
    ) {
        self.title = title
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
        self.secondaryTrailingImage = secondaryTrailingImage
        self.subTitle = subTitle
        self.valueTitle = valueTitle
        self.bottomSeparator = bottomSeparator
        self.switchControl = switchControl
        self.status = status
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUI

extension CardView: CardViewOutput {
    public func display(title: TextOutputPresentableModel?) {
        titleViews.keyLabel.isHidden = title == nil
        titleViews.keyLabel.removeAttributes()
        titleViews.keyLabel.display(model: title)
    }
    
    public func display(status: CardViewPresentableModel.Status?) {
        statusWrapperView.isHidden = status == nil
        if let status = status {
            statusLabel.removeAttributes()
            statusLabel.display(model: status.title)
            statusLeadingImageView.display(model: status.leadingImage)
            statusLeadingImageView.contentMode = status.leadingImage?.contentModeIsFit == true ? .scaleAspectFit : .scaleAspectFill
            statusLeadingImageViewConstraints?.width?.constant = status.leadingImage?.size?.width ?? 0
            statusLeadingImageViewConstraints?.height?.constant = status.leadingImage?.size?.height ?? 0
        }
    }
    
    public func display(leadingImage: ImageViewPresentableModel?) {
        leadingImageWrapperView.isHidden = leadingImage == nil
        leadingImageViewConstraints?.width?.constant = leadingImage?.size?.width ?? 0
        leadingImageViewConstraints?.height?.constant = leadingImage?.size?.height ?? 0
        
        leadingImageView.display(model: leadingImage)
        leadingImageView.contentMode = leadingImage?.contentModeIsFit == true ? .scaleAspectFit : .scaleAspectFill
    }
    
    public func display(trailingImage: ImageViewPresentableModel?) {
        trailingImageWrapperView.isHidden = trailingImage == nil
        trailingImageViewConstraints?.width?.constant = trailingImage?.size?.width ?? 0
        trailingImageViewConstraints?.height?.constant = trailingImage?.size?.height ?? 0
        trailingImageView.display(model: trailingImage)
        trailingImageView.contentMode = trailingImage?.contentModeIsFit == true ? .scaleAspectFit : .scaleAspectFill
    }
    
    public func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        secondaryTrailingImageWrapperView.isHidden = secondaryTrailingImage == nil
        secondaryTrailingImageViewConstraints?.width?.constant = secondaryTrailingImage?.size?.width ?? 0
        secondaryTrailingImageViewConstraints?.height?.constant = secondaryTrailingImage?.size?.height ?? 0
        secondaryTrailingImageView.display(model: secondaryTrailingImage)
        secondaryTrailingImageView.contentMode = secondaryTrailingImage?.contentModeIsFit == true ? .scaleAspectFit : .scaleAspectFill
    }
    
    public func display(subTitle: TextOutputPresentableModel?) {
        subtitleLabel.isHidden = subTitle == nil
        subtitleLabel.removeAttributes()
        subtitleLabel.display(model: subTitle)
    }
    
    public func display(valueTitle: TextOutputPresentableModel?) {
        titleViews.valueLabel.isHidden = valueTitle == nil
        titleViews.valueLabel.removeAttributes()
        titleViews.valueLabel.display(model: valueTitle)
    }
    
    public func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        bottomSeparatorView.isHidden = bottomSeparator == nil
        if let bottomSeparator = bottomSeparator {
            bottomSeparatorView.contentView.backgroundColor = bottomSeparator.color
            bottomSeparatorView.contentViewConstraints?.top?.constant = bottomSeparator.padding.top
            bottomSeparatorView.contentViewConstraints?.leading?.constant = bottomSeparator.padding.leading
            bottomSeparatorView.contentViewConstraints?.trailing?.constant = bottomSeparator.padding.trailing
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
        // Key title
        display(title: model.title)
        
        // Value title
        display(valueTitle: model.valueTitle)
        
        // Subtitle
        display(subTitle: model.subTitle)
        
        // LeadingImage
        display(leadingImage: model.leadingImage)
        
        // TrailingImage
        display(trailingImage: model.trailingImage)
        
        // SecondaryTrailingImage
        display(secondaryTrailingImage: model.secondaryTrailingImage)
        
        // bottomSeparatorView
        display(bottomSeparator: model.bottomSeparator)
        
        //switchControl
        display(switchControl: model.switchControl)
        
        //status view
        display(status: model.status)
    }
}

open class CardView: View {
    public let vStackView = StackView(axis: .vertical, contentInset: .init(top: 0, left: 8, bottom: 0, right: 8))
    public let hStackView = StackView(axis: .horizontal, spacing: 14)
    
    public let leadingImageWrapperView = UIView()
    public let leadingImageView = ImageView(tintColor: .black)
    
    public let titleViewsWrapperView = UIView()
    public let titleViews = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 16), textColor: .black),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 16), textColor: .black),
        spacing: 0
    )
    
    public let subtitleLabel = Label(font: .systemFont(ofSize: 16), textColor: .gray, numberOfLines: 1)
    
    public let trailingImageWrapperView = View()
    public let trailingImageView = ImageView(image: UIImage(named: "rightArrow"), tintColor: .black)
    
    public let secondaryTrailingImageWrapperView = UIView(isHidden: true)
    public let secondaryTrailingImageView = ImageView()
    
    public let switchWrapperView = UIView(isHidden: true)
    public lazy var switchControl = SwitchControl()
    
    public let statusWrapperView = View(isHidden: true)
    public let statusContainerView = View()
    public let statusLabel = Label(font: .systemFont(ofSize: 16), textColor: .black)
    public let statusLeadingImageView = ImageView()
    
    public let bottomSeparatorView = WrapperView(
        contentView: View(backgroundColor: .gray),
        contentViewConstraints: { contentView, superView in
            contentView.fillSuperview()
        }
    )
    
    public var titlesViewConstraints: AnchoredConstraints?
    public var leadingImageViewConstraints: AnchoredConstraints?
    public var trailingImageViewConstraints: AnchoredConstraints?
    public var secondaryTrailingImageViewConstraints: AnchoredConstraints?
    public var switchControlConstraints: AnchoredConstraints?
    public var statusLeadingImageViewConstraints: AnchoredConstraints?
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
    
    private func setupPriorities() {
        subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        hStackView.addArrangedSubview(leadingImageWrapperView)
        hStackView.addArrangedSubview(titleViewsWrapperView)
        hStackView.addArrangedSubview(subtitleLabel)
        hStackView.addArrangedSubview(secondaryTrailingImageWrapperView)
        hStackView.addArrangedSubview(trailingImageWrapperView)
        hStackView.addArrangedSubview(switchWrapperView)
        hStackView.addArrangedSubview(statusWrapperView)
        
        leadingImageWrapperView.addSubview(leadingImageView)
        trailingImageWrapperView.addSubview(trailingImageView)
        secondaryTrailingImageWrapperView.addSubview(secondaryTrailingImageView)
        titleViewsWrapperView.addSubview(titleViews)
        switchWrapperView.addSubview(switchControl)
        statusWrapperView.addSubview(statusContainerView)
        statusContainerView.addSubviews(statusLeadingImageView, statusLabel)
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
            .centerY(leadingImageWrapperView.centerYAnchor),
            .width(16),
            .height(16, priority: .defaultHigh)
        )
        
        secondaryTrailingImageViewConstraints = secondaryTrailingImageView.anchor(
            .topGreaterThanEqual(secondaryTrailingImageWrapperView.topAnchor),
            .bottomLessThanEqual(secondaryTrailingImageWrapperView.bottomAnchor),
            .top(secondaryTrailingImageWrapperView.topAnchor, priority: .defaultHigh),
            .bottom(secondaryTrailingImageWrapperView.bottomAnchor, priority: .defaultHigh),
            .leading(secondaryTrailingImageWrapperView.leadingAnchor),
            .trailing(secondaryTrailingImageWrapperView.trailingAnchor),
            .centerX(secondaryTrailingImageWrapperView.centerXAnchor),
            .centerY(secondaryTrailingImageWrapperView.centerYAnchor),
            .width(6.25),
            .height(10, priority: .defaultHigh)
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
        
        statusLeadingImageViewConstraints = statusLeadingImageView.anchor(
            .leading(statusContainerView.leadingAnchor, constant: 6),
            .top(statusContainerView.topAnchor, constant: 4),
            .bottom(statusContainerView.bottomAnchor, constant: 4),
            .centerY(statusContainerView.centerYAnchor),
            .height(16),
            .width(16)
        )
        
        statusLabel.anchor(
            .leading(statusLeadingImageView.trailingAnchor, constant: 4),
            .trailing(statusContainerView.trailingAnchor, constant: 6),
            .centerY(statusContainerView.centerYAnchor)
        )
        
        vStackView.anchor(
            .leading(leadingAnchor),
            .top(topAnchor),
            .trailing(trailingAnchor),
            .bottom(bottomAnchor)
        )
        
        statusContainerView.centerInSuperview()
        
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
