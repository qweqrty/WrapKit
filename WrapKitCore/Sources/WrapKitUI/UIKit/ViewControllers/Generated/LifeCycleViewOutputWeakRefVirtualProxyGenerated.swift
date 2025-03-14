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

extension LifeCycleViewOutput {
    public var weakReferenced: any LifeCycleViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: LifeCycleViewOutput where T: LifeCycleViewOutput {

    public func viewDidLoad() {
        object?.viewDidLoad()
    }
    public func viewWillAppear() {
        object?.viewWillAppear()
    }
    public func viewWillDisappear() {
        object?.viewWillDisappear()
    }
    public func viewDidAppear() {
        object?.viewDidAppear()
    }
    public func viewDidDisappear() {
        object?.viewDidDisappear()
    }
    public func composed(with output: LifeCycleViewOutput) {
        object?.composed(with: output)
    }
    public func withAnalytics(screenName: String, analytics: AnalyticsTracker) {
        object?.withAnalytics(screenName: screenName, analytics: analytics)
    }

}
#endif
