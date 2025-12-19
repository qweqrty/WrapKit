// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public final class KeyValueFieldViewOutputSpy: KeyValueFieldViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?)
        case displayKeyTitle(keyTitle: TextOutputPresentableModel?)
        case displayValueTitle(valueTitle: TextOutputPresentableModel?)
        case displayBottomImage(bottomImage: ImageViewPresentableModel?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?] = []
    public private(set) var capturedDisplayKeyTitleKeyTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayValueTitleValueTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayBottomImageBottomImage: [ImageViewPresentableModel?] = []


    // MARK: - KeyValueFieldViewOutput methods
    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(keyTitle: TextOutputPresentableModel?) {
        capturedDisplayKeyTitleKeyTitle.append(keyTitle)
        messages.append(.displayKeyTitle(keyTitle: keyTitle))
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        capturedDisplayValueTitleValueTitle.append(valueTitle)
        messages.append(.displayValueTitle(valueTitle: valueTitle))
    }
    public func display(bottomImage: ImageViewPresentableModel?) {
        capturedDisplayBottomImageBottomImage.append(bottomImage)
        messages.append(.displayBottomImage(bottomImage: bottomImage))
    }

    // MARK: - Properties
}
