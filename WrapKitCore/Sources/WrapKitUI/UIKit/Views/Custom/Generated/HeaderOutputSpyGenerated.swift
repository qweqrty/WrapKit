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

public final class HeaderOutputSpy: HeaderOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: HeaderPresentableModel?)
        case displayStyle(style: HeaderPresentableModel.Style?)
        case displayCenterView(centerView: HeaderPresentableModel.CenterView?)
        case displayLeadingCard(leadingCard: CardViewPresentableModel?)
        case displayPrimeTrailingImage(primeTrailingImage: ButtonPresentableModel?)
        case displaySecondaryTrailingImage(secondaryTrailingImage: ButtonPresentableModel?)
        case displayTertiaryTrailingImage(tertiaryTrailingImage: ButtonPresentableModel?)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [HeaderPresentableModel?] = []
    public private(set) var capturedDisplayStyleStyle: [HeaderPresentableModel.Style?] = []
    public private(set) var capturedDisplayCenterViewCenterView: [HeaderPresentableModel.CenterView?] = []
    public private(set) var capturedDisplayLeadingCardLeadingCard: [CardViewPresentableModel?] = []
    public private(set) var capturedDisplayPrimeTrailingImagePrimeTrailingImage: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplaySecondaryTrailingImageSecondaryTrailingImage: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayTertiaryTrailingImageTertiaryTrailingImage: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - HeaderOutput methods
    public func display(model: HeaderPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(style: HeaderPresentableModel.Style?) {
        capturedDisplayStyleStyle.append(style)
        messages.append(.displayStyle(style: style))
    }
    public func display(centerView: HeaderPresentableModel.CenterView?) {
        capturedDisplayCenterViewCenterView.append(centerView)
        messages.append(.displayCenterView(centerView: centerView))
    }
    public func display(leadingCard: CardViewPresentableModel?) {
        capturedDisplayLeadingCardLeadingCard.append(leadingCard)
        messages.append(.displayLeadingCard(leadingCard: leadingCard))
    }
    public func display(primeTrailingImage: ButtonPresentableModel?) {
        capturedDisplayPrimeTrailingImagePrimeTrailingImage.append(primeTrailingImage)
        messages.append(.displayPrimeTrailingImage(primeTrailingImage: primeTrailingImage))
    }
    public func display(secondaryTrailingImage: ButtonPresentableModel?) {
        capturedDisplaySecondaryTrailingImageSecondaryTrailingImage.append(secondaryTrailingImage)
        messages.append(.displaySecondaryTrailingImage(secondaryTrailingImage: secondaryTrailingImage))
    }
    public func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        capturedDisplayTertiaryTrailingImageTertiaryTrailingImage.append(tertiaryTrailingImage)
        messages.append(.displayTertiaryTrailingImage(tertiaryTrailingImage: tertiaryTrailingImage))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
