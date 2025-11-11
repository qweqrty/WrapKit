// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
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
    public var weakReferenced: any ApplicationLifecycleOutput {
        return WeakRefVirtualProxy(self)
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
