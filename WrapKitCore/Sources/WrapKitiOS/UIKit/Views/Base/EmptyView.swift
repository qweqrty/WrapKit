import Foundation

public protocol EmptyViewOutput: AnyObject {
    func display(model: EmptyViewPresentableModel?)
    func display(title: TextOutputPresentableModel?)
    func display(subtitle: TextOutputPresentableModel?)
    func display(buttonModel: ButtonPresentableModel?)
    func display(image: ImageViewPresentableModel?)
}

public struct EmptyViewPresentableModel: HashableWithReflection {
    public let title: TextOutputPresentableModel?
    public let subTitle: TextOutputPresentableModel?
    public let button: ButtonPresentableModel?
    public let image: ImageViewPresentableModel?
    
    public init(
        title: TextOutputPresentableModel?,
        subTitle: TextOutputPresentableModel? = nil,
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
        imageWrapperView.isHidden = image == nil
        imageWrapperView.contentView.display(model: image)
    }
    
    public func display(title: TextOutputPresentableModel?) {
        titleLabel.isHidden = title == nil
        titleLabel.display(model: title)
    }
   
    public func display(subtitle: TextOutputPresentableModel?) {
        subTitleLabel.isHidden = subtitle == nil
        subTitleLabel.display(model: subtitle)
    }
    
    public func display(buttonModel: ButtonPresentableModel?) {
        button.isHidden = buttonModel == nil
        guard let buttonModel else { return }
        button.setTitle(buttonModel.title, for: .normal)
        if let spacing = buttonModel.spacing { button.spacing = spacing }
        button.onPress = buttonModel.onPress
        button.display(style: buttonModel.style)
    }
    
    public func display(model: EmptyViewPresentableModel?) {
        self.isHidden = model == nil
        guard let model else { return }
        display(title: model.title)
        display(subtitle: model.subTitle)
        display(buttonModel: model.button)
        display(image: model.image)
    }
}
#endif
