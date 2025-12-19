// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif
import WrapKit

public final class MediaPickerFlowSpy: MediaPickerFlow {

    public init() {}

    public enum Message: HashableWithReflection {
        case showMediaPickerSourceTypes(sourceTypes: [MediaPickerManager.Source], localizable: MediaPickerLocalizable, callback: ((MediaPickerManager.ResultType?) -> Void)?)
        case finish
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedShowMediaPickerSourceTypesLocalizableCallback: [([MediaPickerManager.Source], MediaPickerLocalizable, ((MediaPickerManager.ResultType?) -> Void)?)] = []
    public private(set) var capturedFinish: [Void] = []

    // MARK: - MediaPickerFlow methods
    public func showMediaPicker(sourceTypes: [MediaPickerManager.Source], localizable: MediaPickerLocalizable, callback: ((MediaPickerManager.ResultType?) -> Void)?) {
        capturedShowMediaPickerSourceTypesLocalizableCallback.append((sourceTypes, localizable, callback))
        messages.append(.showMediaPickerSourceTypes(sourceTypes: sourceTypes, localizable: localizable, callback: callback))
    }
    public func finish() {
        capturedFinish.append(())
        messages.append(.finish)
    }

    // MARK: - Properties
}
