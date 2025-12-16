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
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class EmptyViewOutputSpy: EmptyViewOutput {
    enum Message: HashableWithReflection {
        case display(model: EmptyViewPresentableModel?)
        case display(title: TextOutputPresentableModel?)
        case display(subtitle: TextOutputPresentableModel?)
        case display(buttonModel: ButtonPresentableModel?)
        case display(image: ImageViewPresentableModel?)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [EmptyViewPresentableModel?] = []
    private(set) var capturedDisplayTitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplaySubtitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayButtonModel: [ButtonPresentableModel?] = []
    private(set) var capturedDisplayImage: [ImageViewPresentableModel?] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - EmptyViewOutput methods
    func display(model: EmptyViewPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(title: TextOutputPresentableModel?) {
        capturedDisplayTitle.append(title)
        messages.append(.display(title: title))
    }
    func display(subtitle: TextOutputPresentableModel?) {
        capturedDisplaySubtitle.append(subtitle)
        messages.append(.display(subtitle: subtitle))
    }
    func display(buttonModel: ButtonPresentableModel?) {
        capturedDisplayButtonModel.append(buttonModel)
        messages.append(.display(buttonModel: buttonModel))
    }
    func display(image: ImageViewPresentableModel?) {
        capturedDisplayImage.append(image)
        messages.append(.display(image: image))
    }
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
