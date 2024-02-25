//
//  ViewController.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class ViewController<ContentView: UIView>: UIViewController {
    public let contentView: ContentView
    public var interactivePopGestureRecognizer: UIGestureRecognizerDelegate?
    
    public init(contentView: ContentView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = interactivePopGestureRecognizer
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView)
        contentView.fillSuperview()
    }
    
    deinit {
        print("\(String(describing: self)) has been deallocated")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
