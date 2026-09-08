//
//  NavigationController.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

open class NavigationController: UINavigationController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
    }
}
#endif
