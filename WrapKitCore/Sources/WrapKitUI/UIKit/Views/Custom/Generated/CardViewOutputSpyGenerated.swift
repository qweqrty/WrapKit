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
#if canImport(SwiftUI)
import SwiftUI
#endif
import WrapKit

public final class CardViewOutputSpy: CardViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: CardViewPresentableModel?)
        case displayStyle(style: CardViewPresentableModel.Style?)
        case displayBackgroundImage(backgroundImage: ImageViewPresentableModel?)
        case displayTitle(title: TextOutputPresentableModel?)
        case displayLeadingTitles(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?)
        case displayTrailingTitles(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?)
        case displayLeadingImage(leadingImage: ImageViewPresentableModel?)
        case displaySecondaryLeadingImage(secondaryLeadingImage: ImageViewPresentableModel?)
        case displayTrailingImage(trailingImage: ImageViewPresentableModel?)
        case displaySecondaryTrailingImage(secondaryTrailingImage: ImageViewPresentableModel?)
        case displaySubTitle(subTitle: TextOutputPresentableModel?)
        case displayValueTitle(valueTitle: TextOutputPresentableModel?)
        case displayBottomSeparator(bottomSeparator: CardViewPresentableModel.BottomSeparator?)
        case displaySwitchControl(switchControl: SwitchControlPresentableModel?)
        case displayOnPress(onPress: (() -> Void)?)
        case displayOnLongPress(onLongPress: (() -> Void)?)
        case displayIsHidden(isHidden: Bool)
        case displayIsUserInteractionEnabled(isUserInteractionEnabled: Bool?)
        case displayIsGradientBorderEnabled(isGradientBorderEnabled: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [(CardViewPresentableModel?)] = []
    public private(set) var capturedDisplayStyle: [(CardViewPresentableModel.Style?)] = []
    public private(set) var capturedDisplayBackgroundImage: [(ImageViewPresentableModel?)] = []
    public private(set) var capturedDisplayTitle: [(TextOutputPresentableModel?)] = []
    public private(set) var capturedDisplayLeadingTitles: [(Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?)] = []
    public private(set) var capturedDisplayTrailingTitles: [(Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?)] = []
    public private(set) var capturedDisplayLeadingImage: [(ImageViewPresentableModel?)] = []
    public private(set) var capturedDisplaySecondaryLeadingImage: [(ImageViewPresentableModel?)] = []
    public private(set) var capturedDisplayTrailingImage: [(ImageViewPresentableModel?)] = []
    public private(set) var capturedDisplaySecondaryTrailingImage: [(ImageViewPresentableModel?)] = []
    public private(set) var capturedDisplaySubTitle: [(TextOutputPresentableModel?)] = []
    public private(set) var capturedDisplayValueTitle: [(TextOutputPresentableModel?)] = []
    public private(set) var capturedDisplayBottomSeparator: [(CardViewPresentableModel.BottomSeparator?)] = []
    public private(set) var capturedDisplaySwitchControl: [(SwitchControlPresentableModel?)] = []
    public private(set) var capturedDisplayOnPress: [((() -> Void)?)] = []
    public private(set) var capturedDisplayOnLongPress: [((() -> Void)?)] = []
    public private(set) var capturedDisplayIsHidden: [(Bool)] = []
    public private(set) var capturedDisplayIsUserInteractionEnabled: [(Bool?)] = []
    public private(set) var capturedDisplayIsGradientBorderEnabled: [(Bool)] = []

    // MARK: - CardViewOutput methods
    public func display(model: CardViewPresentableModel?) {
        capturedDisplayModel.append((model))
        messages.append(.displayModel(model: model))
    }
    public func display(style: CardViewPresentableModel.Style?) {
        capturedDisplayStyle.append((style))
        messages.append(.displayStyle(style: style))
    }
    public func display(backgroundImage: ImageViewPresentableModel?) {
        capturedDisplayBackgroundImage.append((backgroundImage))
        messages.append(.displayBackgroundImage(backgroundImage: backgroundImage))
    }
    public func display(title: TextOutputPresentableModel?) {
        capturedDisplayTitle.append((title))
        messages.append(.displayTitle(title: title))
    }
    public func display(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        capturedDisplayLeadingTitles.append((leadingTitles))
        messages.append(.displayLeadingTitles(leadingTitles: leadingTitles))
    }
    public func display(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        capturedDisplayTrailingTitles.append((trailingTitles))
        messages.append(.displayTrailingTitles(trailingTitles: trailingTitles))
    }
    public func display(leadingImage: ImageViewPresentableModel?) {
        capturedDisplayLeadingImage.append((leadingImage))
        messages.append(.displayLeadingImage(leadingImage: leadingImage))
    }
    public func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        capturedDisplaySecondaryLeadingImage.append((secondaryLeadingImage))
        messages.append(.displaySecondaryLeadingImage(secondaryLeadingImage: secondaryLeadingImage))
    }
    public func display(trailingImage: ImageViewPresentableModel?) {
        capturedDisplayTrailingImage.append((trailingImage))
        messages.append(.displayTrailingImage(trailingImage: trailingImage))
    }
    public func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        capturedDisplaySecondaryTrailingImage.append((secondaryTrailingImage))
        messages.append(.displaySecondaryTrailingImage(secondaryTrailingImage: secondaryTrailingImage))
    }
    public func display(subTitle: TextOutputPresentableModel?) {
        capturedDisplaySubTitle.append((subTitle))
        messages.append(.displaySubTitle(subTitle: subTitle))
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        capturedDisplayValueTitle.append((valueTitle))
        messages.append(.displayValueTitle(valueTitle: valueTitle))
    }
    public func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        capturedDisplayBottomSeparator.append((bottomSeparator))
        messages.append(.displayBottomSeparator(bottomSeparator: bottomSeparator))
    }
    public func display(switchControl: SwitchControlPresentableModel?) {
        capturedDisplaySwitchControl.append((switchControl))
        messages.append(.displaySwitchControl(switchControl: switchControl))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append((onPress))
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(onLongPress: (() -> Void)?) {
        capturedDisplayOnLongPress.append((onLongPress))
        messages.append(.displayOnLongPress(onLongPress: onLongPress))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append((isHidden))
        messages.append(.displayIsHidden(isHidden: isHidden))
    }
    public func display(isUserInteractionEnabled: Bool?) {
        capturedDisplayIsUserInteractionEnabled.append((isUserInteractionEnabled))
        messages.append(.displayIsUserInteractionEnabled(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    public func display(isGradientBorderEnabled: Bool) {
        capturedDisplayIsGradientBorderEnabled.append((isGradientBorderEnabled))
        messages.append(.displayIsGradientBorderEnabled(isGradientBorderEnabled: isGradientBorderEnabled))
    }

    // MARK: - Properties
}
