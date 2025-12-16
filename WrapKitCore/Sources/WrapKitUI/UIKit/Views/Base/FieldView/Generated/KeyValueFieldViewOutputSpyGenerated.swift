// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public final class KeyValueFieldViewOutputSpy: KeyValueFieldViewOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?)
        case display(keyTitle: TextOutputPresentableModel?)
        case display(valueTitle: TextOutputPresentableModel?)
        case display(bottomImage: ImageViewPresentableModel?)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?] = []
    private(set) var capturedDisplayKeyTitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayValueTitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayBottomImage: [ImageViewPresentableModel?] = []


    // MARK: - KeyValueFieldViewOutput methods
    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(keyTitle: TextOutputPresentableModel?) {
        capturedDisplayKeyTitle.append(keyTitle)
        messages.append(.display(keyTitle: keyTitle))
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        capturedDisplayValueTitle.append(valueTitle)
        messages.append(.display(valueTitle: valueTitle))
    }
    public func display(bottomImage: ImageViewPresentableModel?) {
        capturedDisplayBottomImage.append(bottomImage)
        messages.append(.display(bottomImage: bottomImage))
    }

    // MARK: - Properties
}
