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

public final class ImageViewOutputSpy: ImageViewOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(model: ImageViewPresentableModel?)
        case display(image: ImageEnum?)
        case display(size: CGSize?)
        case display(onPress: (() -> Void)?)
        case display(onLongPress: (() -> Void)?)
        case display(contentModeIsFit: Bool)
        case display(borderWidth: CGFloat?)
        case display(borderColor: Color?)
        case display(cornerRadius: CGFloat?)
        case display(alpha: CGFloat?)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [ImageViewPresentableModel?] = []
    private(set) var capturedDisplayImage: [ImageEnum?] = []
    private(set) var capturedDisplaySize: [CGSize?] = []
    private(set) var capturedDisplayOnPress: [(() -> Void)?] = []
    private(set) var capturedDisplayOnLongPress: [(() -> Void)?] = []
    private(set) var capturedDisplayContentModeIsFit: [Bool] = []
    private(set) var capturedDisplayBorderWidth: [CGFloat?] = []
    private(set) var capturedDisplayBorderColor: [Color?] = []
    private(set) var capturedDisplayCornerRadius: [CGFloat?] = []
    private(set) var capturedDisplayAlpha: [CGFloat?] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - ImageViewOutput methods
    public func display(model: ImageViewPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(image: ImageEnum?) {
        capturedDisplayImage.append(image)
        messages.append(.display(image: image))
    }
    public func display(size: CGSize?) {
        capturedDisplaySize.append(size)
        messages.append(.display(size: size))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.display(onPress: onPress))
    }
    public func display(onLongPress: (() -> Void)?) {
        capturedDisplayOnLongPress.append(onLongPress)
        messages.append(.display(onLongPress: onLongPress))
    }
    public func display(contentModeIsFit: Bool) {
        capturedDisplayContentModeIsFit.append(contentModeIsFit)
        messages.append(.display(contentModeIsFit: contentModeIsFit))
    }
    public func display(borderWidth: CGFloat?) {
        capturedDisplayBorderWidth.append(borderWidth)
        messages.append(.display(borderWidth: borderWidth))
    }
    public func display(borderColor: Color?) {
        capturedDisplayBorderColor.append(borderColor)
        messages.append(.display(borderColor: borderColor))
    }
    public func display(cornerRadius: CGFloat?) {
        capturedDisplayCornerRadius.append(cornerRadius)
        messages.append(.display(cornerRadius: cornerRadius))
    }
    public func display(alpha: CGFloat?) {
        capturedDisplayAlpha.append(alpha)
        messages.append(.display(alpha: alpha))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
