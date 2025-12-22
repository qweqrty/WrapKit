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
    public private(set) var capturedDisplayModel: [HeaderPresentableModel?] = []
    public private(set) var capturedDisplayStyle: [HeaderPresentableModel.Style?] = []
    public private(set) var capturedDisplayCenterView: [HeaderPresentableModel.CenterView?] = []
    public private(set) var capturedDisplayLeadingCard: [CardViewPresentableModel?] = []
    public private(set) var capturedDisplayPrimeTrailingImage: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplaySecondaryTrailingImage: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayTertiaryTrailingImage: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - HeaderOutput methods
    public func display(model: HeaderPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(style: HeaderPresentableModel.Style?) {
        capturedDisplayStyle.append(style)
        messages.append(.displayStyle(style: style))
    }
    public func display(centerView: HeaderPresentableModel.CenterView?) {
        capturedDisplayCenterView.append(centerView)
        messages.append(.displayCenterView(centerView: centerView))
    }
    public func display(leadingCard: CardViewPresentableModel?) {
        capturedDisplayLeadingCard.append(leadingCard)
        messages.append(.displayLeadingCard(leadingCard: leadingCard))
    }
    public func display(primeTrailingImage: ButtonPresentableModel?) {
        capturedDisplayPrimeTrailingImage.append(primeTrailingImage)
        messages.append(.displayPrimeTrailingImage(primeTrailingImage: primeTrailingImage))
    }
    public func display(secondaryTrailingImage: ButtonPresentableModel?) {
        capturedDisplaySecondaryTrailingImage.append(secondaryTrailingImage)
        messages.append(.displaySecondaryTrailingImage(secondaryTrailingImage: secondaryTrailingImage))
    }
    public func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        capturedDisplayTertiaryTrailingImage.append(tertiaryTrailingImage)
        messages.append(.displayTertiaryTrailingImage(tertiaryTrailingImage: tertiaryTrailingImage))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties

    // MARK: - Reset
    public func reset() {
        messages.removeAll()
        capturedDisplayModel.removeAll()
        capturedDisplayStyle.removeAll()
        capturedDisplayCenterView.removeAll()
        capturedDisplayLeadingCard.removeAll()
        capturedDisplayPrimeTrailingImage.removeAll()
        capturedDisplaySecondaryTrailingImage.removeAll()
        capturedDisplayTertiaryTrailingImage.removeAll()
        capturedDisplayIsHidden.removeAll()
    }
}
