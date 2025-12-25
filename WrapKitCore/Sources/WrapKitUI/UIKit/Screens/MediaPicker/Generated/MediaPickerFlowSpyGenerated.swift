// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class MediaPickerFlowSpy: MediaPickerFlow {

    public init() {}

    public enum Message: HashableWithReflection {
        case showMediaPickerSourceTypes(sourceTypes: [MediaPickerSource], localizable: MediaPickerLocalizable, callback: ((MediaPickerResultType?) -> Void)?)
        case finish
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedShowMediaPickerSourceTypes: [(sourceTypes: [MediaPickerSource], localizable: MediaPickerLocalizable, callback: ((MediaPickerResultType?) -> Void)?)] = []
    public private(set) var capturedFinishCallCount = 0


    // MARK: - MediaPickerFlow methods
    public func showMediaPicker(sourceTypes: [MediaPickerSource], localizable: MediaPickerLocalizable, callback: ((MediaPickerResultType?) -> Void)?) {
        capturedShowMediaPickerSourceTypes.append((sourceTypes: sourceTypes, localizable: localizable, callback: callback))
        messages.append(.showMediaPickerSourceTypes(sourceTypes: sourceTypes, localizable: localizable, callback: callback))
    }
    public func finish() {
        capturedFinishCallCount += 1
        messages.append(.finish)
    }

    // MARK: - Properties
}
