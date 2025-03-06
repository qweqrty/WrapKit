//
//  Composite.swift
//  WrapKit
//
//  Created by Stanislav Li on 6/3/25.
//

import Foundation

public final class Composite<T> {
    public let primary: T
    public let secondary: T
    
    public init(primary: T, secondary: T) {
        self.primary = primary
        self.secondary = secondary
    }
}

public extension LifeCycleViewOutput {
    func composed(with output: LifeCycleViewOutput) -> LifeCycleViewOutput {
        return Composite(primary: self, secondary: output)
    }
}

public extension ApplicationLifecycleOutput {
    func composed(with output: ApplicationLifecycleOutput) -> ApplicationLifecycleOutput {
        return Composite(primary: self, secondary: output)
    }
}

extension Composite: LifeCycleViewOutput where T == LifeCycleViewOutput {
    public func viewDidLoad() {
        primary.viewDidLoad()
        secondary.viewDidLoad()
    }
    
    public func viewWillAppear() {
        primary.viewDidLoad()
        secondary.viewDidLoad()
    }
    
    public func viewWillDisappear() {
        primary.viewDidLoad()
        secondary.viewDidLoad()
    }
    
    public func viewDidAppear() {
        primary.viewDidLoad()
        secondary.viewDidLoad()
    }
    
    public func viewDidDisappear() {
        primary.viewDidLoad()
        secondary.viewDidLoad()
    }
}

extension Composite: ApplicationLifecycleOutput where T == ApplicationLifecycleOutput {
    public func applicationWillEnterForeground() {
        primary.applicationWillEnterForeground()
        secondary.applicationWillEnterForeground()
    }
    
    public func applicationDidEnterBackground() {
        primary.applicationDidEnterBackground()
        secondary.applicationDidEnterBackground()
    }
    
    public func applicationDidBecomeActive() {
        primary.applicationDidBecomeActive()
        secondary.applicationDidBecomeActive()
    }
    
    public func applicationWillResignActive() {
        primary.applicationWillResignActive()
        secondary.applicationWillResignActive()
    }
    
    public func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {
        primary.applicationDidChange(userInterfaceStyle: userInterfaceStyle)
        secondary.applicationDidChange(userInterfaceStyle: userInterfaceStyle)
    }
    
}
