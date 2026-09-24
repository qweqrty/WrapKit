#if canImport(UIKit)
import UIKit
import ObjectiveC

private var nativeHeaderStateKey: UInt8 = 0

public extension UIViewController {
    /// Retained by this screen's navigation item; safe to bind before push.
    var headerOutput: NavigationItemHeaderOutput {
        let output = navigationItem.nativeHeaderOutput
        output.viewController = self
        output.navigationBar = navigationController?.navigationBar
        return output
    }

    /// Restores this screen's visibility without installing a navigation delegate.
    func activateNavigationHeader(animated: Bool = false) {
        guard let navigationController else { return }
        if objc_getAssociatedObject(navigationItem, &nativeHeaderStateKey) == nil {
            // Keep headerless screens hidden, including cancelled interactive pops.
            headerOutput.display(isHidden: true)
        }
        navigationController.navigationBar.activateHeader(for: self, animated: animated)
    }
}

extension UINavigationBar: HeaderOutput {
    /// For a standalone bar, display methods create an item if necessary.
    /// In a navigation controller, bind the presenter using `headerOutput(for:)`
    /// so updates from an inactive screen cannot change the visible screen.
    private var currentHeaderOutput: NavigationItemHeaderOutput {
        if let item = topItem { return item.nativeHeaderOutput }
        let item = UINavigationItem()
        setItems([item], animated: false)
        return item.nativeHeaderOutput
    }

    /// Available before the first title model, so a factory can wire an existing shimmer.
    public var headerTitleLabel: Label { currentHeaderOutput.headerTitleLabel }

    public func display(primeTrailingMenu menu: UIMenu?) {
        currentHeaderOutput.display(primeTrailingMenu: menu)
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
                let restoredOutput = objc_getAssociatedObject(restored.navigationItem, &nativeHeaderStateKey) as? NavigationItemHeaderOutput
                navigationController.setNavigationBarHidden(restoredOutput?.hidden ?? true, animated: true)
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
    var nativeHeaderOutput: NavigationItemHeaderOutput {
        if let output = objc_getAssociatedObject(self, &nativeHeaderStateKey) as? NavigationItemHeaderOutput {
            return output
        }
        let output = NavigationItemHeaderOutput(item: self)
        objc_setAssociatedObject(self, &nativeHeaderStateKey, output, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return output
    }
}

public final class NavigationItemHeaderOutput: HeaderOutput {
    weak var viewController: UIViewController?
    weak var navigationBar: UINavigationBar?
    private weak var item: UINavigationItem?
    private(set) var hidden = false

    private let titles = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 18), textColor: .black, textAlignment: .center, numberOfLines: 1),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)
    )
    public var headerTitleLabel: Label { titles.keyLabel }

    public func display(primeTrailingMenu menu: UIMenu?) {
        primeTrailingMenu = menu
        renderedTrailingItems[0]?.menu = menu
        if renderedTrailingItems[0]?.customView == nil {
            renderedTrailingItems[0]?.primaryAction = menu == nil ? primeTrailingAction : nil
        }
        buttons[0]?.menu = menu
        buttons[0]?.showsMenuAsPrimaryAction = menu != nil
    }

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
    private var headerStyle: HeaderPresentableModel.Style?
    private var isUpdatingModel = false
    private var cardStorage: CardView?
    private var card: CardView {
        if let cardStorage { return cardStorage }
        let view = CardView()
        view.vStackView.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
        view.hStackView.spacing = 8
        view.bottomSeparatorView.isHidden = true
        view.trailingImageWrapperView.isHidden = true
        view.subtitleLabel.isHidden = true
        view.subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.subtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        if let style = headerStyle {
            view.leadingImageView.tintColor = style.primeColor
            view.titleViews.keyLabel.font = style.primeFont
            view.titleViews.keyLabel.textColor = style.primeColor
        }
        cardStorage = view
        return view
    }
    private var buttons: [Button?] = [nil, nil, nil]
    private var buttonEnabled = [true, true, true]
    private func customButton(at index: Int) -> Button {
        if let button = buttons[index] { return button }
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
        button.tintColor = primeColor
        buttons[index] = button
        return button
    }
    private var visibleButtons = [false, false, false]
    private var renderedTrailingItems: [UIBarButtonItem?] = [nil, nil, nil]
    private var primeTrailingAction: UIAction?
    private var primeTrailingMenu: UIMenu?
    private var primeColor: UIColor?
    private var hasCustomLeadingStyle = false
    private var hasCustomButtonStyle = [false, false, false]

    private var cardConstraints: [NSLayoutConstraint] = []
    private lazy var titleHost = makeTitleHost(titles)
    private lazy var imageHost = makeTitleHost(titledImage)
    private let leadingHost = UIView()
    private lazy var leadingSizedHost = NativeHeaderContentView(content: leadingHost)
    private lazy var leadingItem = makeBarItem(leadingSizedHost)
    private var trailingItems: [UIBarButtonItem?] = [nil, nil, nil]
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
        item.leftItemsSupplementBackButton = false
    }

    public func display(model: HeaderPresentableModel?) {
        display(isHidden: model == nil)
        guard let model else { return }
        isUpdatingModel = true
        defer {
            isUpdatingModel = false
            updateTrailingItems()
            invalidateLayout()
        }
        // Preserve the legacy renderer's styling precedence.
        display(centerView: model.centerView)
        display(style: model.style)
        display(leadingCard: model.leadingCard)
        display(primeTrailingImage: model.primeTrailingImage)
        display(secondaryTrailingImage: model.secondaryTrailingImage)
        display(tertiaryTrailingImage: model.tertiaryTrailingImage)
    }

    public func display(style: HeaderPresentableModel.Style?) {
        guard let style else { return }
        headerStyle = style
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = style.backgroundColor
        appearance.shadowColor = .clear
        item?.standardAppearance = appearance
        item?.scrollEdgeAppearance = appearance
        item?.compactAppearance = appearance
        item?.compactScrollEdgeAppearance = appearance
        primeColor = style.primeColor
        item?.leftBarButtonItem?.tintColor = style.primeColor
        if let button = item?.leftBarButtonItem?.customView as? AdaptiveHeaderButton {
            button.titleFont = style.primeFont
            button.tintColor = style.primeColor
        }
        renderedTrailingItems.compactMap { $0 }.forEach { $0.tintColor = style.primeColor }
        cardStorage?.leadingImageView.tintColor = style.primeColor
        buttons.compactMap { $0 }.forEach { $0.tintColor = style.primeColor }
        cardStorage?.titleViews.keyLabel.font = style.primeFont
        cardStorage?.titleViews.keyLabel.textColor = style.primeColor
        titles.keyLabel.font = style.primeFont
        titles.keyLabel.textColor = style.primeColor
        titles.keyLabel.numberOfLines = style.numberOfLines
        titledImage.closingTitleVFieldView.keyLabel.font = style.secondaryFont
        titledImage.closingTitleVFieldView.keyLabel.textColor = style.secondaryColor
        invalidateLayout()
    }

    public func display(centerView: HeaderPresentableModel.CenterView?) {
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

    public func display(leadingCard: CardViewPresentableModel?) {
        if leadingCard?.style != nil { hasCustomLeadingStyle = true }
        guard leadingCard != nil else {
            item?.leftBarButtonItem = nil
            return
        }
        // A simple back/close icon is a native action, so UIKit can relocate it.
        // Rich cards retain the existing renderer and all their callbacks.
        if let model = leadingCard,
           isPlainTitle(model.title), model.leadingTitles == nil, model.trailingTitles == nil,
           model.subTitle == nil, model.valueTitle == nil, model.backgroundImage == nil,
           model.secondaryLeadingImage == nil, model.trailingImage == nil,
           model.secondaryTrailingImage == nil, model.bottomImage == nil,
           model.bottomSeparator == nil, model.switchControl == nil,
           !hasCustomLeadingStyle, !model.isGradientBorderEnabled,
           model.onLongPress == nil, model.leadingImage?.onLongPress == nil,
           case let .asset(image)? = model.leadingImage?.image, let image {
            let action = UIAction(
                title: model.title?.model?.text ?? "",
                image: image
            ) { _ in (model.onPress ?? model.leadingImage?.onPress)?() }
            let nativeItem: UIBarButtonItem
            if let title = model.title?.model?.text, !title.isEmpty {
                let button = AdaptiveHeaderButton(
                    title: title, image: image, font: headerStyle?.primeFont, action: action
                )
                button.tintColor = primeColor
                button.isEnabled = model.isUserInteractionEnabled ?? true
                button.accessibilityIdentifier = model.accessibilityIdentifier
                button.accessibilityLabel = model.accessibility?.label ?? title
                button.accessibilityHint = model.accessibility?.hint
                nativeItem = UIBarButtonItem(customView: button)
            } else {
                nativeItem = UIBarButtonItem(primaryAction: action)
            }
            nativeItem.tintColor = primeColor
            nativeItem.isEnabled = model.isUserInteractionEnabled ?? true
            nativeItem.accessibilityIdentifier = model.accessibilityIdentifier
            nativeItem.accessibilityLabel = model.accessibility?.label ?? model.leadingImage?.accessibility?.label
            nativeItem.accessibilityHint = model.accessibility?.hint
            #if os(iOS)
            if #available(iOS 26, *) { nativeItem.sharesBackground = false }
            if #available(iOS 27.1, *) { nativeItem.axisBehavior = .verticalPreferred }
            #endif
            item?.leftBarButtonItem = nativeItem
            invalidateLayout()
            return
        }
        card.display(model: leadingCard)
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
        leadingItem.title = leadingCard?.accessibility?.label
        leadingItem.accessibilityIdentifier = leadingCard?.accessibilityIdentifier
        #if os(iOS)
        if #available(iOS 27.1, *) {
            let size = leadingSizedHost.intrinsicContentSize
            leadingItem.axisBehavior = size.width <= 44 && size.height <= 44
                ? .verticalPreferred : .horizontalOnly
        }
        #endif
        item?.leftBarButtonItem = leadingItem
        invalidateLayout()
    }

    public func display(primeTrailingImage: ButtonPresentableModel?) { display(button: primeTrailingImage, at: 0) }
    public func display(secondaryTrailingImage: ButtonPresentableModel?) { display(button: secondaryTrailingImage, at: 1) }
    public func display(tertiaryTrailingImage: ButtonPresentableModel?) { display(button: tertiaryTrailingImage, at: 2) }

    private func isPlainTitle(_ title: TextOutputPresentableModel?) -> Bool {
        guard let model = title?.model else { return true }
        if case .text = model { return true }
        return false
    }

    private func display(button: ButtonPresentableModel?, at index: Int) {
        visibleButtons[index] = button != nil
        if button?.style != nil { hasCustomButtonStyle[index] = true }
        guard let button else {
            buttons[index]?.display(model: nil)
            renderedTrailingItems[index] = nil
            updateTrailingItems()
            invalidateLayout()
            return
        }
        if let enabled = button.enabled { buttonEnabled[index] = enabled }
        let barItem: UIBarButtonItem
        if !hasCustomButtonStyle[index], button.height == nil, button.width == nil, button.spacing == nil {
            let model = button
            let action = UIAction(title: model.title ?? model.accessibility?.label ?? "", image: model.image) { _ in
                model.onPress?()
            }
            let native = UIBarButtonItem(primaryAction: action)
            native.tintColor = primeColor
            native.isEnabled = buttonEnabled[index]
            native.accessibilityLabel = model.accessibility?.label
            native.accessibilityHint = model.accessibility?.hint
            barItem = native
        } else {
            let custom = customButton(at: index)
            custom.display(model: button)
            custom.display(enabled: buttonEnabled[index])
            if index == 0 {
                custom.menu = primeTrailingMenu
                custom.showsMenuAsPrimaryAction = primeTrailingMenu != nil
            }
            if trailingItems[index] == nil {
                trailingItems[index] = makeBarItem(NativeHeaderContentView(content: custom))
            }
            barItem = trailingItems[index]!
        }
        renderedTrailingItems[index] = barItem
        if index == 0 {
            primeTrailingAction = barItem.primaryAction
            barItem.menu = primeTrailingMenu
            if primeTrailingMenu != nil { barItem.primaryAction = nil }
        }
        barItem.title = button.title ?? button.accessibility?.label
        barItem.accessibilityIdentifier = button.accessibilityIdentifier
        #if os(iOS)
        if #available(iOS 26, *) { barItem.sharesBackground = false }
        if #available(iOS 27.1, *) {
            if let custom = barItem.customView {
                let size = custom.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                barItem.axisBehavior = button.title == nil && size.width <= 44 && size.height <= 44
                    ? .verticalPreferred : .horizontalOnly
            } else if button.image != nil {
                barItem.axisBehavior = .verticalPreferred
            }
        }
        #endif
        updateTrailingItems()
        invalidateLayout()
    }

    private func updateTrailingItems() {
        guard !isUpdatingModel else { return }
        // UIKit lists trailing items from the outer edge inward.
        item?.rightBarButtonItems = renderedTrailingItems.reversed().compactMap { $0 }
    }

    public func display(isHidden: Bool) {
        hidden = isHidden
        if let controller = viewController {
            guard let navigationController = controller.navigationController,
                  navigationController.topViewController === controller else { return }
            navigationBar = navigationController.navigationBar
            navigationController.setNavigationBarHidden(isHidden, animated: false)
        } else if navigationBar?.topItem === item {
            navigationBar?.isHidden = isHidden
        }
    }

    private func invalidateLayout() {
        guard !isUpdatingModel else { return }
        // Do not initialize unused custom controls while updating native items.
        item?.titleView?.invalidateIntrinsicContentSize()
        renderedTrailingItems.compactMap { $0?.customView }.forEach {
            $0.invalidateIntrinsicContentSize()
        }
        item?.leftBarButtonItem?.customView?.invalidateIntrinsicContentSize()
        item?.leftBarButtonItem?.customView?.setNeedsLayout()
        navigationBar?.setNeedsLayout()
    }

    private func makeTitleHost(_ content: UIView) -> UIView {
        NativeHeaderTitleView(content: content)
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

/// UIKit moves this item between horizontal and vertical bars. Only its label
/// adapts to the system bar environment; there are no device or width checks.
private final class AdaptiveHeaderButton: UIButton {
    private let headerTitle: String
    private let headerImage: UIImage
    private var configuredVerticalBar: Bool?
    private var configuredFont: UIFont?
    var titleFont: UIFont? {
        didSet { setNeedsUpdateConfiguration() }
    }

    init(title: String, image: UIImage, font: UIFont?, action: UIAction) {
        headerTitle = title
        headerImage = image
        titleFont = font
        super.init(frame: .zero)
        addAction(action, for: .touchUpInside)
        #if os(iOS)
        if #available(iOS 27.1, *) {
            registerForTraitChanges(UITraitCollection.systemTraitsAffectingVerticalBarEdge) {
                (button: AdaptiveHeaderButton, _: UITraitCollection) in
                button.setNeedsUpdateConfiguration()
            }
        }
        #endif
        updateConfiguration()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        setNeedsUpdateConfiguration()
    }

    override func updateConfiguration() {
        super.updateConfiguration()
        var usesVerticalBar = false
        #if os(iOS)
        if #available(iOS 27.1, *) {
            usesVerticalBar = traitCollection.verticalBarEdge != .unspecified
        }
        #endif
        guard configuredVerticalBar != usesVerticalBar || configuredFont != titleFont else { return }
        configuredVerticalBar = usesVerticalBar
        configuredFont = titleFont
        var config = UIButton.Configuration.plain()
        config.image = headerImage
        config.title = usesVerticalBar ? nil : headerTitle
        config.imagePadding = usesVerticalBar ? 0 : 8
        config.contentInsets = .init(top: 11, leading: 11, bottom: 11, trailing: 11)
        if let titleFont {
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = titleFont
                return outgoing
            }
        }
        configuration = config
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// Centers content inside the title slot allocated by UIKit. The screen's center
/// can lie outside that slot when the native bar groups its trailing controls.
private final class NativeHeaderTitleView: UIView {
    private let content: UIView
    private var contentWidth: NSLayoutConstraint!
    private var measuredSize: CGSize?

    init(content: UIView) {
        self.content = content
        super.init(frame: .zero)
        addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        contentWidth = content.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            contentWidth, content.centerXAnchor.constraint(equalTo: centerXAnchor),
            content.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private var naturalSize: CGSize {
        if let measuredSize { return measuredSize }
        contentWidth.isActive = false
        let size = content.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        contentWidth.isActive = true
        measuredSize = size
        return size
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.layoutFittingExpandedSize.width, height: naturalSize.height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width, height: naturalSize.height)
    }

    override func invalidateIntrinsicContentSize() {
        measuredSize = nil
        super.invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        let width = min(naturalSize.width, max(0, bounds.width))
        if contentWidth.constant != width { contentWidth.constant = width }
        super.layoutSubviews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
