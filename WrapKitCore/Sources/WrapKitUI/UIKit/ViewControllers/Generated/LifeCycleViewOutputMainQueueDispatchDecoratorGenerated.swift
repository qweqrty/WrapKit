// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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

extension LifeCycleViewOutput {
    public var weakReferenced: any LifeCycleViewOutput {
        return WeakRefVirtualProxy(self)
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
    public func withAnalytics(screenName: String, analytics: AnalyticsTracker) {
        dispatch { [weak self] in
            self?.decoratee.withAnalytics(screenName: screenName, analytics: analytics)
        }
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
