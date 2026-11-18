#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)
import UIKit
import SwiftUI

/// The UIKit navigation boundary for a SwiftUI scene.
/// Scene lifecycle and presentation outputs belong to the SwiftUI view.
/// A child host keeps SwiftUI navigation preferences separate from this controller's native item.
open class SUIHostingController<Content: SwiftUI.View>: UIViewController {
    private let hostingController: UIHostingController<Content>

    public var rootView: Content {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    public init(rootView: Content) {
        hostingController = UIHostingController(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
    }

    public init?(coder: NSCoder, rootView: Content) {
        hostingController = UIHostingController(rootView: rootView)
        super.init(coder: coder)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if !os(tvOS)
    open override var childForStatusBarStyle: UIViewController? { hostingController }
    open override var childForStatusBarHidden: UIViewController? { hostingController }
    #endif

    public func sizeThatFits(in size: CGSize) -> CGSize {
        hostingController.sizeThatFits(in: size)
    }

    open override func preferredContentSizeDidChange(forChildContentContainer container: any UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container === hostingController {
            preferredContentSize = hostingController.preferredContentSize
        }
    }

    #if !os(tvOS)
    private var previousInteractivePopDelegate: UIGestureRecognizerDelegate?
    #endif

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addChild(hostingController)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
        view.addTapToDismissKeyboard()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateNavigationHeader(animated: animated)
        #if !os(tvOS)
        previousInteractivePopDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        #endif
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if !os(tvOS)
        navigationController?.interactivePopGestureRecognizer?.delegate = previousInteractivePopDelegate
        previousInteractivePopDelegate = nil
        #endif
    }
}
#endif
