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

public final class HeaderOutputSpy: HeaderOutput {
    enum Message: HashableWithReflection {
        case display(model: HeaderPresentableModel?)
        case display(style: HeaderPresentableModel.Style?)
        case display(centerView: HeaderPresentableModel.CenterView?)
        case display(leadingCard: CardViewPresentableModel?)
        case display(primeTrailingImage: ButtonPresentableModel?)
        case display(secondaryTrailingImage: ButtonPresentableModel?)
        case display(tertiaryTrailingImage: ButtonPresentableModel?)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [HeaderPresentableModel?] = []
    private(set) var capturedDisplayStyle: [HeaderPresentableModel.Style?] = []
    private(set) var capturedDisplayCenterView: [HeaderPresentableModel.CenterView?] = []
    private(set) var capturedDisplayLeadingCard: [CardViewPresentableModel?] = []
    private(set) var capturedDisplayPrimeTrailingImage: [ButtonPresentableModel?] = []
    private(set) var capturedDisplaySecondaryTrailingImage: [ButtonPresentableModel?] = []
    private(set) var capturedDisplayTertiaryTrailingImage: [ButtonPresentableModel?] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - HeaderOutput methods
    func display(model: HeaderPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(style: HeaderPresentableModel.Style?) {
        capturedDisplayStyle.append(style)
        messages.append(.display(style: style))
    }
    func display(centerView: HeaderPresentableModel.CenterView?) {
        capturedDisplayCenterView.append(centerView)
        messages.append(.display(centerView: centerView))
    }
    func display(leadingCard: CardViewPresentableModel?) {
        capturedDisplayLeadingCard.append(leadingCard)
        messages.append(.display(leadingCard: leadingCard))
    }
    func display(primeTrailingImage: ButtonPresentableModel?) {
        capturedDisplayPrimeTrailingImage.append(primeTrailingImage)
        messages.append(.display(primeTrailingImage: primeTrailingImage))
    }
    func display(secondaryTrailingImage: ButtonPresentableModel?) {
        capturedDisplaySecondaryTrailingImage.append(secondaryTrailingImage)
        messages.append(.display(secondaryTrailingImage: secondaryTrailingImage))
    }
    func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        capturedDisplayTertiaryTrailingImage.append(tertiaryTrailingImage)
        messages.append(.display(tertiaryTrailingImage: tertiaryTrailingImage))
    }
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
