#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)
import UIKit
import SwiftUI

/// The UIKit navigation boundary for a SwiftUI scene with its own header.
/// Scene lifecycle and presentation outputs belong to the SwiftUI view.
open class SUIHostingController<Content: SwiftUI.View>: UIHostingController<Content> {
    #if !os(tvOS)
    private var previousInteractivePopDelegate: UIGestureRecognizerDelegate?
    #endif

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addTapToDismissKeyboard()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        #if !os(tvOS)
        previousInteractivePopDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        #endif
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        #if !os(tvOS)
        navigationController?.interactivePopGestureRecognizer?.delegate = previousInteractivePopDelegate
        previousInteractivePopDelegate = nil
        #endif
    }
}
#endif
