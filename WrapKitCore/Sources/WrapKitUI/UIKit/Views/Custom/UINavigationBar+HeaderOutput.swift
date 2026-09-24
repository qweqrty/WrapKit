#if canImport(UIKit)
import UIKit
import ObjectiveC

private var nativeHeaderStateKey: UInt8 = 0

extension UINavigationBar: HeaderOutput {
    /// For a standalone bar, display methods create an item if necessary.
    /// In a navigation controller, bind the presenter using `headerOutput(for:)`
    /// so updates from an inactive screen cannot change the visible screen.
    private var currentHeaderOutput: NativeHeaderOutput {
        if let item = topItem { return item.nativeHeaderOutput }
        let item = UINavigationItem()
        setItems([item], animated: false)
        return item.nativeHeaderOutput
    }

    /// The navigation item retains the output, including when the presenter uses
    /// `weakReferenced`. The output holds only weak references to its owners.
    public func headerOutput(for viewController: UIViewController) -> any HeaderOutput {
        let output = viewController.navigationItem.nativeHeaderOutput
        output.viewController = viewController
        output.navigationBar = self
        return output
    }

    /// Call from the owning controller's `viewWillAppear`, after `super`, to
    /// restore visibility on push/pop. Do not hide the bar in viewWillDisappear.
    public func activateHeader(for viewController: UIViewController, animated: Bool = false) {
        let output = viewController.navigationItem.nativeHeaderOutput
        output.viewController = viewController
        output.navigationBar = self
        if let navigationController = viewController.navigationController,
           navigationController.navigationBar === self {
            navigationController.setNavigationBarHidden(output.hidden, animated: animated)
            viewController.transitionCoordinator?.notifyWhenInteractionChanges { [weak self] context in
                guard context.isCancelled,
                      let restored = context.viewController(forKey: .from),
                      let self else { return }
                let restoredOutput = restored.navigationItem.nativeHeaderOutput
                navigationController.setNavigationBarHidden(restoredOutput.hidden, animated: true)
                self.setNeedsLayout()
            }
        } else {
            isHidden = output.hidden
        }
    }

    public func display(model: HeaderPresentableModel?) {
        currentHeaderOutput.navigationBar = self
        currentHeaderOutput.display(model: model)
    }

    public func display(style: HeaderPresentableModel.Style?) {
        currentHeaderOutput.display(style: style)
    }

    public func display(centerView: HeaderPresentableModel.CenterView?) {
        currentHeaderOutput.display(centerView: centerView)
    }

    public func display(leadingCard: CardViewPresentableModel?) {
        currentHeaderOutput.display(leadingCard: leadingCard)
    }

    public func display(primeTrailingImage: ButtonPresentableModel?) {
        currentHeaderOutput.display(primeTrailingImage: primeTrailingImage)
    }

    public func display(secondaryTrailingImage: ButtonPresentableModel?) {
        currentHeaderOutput.display(secondaryTrailingImage: secondaryTrailingImage)
    }

    public func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        currentHeaderOutput.display(tertiaryTrailingImage: tertiaryTrailingImage)
    }

    public func display(isHidden: Bool) {
        currentHeaderOutput.navigationBar = self
        currentHeaderOutput.display(isHidden: isHidden)
    }
}

private extension UINavigationItem {
    var nativeHeaderOutput: NativeHeaderOutput {
        if let output = objc_getAssociatedObject(self, &nativeHeaderStateKey) as? NativeHeaderOutput {
            return output
        }
        let output = NativeHeaderOutput(item: self)
        objc_setAssociatedObject(self, &nativeHeaderStateKey, output, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return output
    }
}

private final class NativeHeaderOutput: HeaderOutput {
    weak var viewController: UIViewController?
    weak var navigationBar: UINavigationBar?
    private weak var item: UINavigationItem?
    private(set) var hidden = false

    private let titles = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 18), textColor: .black, textAlignment: .center, numberOfLines: 1),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)
    )
    private let titledImage: TitledView<WrapperView<ImageView>> = {
        let view = TitledView(contentView: WrapperView(
            contentView: ImageView(),
            contentViewConstraints: { contentView, _ in contentView.centerInSuperview() }
        ))
        view.closingTitleVFieldView.keyLabel.textAlignment = .center
        view.closingTitleVFieldView.valueLabel.textAlignment = .center
        view.closingTitleVFieldView.isHidden = false
        return view
    }()
    private let card: CardView = {
        let view = CardView()
        view.vStackView.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
        view.hStackView.spacing = 8
        view.bottomSeparatorView.isHidden = true
        view.trailingImageWrapperView.isHidden = true
        view.subtitleLabel.isHidden = true
        view.subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.subtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }()
    private let trailing = UIStackView()
    private let buttons: [Button] = (0..<3).map { _ in
        let button = Button(contentInset: isAvailableOS26 && isLiquidGlassEnabled
            ? .init(top: 11, left: 11, bottom: 11, right: 11)
            : .init(top: 0, left: 8, bottom: 0, right: 8))
        #if os(iOS)
        if #available(iOS 26, *) {
            button.configuration = .glass()
            button.configuration?.cornerStyle = .capsule
        }
        #endif
        button.isHidden = true
        return button
    }
    private var visibleButtons = [false, false, false]
    private var cardConstraints: [NSLayoutConstraint] = []
    private lazy var titleHost = NativeHeaderContentView(content: titles)
    private lazy var imageHost = NativeHeaderContentView(content: titledImage)
    private lazy var trailingHost = NativeHeaderContentView(content: trailing)
    private let leadingHost = UIView()
    private lazy var leadingSizedHost = NativeHeaderContentView(content: leadingHost)
    private lazy var leadingItem = makeBarItem(leadingSizedHost)
    private lazy var trailingItem = makeBarItem(trailingHost)
    private lazy var glass: UIView = {
        #if os(iOS)
        if #available(iOS 26, *) {
            let effect = UIGlassEffect(style: .regular)
            effect.isInteractive = true
            let view = UIVisualEffectView(effect: effect)
            view.cornerConfiguration = .capsule()
            return view
        }
        #endif
        return UIView()
    }()

    init(item: UINavigationItem) {
        self.item = item
        item.hidesBackButton = true
        item.largeTitleDisplayMode = .never
        item.titleView = UIView()
        trailing.axis = .horizontal
        trailing.alignment = .center
        trailing.spacing = 12
        buttons.forEach { trailing.addArrangedSubview($0) }
    }

    func display(model: HeaderPresentableModel?) {
        display(isHidden: model == nil)
        guard let model else { return }
        // Preserve the legacy renderer's styling precedence.
        display(centerView: model.centerView)
        display(style: model.style)
        display(leadingCard: model.leadingCard)
        display(primeTrailingImage: model.primeTrailingImage)
        display(secondaryTrailingImage: model.secondaryTrailingImage)
        display(tertiaryTrailingImage: model.tertiaryTrailingImage)
    }

    func display(style: HeaderPresentableModel.Style?) {
        guard let style else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = style.backgroundColor
        appearance.shadowColor = .clear
        item?.standardAppearance = appearance
        item?.scrollEdgeAppearance = appearance
        item?.compactAppearance = appearance
        item?.compactScrollEdgeAppearance = appearance
        trailing.spacing = style.horizontalSpacing * 1.5
        card.leadingImageView.tintColor = style.primeColor
        buttons.forEach { $0.tintColor = style.primeColor }
        card.titleViews.keyLabel.font = style.primeFont
        card.titleViews.keyLabel.textColor = style.primeColor
        titles.keyLabel.font = style.primeFont
        titles.keyLabel.textColor = style.primeColor
        titles.keyLabel.numberOfLines = style.numberOfLines
        titledImage.closingTitleVFieldView.keyLabel.font = style.secondaryFont
        titledImage.closingTitleVFieldView.keyLabel.textColor = style.secondaryColor
        invalidateLayout()
    }

    func display(centerView: HeaderPresentableModel.CenterView?) {
        switch centerView {
        case .keyValue(let pair):
            titles.display(model: pair)
            item?.titleView = pair.first == nil && pair.second == nil ? nil : titleHost
        case .titledImage(let pair):
            titledImage.closingTitleVFieldView.keyLabel.display(model: pair.second)
            titledImage.contentView.contentView.display(model: pair.first)
            item?.titleView = pair.first == nil && pair.second == nil ? nil : imageHost
        case nil:
            item?.titleView = nil
        }
        // An empty custom title suppresses fallback to the controller's title.
        if item?.titleView == nil { item?.titleView = UIView() }
        invalidateLayout()
    }

    func display(leadingCard: CardViewPresentableModel?) {
        card.display(model: leadingCard)
        guard leadingCard != nil else {
            item?.leftBarButtonItem = nil
            return
        }
        NSLayoutConstraint.deactivate(cardConstraints)
        card.removeFromSuperview()
        glass.removeFromSuperview()
        let interactive = !(card.gestureRecognizers?.isEmpty ?? true)
        let parent: UIView
        if interactive {
            leadingHost.addSubview(glass)
            parent = (glass as? UIVisualEffectView)?.contentView ?? glass
            cardConstraints = pin(glass, to: leadingHost)
        } else {
            parent = leadingHost
            cardConstraints = []
        }
        parent.addSubview(card)
        cardConstraints += pin(card, to: parent)
        item?.leftBarButtonItem = leadingItem
        invalidateLayout()
    }

    func display(primeTrailingImage: ButtonPresentableModel?) { display(button: primeTrailingImage, at: 0) }
    func display(secondaryTrailingImage: ButtonPresentableModel?) { display(button: secondaryTrailingImage, at: 1) }
    func display(tertiaryTrailingImage: ButtonPresentableModel?) { display(button: tertiaryTrailingImage, at: 2) }

    private func display(button: ButtonPresentableModel?, at index: Int) {
        visibleButtons[index] = button != nil
        buttons[index].display(model: button)
        buttons[index].isHidden = button == nil
        // One group preserves prime/secondary/tertiary order and model spacing.
        item?.rightBarButtonItem = visibleButtons.contains(true) ? trailingItem : nil
        invalidateLayout()
    }

    func display(isHidden: Bool) {
        hidden = isHidden
        if let controller = viewController {
            guard let navigationController = controller.navigationController,
                  navigationController.topViewController === controller,
                  navigationController.navigationBar === navigationBar else { return }
            navigationController.setNavigationBarHidden(isHidden, animated: false)
        } else if navigationBar?.topItem === item {
            navigationBar?.isHidden = isHidden
        }
    }

    private func invalidateLayout() {
        titleHost.invalidateIntrinsicContentSize()
        imageHost.invalidateIntrinsicContentSize()
        trailingHost.invalidateIntrinsicContentSize()
        leadingHost.invalidateIntrinsicContentSize()
        leadingSizedHost.invalidateIntrinsicContentSize()
        leadingHost.setNeedsLayout()
        navigationBar?.setNeedsLayout()
    }

    private func makeBarItem(_ view: UIView) -> UIBarButtonItem {
        let item = UIBarButtonItem(customView: view)
        #if os(iOS)
        if #available(iOS 26, *) {
            // The content already supplies the same glass as NavigationBar.
            item.hidesSharedBackground = true
        }
        #endif
        return item
    }

    private func pin(_ view: UIView, to parent: UIView) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            view.topAnchor.constraint(equalTo: parent.topAnchor),
            view.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}

/// Exposes Auto Layout content size to UINavigationBar without fixing the bar's
/// height or caching a screen width. UIKit remains responsible for compact bars.
private final class NativeHeaderContentView: UIView {
    private let content: UIView

    init(content: UIView) {
        self.content = content
        super.init(frame: .zero)
        addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override var intrinsicContentSize: CGSize {
        content.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fitting = content.systemLayoutSizeFitting(
            CGSize(width: size.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: min(size.width, fitting.width), height: min(size.height, fitting.height))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
#endif
