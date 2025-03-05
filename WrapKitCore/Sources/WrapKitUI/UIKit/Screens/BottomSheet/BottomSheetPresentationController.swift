import Foundation
#if canImport(UIKit)
import UIKit

final public class BottomSheetPresentationController: UIPresentationController {
    
    private lazy var backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    internal let bottomSheetInteractiveDismissalTransition = BottomSheetInteractiveDismissalTransition()
    
    internal let containerMargins: UIEdgeInsets
    internal let sheetCornerRadius: CGFloat
    internal let sheetSizingFactor: CGFloat
    internal let sheetBackdropColor: UIColor
    
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))
    var panToDismissEnabled: Bool = true
    
    public init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        containerMargins: UIEdgeInsets,
        sheetCornerRadius: CGFloat,
        sheetSizingFactor: CGFloat,
        sheetBackdropColor: UIColor
    ) {
        self.containerMargins = containerMargins
        self.sheetCornerRadius = sheetCornerRadius
        self.sheetSizingFactor = sheetSizingFactor
        self.sheetBackdropColor = sheetBackdropColor
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.backdropView.backgroundColor = sheetBackdropColor
    }
    
    @objc private func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard
            let presentedView = presentedView,
            let containerView = containerView,
            !presentedView.frame.contains(gestureRecognizer.location(in: containerView))
        else {
            return
        }
        
        presentingViewController.dismiss(animated: true)
    }
    
    @objc private func onPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else {
            return
        }
        
        let translation = gestureRecognizer.translation(in: presentedView)
        
        let progress = translation.y / presentedView.frame.height
        
        switch gestureRecognizer.state {
        case .began:
            bottomSheetInteractiveDismissalTransition.start(
                moving: presentedView, interactiveDismissal: panToDismissEnabled
            )
        case .changed:
            if panToDismissEnabled && progress > 0 && !presentedViewController.isBeingDismissed {
                presentingViewController.dismiss(animated: true)
            }
            bottomSheetInteractiveDismissalTransition.move(
                presentedView, using: translation.y
            )
        default:
            let velocity = gestureRecognizer.velocity(in: presentedView)
            bottomSheetInteractiveDismissalTransition.stop(
                moving: presentedView, at: translation.y, with: velocity
            )
        }
    }
    
    public override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView,
              let containerView = containerView else { return }
        
        presentedView.addGestureRecognizer(panGestureRecognizer)
        presentedView.layer.cornerRadius = sheetCornerRadius
        
        containerView.addGestureRecognizer(tapGestureRecognizer)
        containerView.addSubview(backdropView)
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backdropView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
        containerView.addSubview(presentedView)
        presentedView.translatesAutoresizingMaskIntoConstraints = false
        
        let preferredHeightConstraint = presentedView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: sheetSizingFactor)
        preferredHeightConstraint.priority = .fittingSizeLevel
        
        let topConstraint = presentedView.topAnchor.constraint(greaterThanOrEqualTo: containerView.safeAreaLayoutGuide.topAnchor, constant: containerMargins.top)
        topConstraint.priority = .required - 1
        
        let heightConstraint = presentedView.heightAnchor.constraint(equalToConstant: 0)
        let bottomConstraint = presentedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: containerMargins.bottom)
        
        NSLayoutConstraint.activate([
            topConstraint,
            presentedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: containerMargins.left),
            presentedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: containerMargins.right),
            bottomConstraint,
            preferredHeightConstraint
        ])
        
        bottomSheetInteractiveDismissalTransition.bottomOffset = containerMargins.bottom
        bottomSheetInteractiveDismissalTransition.bottomConstraint = bottomConstraint
        bottomSheetInteractiveDismissalTransition.heightConstraint = heightConstraint
        
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        
        transitionCoordinator.animate(alongsideTransition: { _ in
            self.backdropView.alpha = 0.3
        })
    }
    
    public override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backdropView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    public override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }
        
        transitionCoordinator.animate { _ in
            self.backdropView.alpha = 0
        }
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backdropView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        panGestureRecognizer.isEnabled = false
        coordinator.animate(alongsideTransition: nil) { _ in
            self.panGestureRecognizer.isEnabled = true
        }
    }
}

#endif
