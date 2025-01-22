//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 22/1/25.
//

import Foundation

public protocol EmptyViewOutput {
    func display(model: EmptyViewPresentableModel?)
    func display(title: [TextAttributes])
    func display(subtitle: [TextAttributes])
    func display(buttonModel: ButtonPresentableModel?)
    func display(image: ImageViewPresentableModel?)
}

public struct EmptyViewPresentableModel: HashableWithReflection {

    public let title: [TextAttributes]
    public let subTitle: [TextAttributes]
    public let button: ButtonPresentableModel?
    public let image: ImageViewPresentableModel?
    
    public init(
        title: [TextAttributes],
        subTitle: [TextAttributes] = [],
        button: ButtonPresentableModel? = nil,
        image: ImageViewPresentableModel? = nil
    ) {
        self.title = title
        self.subTitle = subTitle
        self.button = button
        self.image = image
    }
}

#if canImport(UIKit)
import UIKit

public class EmptyView: UIView {
    public lazy var stackView = StackView(axis: .vertical, spacing: 16)
    public lazy var imageWrapperView = WrapperView(
        contentView: ImageView(),
        contentViewConstraints: { contentView, superView in
            contentView.anchor(
                .top(superView.topAnchor),
                .leadingGreaterThanEqual(superView.leadingAnchor),
                .width(0),
                .height(0),
                .centerX(superView.centerXAnchor),
                .trailingLessThanEqual(superView.trailingAnchor),
                .bottom(superView.bottomAnchor)
            )
        }
    )
    
    public lazy var titleLabel = Label()
    public lazy var subTitleLabel = Label()
    public lazy var button = Button()
    
    public init() {
        super.init(frame: .zero)
        
        setupViews()
        setupConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(stackView)
        stackView.addArrangedSubviews(
            imageWrapperView,
            titleLabel,
            subTitleLabel,
            button
        )
    }
    
    func setupConstraints() {
        stackView.anchor(
            .topGreaterThanEqual(topAnchor),
            .bottomLessThanEqual(bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor),
            .centerY(centerYAnchor)
        )
    }
}

extension EmptyView: EmptyViewOutput {
    public func display(image: ImageViewPresentableModel?) {
        imageWrapperView.contentView.display(model: image)
    }
    
    public func display(title: [TextAttributes]) {
        titleLabel.isHidden = title.isEmpty
        titleLabel.removeAttributes()
        title.forEach { titleLabel.append($0) }
    }
   
    public func display(subtitle: [TextAttributes]) {
        subTitleLabel.isHidden = subtitle.isEmpty
        subTitleLabel.removeAttributes()
        subtitle.forEach { subTitleLabel.append($0) }
    }
    
    public func display(buttonModel: ButtonPresentableModel?) {
        button.isHidden = buttonModel == nil
        guard let buttonModel else { return }
        button.setTitle(buttonModel.title, for: .normal)
        button.spacing = buttonModel.spacing
        button.onPress = buttonModel.onPress
        button.style = buttonModel.style
    }
    
    public func display(model: EmptyViewPresentableModel?) {
        self.isHidden = model == nil
        guard let model else { return }
        titleLabel.removeAttributes()
        model.title.forEach {
            titleLabel.append($0)
        }
        subTitleLabel.removeAttributes()
        model.subTitle.forEach {
            subTitleLabel.append($0)
        }
        
        button.display(model: model.button)
        imageWrapperView.contentView.display(model: model.image)
    }
}
#endif
