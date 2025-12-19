// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
import WrapKit
#if canImport(UIKit)
import UIKit
#endif
import WrapKit

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
    public private(set) var capturedDisplayModel: [(EmptyViewPresentableModel?)] = []
    public private(set) var capturedDisplayTitle: [(TextOutputPresentableModel?)] = []
    public private(set) var capturedDisplaySubtitle: [(TextOutputPresentableModel?)] = []
    public private(set) var capturedDisplayButtonModel: [(ButtonPresentableModel?)] = []
    public private(set) var capturedDisplayImage: [(ImageViewPresentableModel?)] = []
    public private(set) var capturedDisplayIsHidden: [(Bool)] = []

    // MARK: - EmptyViewOutput methods
    public func display(model: EmptyViewPresentableModel?) {
        capturedDisplayModel.append((model))
        messages.append(.displayModel(model: model))
    }
    public func display(title: TextOutputPresentableModel?) {
        capturedDisplayTitle.append((title))
        messages.append(.displayTitle(title: title))
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        capturedDisplaySubtitle.append((subtitle))
        messages.append(.displaySubtitle(subtitle: subtitle))
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        capturedDisplayButtonModel.append((buttonModel))
        messages.append(.displayButtonModel(buttonModel: buttonModel))
    }
    public func display(image: ImageViewPresentableModel?) {
        capturedDisplayImage.append((image))
        messages.append(.displayImage(image: image))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append((isHidden))
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
