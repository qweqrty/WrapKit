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
#if canImport(SwiftUI)
import SwiftUI
#endif

final class CardViewOutputSpy: CardViewOutput {
    enum Message: HashableWithReflection {
        case display(model: CardViewPresentableModel?)
        case display(style: CardViewPresentableModel.Style?)
        case display(backgroundImage: ImageViewPresentableModel?)
        case display(title: TextOutputPresentableModel?)
        case display(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?)
        case display(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?)
        case display(leadingImage: ImageViewPresentableModel?)
        case display(secondaryLeadingImage: ImageViewPresentableModel?)
        case display(trailingImage: ImageViewPresentableModel?)
        case display(secondaryTrailingImage: ImageViewPresentableModel?)
        case display(subTitle: TextOutputPresentableModel?)
        case display(valueTitle: TextOutputPresentableModel?)
        case display(bottomSeparator: CardViewPresentableModel.BottomSeparator?)
        case display(switchControl: SwitchControlPresentableModel?)
        case display(onPress: (() -> Void)?)
        case display(onLongPress: (() -> Void)?)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [CardViewPresentableModel?] = []
    private(set) var capturedDisplayStyle: [CardViewPresentableModel.Style?] = []
    private(set) var capturedDisplayBackgroundImage: [ImageViewPresentableModel?] = []
    private(set) var capturedDisplayTitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayLeadingTitles: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?] = []
    private(set) var capturedDisplayTrailingTitles: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?] = []
    private(set) var capturedDisplayLeadingImage: [ImageViewPresentableModel?] = []
    private(set) var capturedDisplaySecondaryLeadingImage: [ImageViewPresentableModel?] = []
    private(set) var capturedDisplayTrailingImage: [ImageViewPresentableModel?] = []
    private(set) var capturedDisplaySecondaryTrailingImage: [ImageViewPresentableModel?] = []
    private(set) var capturedDisplaySubTitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayValueTitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayBottomSeparator: [CardViewPresentableModel.BottomSeparator?] = []
    private(set) var capturedDisplaySwitchControl: [SwitchControlPresentableModel?] = []
    private(set) var capturedDisplayOnPress: [(() -> Void)?] = []
    private(set) var capturedDisplayOnLongPress: [(() -> Void)?] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - CardViewOutput methods
    func display(model: CardViewPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(style: CardViewPresentableModel.Style?) {
        capturedDisplayStyle.append(style)
        messages.append(.display(style: style))
    }
    func display(backgroundImage: ImageViewPresentableModel?) {
        capturedDisplayBackgroundImage.append(backgroundImage)
        messages.append(.display(backgroundImage: backgroundImage))
    }
    func display(title: TextOutputPresentableModel?) {
        capturedDisplayTitle.append(title)
        messages.append(.display(title: title))
    }
    func display(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        capturedDisplayLeadingTitles.append(leadingTitles)
        messages.append(.display(leadingTitles: leadingTitles))
    }
    func display(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        capturedDisplayTrailingTitles.append(trailingTitles)
        messages.append(.display(trailingTitles: trailingTitles))
    }
    func display(leadingImage: ImageViewPresentableModel?) {
        capturedDisplayLeadingImage.append(leadingImage)
        messages.append(.display(leadingImage: leadingImage))
    }
    func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        capturedDisplaySecondaryLeadingImage.append(secondaryLeadingImage)
        messages.append(.display(secondaryLeadingImage: secondaryLeadingImage))
    }
    func display(trailingImage: ImageViewPresentableModel?) {
        capturedDisplayTrailingImage.append(trailingImage)
        messages.append(.display(trailingImage: trailingImage))
    }
    func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        capturedDisplaySecondaryTrailingImage.append(secondaryTrailingImage)
        messages.append(.display(secondaryTrailingImage: secondaryTrailingImage))
    }
    func display(subTitle: TextOutputPresentableModel?) {
        capturedDisplaySubTitle.append(subTitle)
        messages.append(.display(subTitle: subTitle))
    }
    func display(valueTitle: TextOutputPresentableModel?) {
        capturedDisplayValueTitle.append(valueTitle)
        messages.append(.display(valueTitle: valueTitle))
    }
    func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        capturedDisplayBottomSeparator.append(bottomSeparator)
        messages.append(.display(bottomSeparator: bottomSeparator))
    }
    func display(switchControl: SwitchControlPresentableModel?) {
        capturedDisplaySwitchControl.append(switchControl)
        messages.append(.display(switchControl: switchControl))
    }
    func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.display(onPress: onPress))
    }
    func display(onLongPress: (() -> Void)?) {
        capturedDisplayOnLongPress.append(onLongPress)
        messages.append(.display(onLongPress: onLongPress))
    }
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
