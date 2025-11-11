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

extension MediaPickerFlow {
    public var mainQueueDispatched: any MediaPickerFlow {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: MediaPickerFlow where T: MediaPickerFlow {

    public func showMediaPicker(sourceTypes: [MediaPickerManager.Source], localizable: MediaPickerLocalizable, callback: ((MediaPickerManager.ResultType?) -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.showMediaPicker(sourceTypes: sourceTypes, localizable: localizable, callback: callback)
        }
    }
    public func finish() {
        dispatch { [weak self] in
            self?.decoratee.finish()
        }
    }

}
#endif
