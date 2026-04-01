//
//  File.swift
//
//
//  Created by Stanislav Li on 21/8/24.
//

#if canImport(UIKit)
import UIKit

public extension UIApplication {
    static var window: UIWindow? {
        let resolveWindow = {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)
        }
        
        if Thread.isMainThread {
            return resolveWindow()
        } else {
            return DispatchQueue.main.sync {
                resolveWindow()
            }
        }
    }
    
    static var topViewController: UIViewController? {
        topViewController(from: window?.rootViewController)
    }
    
    private static func topViewController(from controller: UIViewController?) -> UIViewController? {
        if let presented = controller?.presentedViewController {
            return topViewController(from: presented)
        }
        
        if let nav = controller as? UINavigationController {
            return topViewController(from: nav.visibleViewController)
        }
        
        if let tab = controller as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }
        
        return controller
    }
    
    static var topNavigationController: UINavigationController? {
        if let nav = topViewController as? UINavigationController {
            return nav
        }
        return topViewController?.navigationController
    }
}
#endif
