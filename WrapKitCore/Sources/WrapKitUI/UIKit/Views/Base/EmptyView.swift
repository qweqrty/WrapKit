import Foundation

public protocol EmptyViewOutput: AnyObject {
    func display(model: EmptyViewPresentableModel?)
    func display(title: TextOutputPresentableModel?)
    func display(subtitle: TextOutputPresentableModel?)
    func display(buttonModel: ButtonPresentableModel?)
    func display(image: ImageViewPresentableModel?)
    func display(isHidden: Bool)
}

public struct EmptyViewAnimationConfig: HashableWithReflection {
    public let isAnimated: Bool
    public let duration: TimeInterval
    
    public init(
        isAnimated: Bool = false,
        duration: TimeInterval = 0.3
    ) {
        self.isAnimated = isAnimated
        self.duration = duration
    }
    
    public static let `default` = EmptyViewAnimationConfig()
}

public struct EmptyViewPresentableModel: HashableWithReflection {
    public let title: TextOutputPresentableModel?
    public let subTitle: TextOutputPresentableModel?
    public let button: ButtonPresentableModel?
    public let image: ImageViewPresentableModel?
    public let animationConfig: EmptyViewAnimationConfig
    
    public init(
        title: TextOutputPresentableModel?,
        subTitle: TextOutputPresentableModel? = nil,
        button: ButtonPresentableModel? = nil,
        image: ImageViewPresentableModel? = nil,
        animationConfig: EmptyViewAnimationConfig = .default
    ) {
        self.title = title
        self.subTitle = subTitle
        self.button = button
        self.image = image
        self.animationConfig = animationConfig
    }
}

#if canImport(UIKit)
import UIKit

public class EmptyView: UIView {
    private var visibilityAnimator: UIViewPropertyAnimator?

    public lazy var stackView = StackView(
        axis: .vertical,
        spacing: 16,
        contentInset: .init(top: 12, left: 12, bottom: 12, right: 12)
    )
    
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
        setHidden(
            model == nil,
            animated: model?.animationConfig.isAnimated ?? true,
            duration: model?.animationConfig.duration ?? 0.3
        )
        
        // Update content without animation
        UIView.performWithoutAnimation {
            display(title: model?.title)
            display(subtitle: model?.subTitle)
            display(buttonModel: model?.button)
            display(image: model?.image)
        }
    }
    
    public func display(isHidden: Bool) {
        setHidden(isHidden, animated: false)
    }
    
    private func setHidden(_ isHidden: Bool, animated: Bool, duration: TimeInterval = 0.3) {
        guard animated else {
            visibilityAnimator?.stopAnimation(true)
            visibilityAnimator = nil
            self.isHidden = isHidden
            self.alpha = isHidden ? 0 : 1
            return
        }

        // Cancel any in-flight animation
        visibilityAnimator?.stopAnimation(true)
        visibilityAnimator = nil

        // Find a layout container to animate with (important for UIStackView)
        // Prefer superview; if inside a stack view, animating its layout fixes collapsing.
        let layoutContainer = self.superview ?? self

        if isHidden {
            // If already hidden, nothing to do
            guard !self.isHidden else { return }

            // Make sure we start from visible state
            self.alpha = 1

            let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
                self.alpha = 0
                layoutContainer.layoutIfNeeded()
            }

            animator.addCompletion { [weak self] _ in
                guard let self else { return }
                // Only finalize if no newer animation started
                self.isHidden = true
                self.alpha = 0
            }

            visibilityAnimator = animator
            animator.startAnimation()

        } else {
            // Show: unhide first, then animate alpha in
            self.isHidden = false
            self.alpha = 0

            // Force layout so stack view computes correct size before fade in
            layoutContainer.setNeedsLayout()
            layoutContainer.layoutIfNeeded()

            let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
                self.alpha = 1
                layoutContainer.layoutIfNeeded()
            }

            animator.addCompletion { [weak self] _ in
                guard let self else { return }
                self.alpha = 1
            }

            visibilityAnimator = animator
            animator.startAnimation()
        }
    }

}
#endif
