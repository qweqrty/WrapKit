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
        case displayModel(model: EmptyViewPresentableModel?)
        case displayTitle(title: TextOutputPresentableModel?)
        case displaySubtitle(subtitle: TextOutputPresentableModel?)
        case displayButtonModel(buttonModel: ButtonPresentableModel?)
        case displayImage(image: ImageViewPresentableModel?)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [EmptyViewPresentableModel?] = []
    public private(set) var capturedDisplayTitleTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplaySubtitleSubtitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayButtonModelButtonModel: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayImageImage: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - EmptyViewOutput methods
    public func display(model: EmptyViewPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(title: TextOutputPresentableModel?) {
        capturedDisplayTitleTitle.append(title)
        messages.append(.displayTitle(title: title))
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        capturedDisplaySubtitleSubtitle.append(subtitle)
        messages.append(.displaySubtitle(subtitle: subtitle))
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        capturedDisplayButtonModelButtonModel.append(buttonModel)
        messages.append(.displayButtonModel(buttonModel: buttonModel))
    }
    public func display(image: ImageViewPresentableModel?) {
        capturedDisplayImageImage.append(image)
        messages.append(.displayImage(image: image))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
