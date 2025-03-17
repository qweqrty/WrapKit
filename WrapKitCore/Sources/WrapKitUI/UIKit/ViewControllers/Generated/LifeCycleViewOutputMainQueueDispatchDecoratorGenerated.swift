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
    public var mainQueueDispatched: any LifeCycleViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: LifeCycleViewOutput where T: LifeCycleViewOutput {

    public func viewDidLoad() {
        dispatch { [weak self] in
            self?.decoratee.viewDidLoad()
        }
    }
    public func viewWillAppear() {
        dispatch { [weak self] in
            self?.decoratee.viewWillAppear()
        }
    }
    public func viewWillDisappear() {
        dispatch { [weak self] in
            self?.decoratee.viewWillDisappear()
        }
    }
    public func viewDidAppear() {
        dispatch { [weak self] in
            self?.decoratee.viewDidAppear()
        }
    }
    public func viewDidDisappear() {
        dispatch { [weak self] in
            self?.decoratee.viewDidDisappear()
        }
    }
    public func composed(with output: LifeCycleViewOutput) {
        dispatch { [weak self] in
            self?.decoratee.composed(with: output)
        }
    }
    public func withAnalytics(eventName: String, parameters: [String: Any], analytics: AnalyticsTracker) {
        dispatch { [weak self] in
            self?.decoratee.withAnalytics(eventName: eventName, parameters: parameters, analytics: analytics)
        }
    }

}
#endif
