// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif

public final class MediaPickerFlowSpy: MediaPickerFlow {

    public init() {}

    public enum Message: HashableWithReflection {
        case showMediaPickerSourceTypes(sourceTypes: [MediaPickerManager.Source], localizable: MediaPickerLocalizable, callback: ((MediaPickerManager.ResultType?) -> Void)?)
        case finish
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedShowMediaPickerSourceTypes: [[MediaPickerManager.Source]] = []
    public private(set) var capturedShowMediaPickerLocalizable: [MediaPickerLocalizable] = []
    public private(set) var capturedShowMediaPickerCallback: [((MediaPickerManager.ResultType?) -> Void)?] = []


    // MARK: - MediaPickerFlow methods
    public func showMediaPicker(sourceTypes: [MediaPickerManager.Source], localizable: MediaPickerLocalizable, callback: ((MediaPickerManager.ResultType?) -> Void)?) {
        capturedShowMediaPickerSourceTypes.append(sourceTypes)
        capturedShowMediaPickerLocalizable.append(localizable)
        capturedShowMediaPickerCallback.append(callback)
        messages.append(.showMediaPickerSourceTypes(sourceTypes: sourceTypes, localizable: localizable, callback: callback))
    }
    public func finish() {
        messages.append(.finish)
    }

    // MARK: - Properties
}
