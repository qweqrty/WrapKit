// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

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
#endif
