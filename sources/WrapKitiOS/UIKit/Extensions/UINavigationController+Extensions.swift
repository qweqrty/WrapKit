//
//  UINavigationController+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension UINavigationController {
    func popViewControllers(for count: Int, animated: Bool) {
        guard viewControllers.count > count else { return }
        popToViewController(viewControllers[viewControllers.count - count - 1], animated: animated)
    }
    
    func dismissPresentedViewController(animated: Bool) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: animated, completion: nil)
        }
    }
    
    func popToSpecificViewControllerOrPush(_ viewController: UIViewController, animated: Bool) {
        dismissPresentedViewController(animated: animated)
        
        if viewControllers.contains(viewController) {
            popToViewController(viewController, animated: animated)
        } else {
            pushViewController(viewController, animated: animated)
        }
    }
}
#endif
