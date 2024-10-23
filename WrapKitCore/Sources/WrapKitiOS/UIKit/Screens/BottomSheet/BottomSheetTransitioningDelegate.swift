#if canImport(UIKit)
import UIKit

final public class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private weak var bottomSheetPresentationController: BottomSheetPresentationController?
    
    public var preferredSheetTopInset: CGFloat
    public var preferredSheetLeftInset: CGFloat
    public var preferredSheetRightInset: CGFloat
    public var preferredSheetBottomInset: CGFloat
    public var preferredSheetCornerRadius: CGFloat
    public var preferredSheetSizingFactor: CGFloat
    public var preferredSheetBackdropColor: UIColor
    
    public var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetPresentationController?.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        }
    }
    
    public var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetPresentationController?.panToDismissEnabled = panToDismissEnabled
        }
    }
    
    public init(
        preferredSheetTopInset: CGFloat,
        preferredSheetLeftInset: CGFloat,
        preferredSheetRightInset: CGFloat,
        preferredSheetBottomInset: CGFloat,
        preferredSheetCornerRadius: CGFloat,
        preferredSheetSizingFactor: CGFloat,
        preferredSheetBackdropColor: UIColor
    ) {
        self.preferredSheetTopInset = preferredSheetTopInset
        self.preferredSheetLeftInset = preferredSheetLeftInset
        self.preferredSheetRightInset = preferredSheetRightInset
        self.preferredSheetBottomInset = preferredSheetBottomInset
        self.preferredSheetCornerRadius = preferredSheetCornerRadius
        self.preferredSheetSizingFactor = preferredSheetSizingFactor
        self.preferredSheetBackdropColor = preferredSheetBackdropColor
        super.init()
    }
    
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let bottomSheetPresentationController = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source,
            containerMargins: .init(
                top: preferredSheetTopInset,
                left: preferredSheetLeftInset,
                bottom: preferredSheetBottomInset,
                right: preferredSheetRightInset
            ),
            sheetCornerRadius: preferredSheetCornerRadius,
            sheetSizingFactor: preferredSheetSizingFactor,
            sheetBackdropColor: preferredSheetBackdropColor
        )
        bottomSheetPresentationController.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        bottomSheetPresentationController.panToDismissEnabled = panToDismissEnabled
        
        self.bottomSheetPresentationController = bottomSheetPresentationController
        
        return bottomSheetPresentationController
    }
    
    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard
            let bottomSheetPresentationController = dismissed.presentationController as? BottomSheetPresentationController,
            bottomSheetPresentationController.bottomSheetInteractiveDismissalTransition.wantsInteractiveStart
        else {
            return nil
        }
        
        return bottomSheetPresentationController.bottomSheetInteractiveDismissalTransition
    }
    
    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        animator as? BottomSheetInteractiveDismissalTransition
    }
}

#endif
