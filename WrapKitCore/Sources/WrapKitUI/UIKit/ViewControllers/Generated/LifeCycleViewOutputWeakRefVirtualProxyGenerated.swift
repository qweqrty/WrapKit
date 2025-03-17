// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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
    public func withAnalytics(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker) {
        object?.withAnalytics(eventName: eventName, parameters: parameters, analytics: analytics)
    }

}
#endif
