//
//  ViewController.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol LifeCycleViewInput {
    // View Controller Lifecycle
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    func viewDidDisappear()
}

public protocol ApplicationLifecycleInput {
    // Application Lifecycle
    func applicationWillEnterForeground()
    func applicationDidEnterBackground()
    func applicationDidBecomeActive()
    func applicationWillResignActive()
}

#if canImport(UIKit)
import UIKit

open class ViewController<ContentView: UIView>: UIViewController {
    public let contentView: ContentView
    private let lifeCycleViewInput: LifeCycleViewInput?
    private let applicationLifecycleInput: ApplicationLifecycleInput?
    public var interactivePopGestureRecognizer: UIGestureRecognizerDelegate?

    public init(contentView: ContentView, lifeCycleViewInput: LifeCycleViewInput? = nil, applicationLifecycleInput: ApplicationLifecycleInput? = nil) {
        self.contentView = contentView
        self.lifeCycleViewInput = lifeCycleViewInput
        self.applicationLifecycleInput = applicationLifecycleInput
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
        lifeCycleViewInput?.viewWillAppear()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = interactivePopGestureRecognizer
        lifeCycleViewInput?.viewWillDisappear()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        lifeCycleViewInput?.viewDidLoad()
        view.addSubview(contentView)
        contentView.fillSuperview()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lifeCycleViewInput?.viewDidAppear()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifeCycleViewInput?.viewDidDisappear()
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
        applicationLifecycleInput?.applicationWillEnterForeground()
    }

    @objc private func applicationDidEnterBackground() {
        applicationLifecycleInput?.applicationDidEnterBackground()
    }

    @objc private func applicationDidBecomeActive() {
        applicationLifecycleInput?.applicationDidBecomeActive()
    }

    @objc private func applicationWillResignActive() {
        applicationLifecycleInput?.applicationWillResignActive()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func navigateToBack() {
        navigationController?.popViewController(animated: true)
    }
}
#endif

// Default implementations for LifeCycleViewInput
public extension LifeCycleViewInput {
    func viewDidLoad() {}
    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
}

// Default implementations for ApplicationLifecycleInput
public extension ApplicationLifecycleInput {
    func applicationWillEnterForeground() {}
    func applicationDidEnterBackground() {}
    func applicationDidBecomeActive() {}
    func applicationWillResignActive() {}
}
