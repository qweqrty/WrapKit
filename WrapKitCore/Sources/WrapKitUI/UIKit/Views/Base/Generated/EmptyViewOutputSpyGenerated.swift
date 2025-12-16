// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class EmptyViewOutputSpy: EmptyViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case display(model: EmptyViewPresentableModel?)
        case display(title: TextOutputPresentableModel?)
        case display(subtitle: TextOutputPresentableModel?)
        case display(buttonModel: ButtonPresentableModel?)
        case display(image: ImageViewPresentableModel?)
        case display(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [EmptyViewPresentableModel?] = []
    public private(set) var capturedDisplayTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplaySubtitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayButtonModel: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayImage: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - EmptyViewOutput methods
    public func display(model: EmptyViewPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(title: TextOutputPresentableModel?) {
        capturedDisplayTitle.append(title)
        messages.append(.display(title: title))
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        capturedDisplaySubtitle.append(subtitle)
        messages.append(.display(subtitle: subtitle))
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        capturedDisplayButtonModel.append(buttonModel)
        messages.append(.display(buttonModel: buttonModel))
    }
    public func display(image: ImageViewPresentableModel?) {
        capturedDisplayImage.append(image)
        messages.append(.display(image: image))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
