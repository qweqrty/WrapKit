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
        return (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow })
    }
}
#endif
