// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(UIKit)
import UIKit
#endif

extension ApplicationLifecycleOutput {
    public var mainQueueDispatched: any ApplicationLifecycleOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension ApplicationLifecycleOutput {
    public var weakReferenced: any ApplicationLifecycleOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: ApplicationLifecycleOutput where T: ApplicationLifecycleOutput {

    public func applicationWillEnterForeground() {
        dispatch { [weak self] in
            self?.decoratee.applicationWillEnterForeground()
        }
    }
    public func applicationDidEnterBackground() {
        dispatch { [weak self] in
            self?.decoratee.applicationDidEnterBackground()
        }
    }
    public func applicationDidBecomeActive() {
        dispatch { [weak self] in
            self?.decoratee.applicationDidBecomeActive()
        }
    }
    public func applicationWillResignActive() {
        dispatch { [weak self] in
            self?.decoratee.applicationWillResignActive()
        }
    }
    public func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {
        dispatch { [weak self] in
            self?.decoratee.applicationDidChange(userInterfaceStyle: userInterfaceStyle)
        }
    }
    public func composed(with output: ApplicationLifecycleOutput) {
        dispatch { [weak self] in
            self?.decoratee.composed(with: output)
        }
    }

}

extension WeakRefVirtualProxy: ApplicationLifecycleOutput where T: ApplicationLifecycleOutput {

    public func applicationWillEnterForeground() {
        object?.applicationWillEnterForeground()
    }
    public func applicationDidEnterBackground() {
        object?.applicationDidEnterBackground()
    }
    public func applicationDidBecomeActive() {
        object?.applicationDidBecomeActive()
    }
    public func applicationWillResignActive() {
        object?.applicationWillResignActive()
    }
    public func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {
        object?.applicationDidChange(userInterfaceStyle: userInterfaceStyle)
    }
    public func composed(with output: ApplicationLifecycleOutput) {
        object?.composed(with: output)
    }

}

#endif
