//
//  SplashPresenter.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 28/2/25.
//

import Foundation
import WrapKit

public class SplashPresenter: LifeCycleViewOutput, ApplicationLifecycleOutput {
    public var lottieView: LottieViewOutput?
    
    public init() {
       
    }

    // MARK: - View Lifecycle
    public func viewDidLoad() {
        print("SplashPresenter: viewDidLoad()")
    }

    public func viewWillAppear() {
        print("SplashPresenter: viewWillAppear()")
    }

    public func viewWillDisappear() {
        print("SplashPresenter: viewWillDisappear()")
    }

    public func viewDidAppear() {
        print("SplashPresenter: viewDidAppear()")
    }

    public func viewDidDisappear() {
        print("SplashPresenter: viewDidDisappear()")
    }

    // MARK: - Application Lifecycle
    public func applicationWillEnterForeground() {
        print("SplashPresenter: applicationWillEnterForeground()")
    }

    public func applicationDidEnterBackground() {
        print("SplashPresenter: applicationDidEnterBackground()")
    }

    public func applicationDidBecomeActive() {
        print("SplashPresenter: applicationDidBecomeActive()")
    }

    public func applicationWillResignActive() {
        print("SplashPresenter: applicationWillResignActive()")
    }

    public func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {
        print("SplashPresenter: applicationDidChange(userInterfaceStyle: \(userInterfaceStyle))")
    }
}
