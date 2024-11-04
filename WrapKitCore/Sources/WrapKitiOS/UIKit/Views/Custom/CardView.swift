//
//  CardView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

import Foundation

public protocol CardViewOutput: AnyObject {
    func display(model: CardViewPresentableModel)
}

public struct CardViewPresentableModel: HashableWithReflection {
    public struct Image {
        public let image: ImageEnum
        public let size: CGSize
        
        public init(image: ImageEnum, size: CGSize) {
            self.image = image
            self.size = size
        }
    }
    
    public let title: [TextAttributes]
    public let leadingImage: Image?
    public let trailingImage: Image?
    public let subTitle: [TextAttributes]
    public let valueTitle: [TextAttributes]
    public let separatorColor: Color?
    
    public init(
        title: [TextAttributes] = [],
        leadingImage: Image? = nil,
        trailingImage: Image? = nil,
        subTitle: [TextAttributes] = [],
        valueTitle: [TextAttributes] = [],
        separatorColor: Color? = nil
    ) {
        self.title = title
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
        self.subTitle = subTitle
        self.valueTitle = valueTitle
        self.separatorColor = separatorColor
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUI

extension CardView: CardViewOutput {
    public func display(model: CardViewPresentableModel) {
        // Key title
        titleViews.keyLabel.isHidden = model.title.isEmpty
        titleViews.keyLabel.removeAttributes()
        model.title.forEach { titleViews.keyLabel.append($0) }
        // Value title
        titleViews.valueLabel.removeAttributes()
        titleViews.valueLabel.isHidden = model.valueTitle.isEmpty
        model.valueTitle.forEach { attribute in
            titleViews.valueLabel.append(attribute)
        }
        
        // Subtitle
        subtitleLabel.isHidden = model.subTitle.isEmpty
        subtitleLabel.removeAttributes()
        model.valueTitle.forEach { attribute in
            subtitleLabel.append(attribute)
        }
        
        // LeadingImage
        leadingImageWrapperView.isHidden = model.leadingImage == nil
        leadingImageViewConstraints?.width?.constant = model.leadingImage?.size.width ?? 0
        leadingImageViewConstraints?.height?.constant = model.leadingImage?.size.height ?? 0
        
        leadingImageView.setImage(model.leadingImage?.image)
        
        // TrailingImage
        trailingImageWrapperView.isHidden = model.trailingImage == nil
        trailingImageViewConstraints?.width?.constant = model.trailingImage?.size.width ?? 0
        trailingImageViewConstraints?.height?.constant = model.trailingImage?.size.height ?? 0
        trailingImageView.setImage(model.trailingImage?.image)
        
        // bottomSeparatorView
        bottomSeparatorView.contentView.backgroundColor = model.separatorColor
        bottomSeparatorView.isHidden = model.separatorColor == nil
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
    
    public let trailingImageWrapperView = UIView()
    public let trailingImageView = ImageView(image: UIImage(named: "rightArrow"), tintColor: .black)
    
    public let switchWrapperView = UIView(isHidden: true)
    public lazy var switchControl = SwitchControl()
    
    public let bottomSeparatorView = WrapperView(
        contentView: View(backgroundColor: .gray),
        contentViewConstraints: { contentView, superView in
            contentView.fillSuperview()
        }
    )
    
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
        hStackView.addArrangedSubview(trailingImageWrapperView)
        hStackView.addArrangedSubview(switchWrapperView)
        
        leadingImageWrapperView.addSubview(leadingImageView)
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
