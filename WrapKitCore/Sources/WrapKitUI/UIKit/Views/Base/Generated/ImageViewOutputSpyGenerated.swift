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

public final class ImageViewOutputSpy: ImageViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: ImageViewPresentableModel?)
        case displayImage(image: ImageEnum?)
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
    public private(set) var capturedDisplayModel: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplayImage: [ImageEnum?] = []
    public private(set) var capturedDisplaySize: [CGSize?] = []
    public private(set) var capturedDisplayOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnLongPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayContentModeIsFit: [Bool] = []
    public private(set) var capturedDisplayBorderWidth: [CGFloat?] = []
    public private(set) var capturedDisplayBorderColor: [Color?] = []
    public private(set) var capturedDisplayCornerRadius: [CGFloat?] = []
    public private(set) var capturedDisplayAlpha: [CGFloat?] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - ImageViewOutput methods
    public func display(model: ImageViewPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(image: ImageEnum?) {
        capturedDisplayImage.append(image)
        messages.append(.displayImage(image: image))
    }
    public func display(size: CGSize?) {
        capturedDisplaySize.append(size)
        messages.append(.displaySize(size: size))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(onLongPress: (() -> Void)?) {
        capturedDisplayOnLongPress.append(onLongPress)
        messages.append(.displayOnLongPress(onLongPress: onLongPress))
    }
    public func display(contentModeIsFit: Bool) {
        capturedDisplayContentModeIsFit.append(contentModeIsFit)
        messages.append(.displayContentModeIsFit(contentModeIsFit: contentModeIsFit))
    }
    public func display(borderWidth: CGFloat?) {
        capturedDisplayBorderWidth.append(borderWidth)
        messages.append(.displayBorderWidth(borderWidth: borderWidth))
    }
    public func display(borderColor: Color?) {
        capturedDisplayBorderColor.append(borderColor)
        messages.append(.displayBorderColor(borderColor: borderColor))
    }
    public func display(cornerRadius: CGFloat?) {
        capturedDisplayCornerRadius.append(cornerRadius)
        messages.append(.displayCornerRadius(cornerRadius: cornerRadius))
    }
    public func display(alpha: CGFloat?) {
        capturedDisplayAlpha.append(alpha)
        messages.append(.displayAlpha(alpha: alpha))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
