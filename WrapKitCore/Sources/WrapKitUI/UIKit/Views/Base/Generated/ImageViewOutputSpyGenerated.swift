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
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Kingfisher)
import Kingfisher
#endif

public final class ImageViewOutputSpy: ImageViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: ImageViewPresentableModel?, completion: ((Image?) -> Void)?)
        case displayImage(image: ImageEnum?, completion: ((Image?) -> Void)?)
        case displaySize(size: CGSize?)
        case displayOnPress(onPress: (() -> Void)?)
        case displayOnLongPress(onLongPress: (() -> Void)?)
        case displayContentModeIsFit(contentModeIsFit: Bool)
        case displayBorderWidth(borderWidth: CGFloat?)
        case displayBorderColor(borderColor: Color?)
        case displayCornerRadius(cornerRadius: CGFloat?)
        case displayAlpha(alpha: CGFloat?)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplayModelCompletion: [((Image?) -> Void)?] = []
    public private(set) var capturedDisplayImageImage: [ImageEnum?] = []
    public private(set) var capturedDisplayImageCompletion: [((Image?) -> Void)?] = []
    public private(set) var capturedDisplaySizeSize: [CGSize?] = []
    public private(set) var capturedDisplayOnPressOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnLongPressOnLongPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayContentModeIsFitContentModeIsFit: [Bool] = []
    public private(set) var capturedDisplayBorderWidthBorderWidth: [CGFloat?] = []
    public private(set) var capturedDisplayBorderColorBorderColor: [Color?] = []
    public private(set) var capturedDisplayCornerRadiusCornerRadius: [CGFloat?] = []
    public private(set) var capturedDisplayAlphaAlpha: [CGFloat?] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - ImageViewOutput methods
    public func display(model: ImageViewPresentableModel?, completion: ((Image?) -> Void)?) {
        capturedDisplayModelModel.append(model)
        capturedDisplayModelCompletion.append(completion)
        messages.append(.displayModel(model: model, completion: completion))
    }
    public func display(image: ImageEnum?, completion: ((Image?) -> Void)?) {
        capturedDisplayImageImage.append(image)
        capturedDisplayImageCompletion.append(completion)
        messages.append(.displayImage(image: image, completion: completion))
    }
    public func display(size: CGSize?) {
        capturedDisplaySizeSize.append(size)
        messages.append(.displaySize(size: size))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPressOnPress.append(onPress)
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(onLongPress: (() -> Void)?) {
        capturedDisplayOnLongPressOnLongPress.append(onLongPress)
        messages.append(.displayOnLongPress(onLongPress: onLongPress))
    }
    public func display(contentModeIsFit: Bool) {
        capturedDisplayContentModeIsFitContentModeIsFit.append(contentModeIsFit)
        messages.append(.displayContentModeIsFit(contentModeIsFit: contentModeIsFit))
    }
    public func display(borderWidth: CGFloat?) {
        capturedDisplayBorderWidthBorderWidth.append(borderWidth)
        messages.append(.displayBorderWidth(borderWidth: borderWidth))
    }
    public func display(borderColor: Color?) {
        capturedDisplayBorderColorBorderColor.append(borderColor)
        messages.append(.displayBorderColor(borderColor: borderColor))
    }
    public func display(cornerRadius: CGFloat?) {
        capturedDisplayCornerRadiusCornerRadius.append(cornerRadius)
        messages.append(.displayCornerRadius(cornerRadius: cornerRadius))
    }
    public func display(alpha: CGFloat?) {
        capturedDisplayAlphaAlpha.append(alpha)
        messages.append(.displayAlpha(alpha: alpha))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
