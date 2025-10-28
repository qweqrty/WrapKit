//
//  ViewController.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol LifeCycleViewOutput: AnyObject {
    // View Controller Lifecycle
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    func viewDidDisappear()
    func viewDidLayoutSubviews()
}

public protocol ApplicationLifecycleOutput: AnyObject {
    // Application Lifecycle
    func applicationWillEnterForeground()
    func applicationDidEnterBackground()
    func applicationDidBecomeActive()
    func applicationWillResignActive()
    func applicationDidChange(userInterfaceStyle: UserInterfaceStyle)
}

#if canImport(UIKit)
import UIKit

open class ViewController<ContentView: UIView>: UIViewController {
    private let LifeCycleViewOutput: LifeCycleViewOutput?
    private let ApplicationLifecycleOutput: ApplicationLifecycleOutput?
    
    public let contentView: ContentView
    public var removingNavStackCountOnAppear: Int = 0
    public var interactivePopGestureRecognizer: UIGestureRecognizerDelegate?

    public init(contentView: ContentView, lifeCycleViewOutput: LifeCycleViewOutput? = nil, applicationLifecycleOutput: ApplicationLifecycleOutput? = nil) {
        self.contentView = contentView
        self.LifeCycleViewOutput = lifeCycleViewOutput
        self.ApplicationLifecycleOutput = applicationLifecycleOutput
        super.init(nibName: nil, bundle: nil)
        registerForAppLifecycleNotifications()
    }

    deinit {
        unregisterFromAppLifecycleNotifications()
        print("\(String(describing: self)) has been deallocated")
    }

    // MARK: - View Controller Lifecycle
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        LifeCycleViewOutput?.viewWillAppear()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = interactivePopGestureRecognizer
        LifeCycleViewOutput?.viewWillDisappear()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard let previousTraitCollection = previousTraitCollection,
              previousTraitCollection.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }
        
        ApplicationLifecycleOutput?.applicationDidChange(userInterfaceStyle: UserInterfaceStyle.current)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        LifeCycleViewOutput?.viewDidLoad()
        view.addSubview(contentView)
        contentView.fillSuperview()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if removingNavStackCountOnAppear > 0, var viewControllersToRemain = navigationController?.viewControllers {
            guard viewControllersToRemain.count > 0 else {
                LifeCycleViewOutput?.viewDidAppear()
                return
            }
            
            guard let lastViewController = viewControllersToRemain.last else {
                LifeCycleViewOutput?.viewDidAppear()
                return
            }
            
            viewControllersToRemain.removeLast()
            
            let countToRemove = min(removingNavStackCountOnAppear, viewControllersToRemain.count)
            
            if countToRemove > 0 {
                viewControllersToRemain.removeLast(countToRemove)
                viewControllersToRemain.append(lastViewController)
                navigationController?.setViewControllers(viewControllersToRemain, animated: false)
            }
        }
        
        LifeCycleViewOutput?.viewDidAppear()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LifeCycleViewOutput?.viewDidDisappear()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LifeCycleViewOutput?.viewDidLayoutSubviews()
    }

    // MARK: - App Lifecycle Notifications
    private func registerForAppLifecycleNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    private func unregisterFromAppLifecycleNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func applicationWillEnterForeground() {
        ApplicationLifecycleOutput?.applicationWillEnterForeground()
    }

    @objc private func applicationDidEnterBackground() {
        ApplicationLifecycleOutput?.applicationDidEnterBackground()
    }

    @objc private func applicationDidBecomeActive() {
        ApplicationLifecycleOutput?.applicationDidBecomeActive()
    }

    @objc private func applicationWillResignActive() {
        ApplicationLifecycleOutput?.applicationWillResignActive()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func navigateToBack() {
        navigationController?.popViewController(animated: true)
    }
}
#endif

// Default implementations for LifeCycleViewOutput
public extension LifeCycleViewOutput {
    func viewDidLoad() {}
    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
    func viewDidLayoutSubviews() {}
}

// Default implementations for ApplicationLifecycleOutput
public extension ApplicationLifecycleOutput {
    func applicationWillEnterForeground() {}
    func applicationDidEnterBackground() {}
    func applicationDidBecomeActive() {}
    func applicationWillResignActive() {}
    func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {}
}
