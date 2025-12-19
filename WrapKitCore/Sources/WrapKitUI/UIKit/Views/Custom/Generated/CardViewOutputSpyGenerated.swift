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
    public private(set) var capturedDisplayModelModel: [CardViewPresentableModel?] = []
    public private(set) var capturedDisplayStyleStyle: [CardViewPresentableModel.Style?] = []
    public private(set) var capturedDisplayBackgroundImageBackgroundImage: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplayTitleTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayLeadingTitlesLeadingTitles: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?] = []
    public private(set) var capturedDisplayTrailingTitlesTrailingTitles: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?] = []
    public private(set) var capturedDisplayLeadingImageLeadingImage: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplaySecondaryLeadingImageSecondaryLeadingImage: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplayTrailingImageTrailingImage: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplaySecondaryTrailingImageSecondaryTrailingImage: [ImageViewPresentableModel?] = []
    public private(set) var capturedDisplaySubTitleSubTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayValueTitleValueTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayBottomSeparatorBottomSeparator: [CardViewPresentableModel.BottomSeparator?] = []
    public private(set) var capturedDisplaySwitchControlSwitchControl: [SwitchControlPresentableModel?] = []
    public private(set) var capturedDisplayOnPressOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayOnLongPressOnLongPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []
    public private(set) var capturedDisplayIsUserInteractionEnabledIsUserInteractionEnabled: [Bool?] = []
    public private(set) var capturedDisplayIsGradientBorderEnabledIsGradientBorderEnabled: [Bool] = []


    // MARK: - CardViewOutput methods
    public func display(model: CardViewPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(style: CardViewPresentableModel.Style?) {
        capturedDisplayStyleStyle.append(style)
        messages.append(.displayStyle(style: style))
    }
    public func display(backgroundImage: ImageViewPresentableModel?) {
        capturedDisplayBackgroundImageBackgroundImage.append(backgroundImage)
        messages.append(.displayBackgroundImage(backgroundImage: backgroundImage))
    }
    public func display(title: TextOutputPresentableModel?) {
        capturedDisplayTitleTitle.append(title)
        messages.append(.displayTitle(title: title))
    }
    public func display(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        capturedDisplayLeadingTitlesLeadingTitles.append(leadingTitles)
        messages.append(.displayLeadingTitles(leadingTitles: leadingTitles))
    }
    public func display(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        capturedDisplayTrailingTitlesTrailingTitles.append(trailingTitles)
        messages.append(.displayTrailingTitles(trailingTitles: trailingTitles))
    }
    public func display(leadingImage: ImageViewPresentableModel?) {
        capturedDisplayLeadingImageLeadingImage.append(leadingImage)
        messages.append(.displayLeadingImage(leadingImage: leadingImage))
    }
    public func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        capturedDisplaySecondaryLeadingImageSecondaryLeadingImage.append(secondaryLeadingImage)
        messages.append(.displaySecondaryLeadingImage(secondaryLeadingImage: secondaryLeadingImage))
    }
    public func display(trailingImage: ImageViewPresentableModel?) {
        capturedDisplayTrailingImageTrailingImage.append(trailingImage)
        messages.append(.displayTrailingImage(trailingImage: trailingImage))
    }
    public func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        capturedDisplaySecondaryTrailingImageSecondaryTrailingImage.append(secondaryTrailingImage)
        messages.append(.displaySecondaryTrailingImage(secondaryTrailingImage: secondaryTrailingImage))
    }
    public func display(subTitle: TextOutputPresentableModel?) {
        capturedDisplaySubTitleSubTitle.append(subTitle)
        messages.append(.displaySubTitle(subTitle: subTitle))
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        capturedDisplayValueTitleValueTitle.append(valueTitle)
        messages.append(.displayValueTitle(valueTitle: valueTitle))
    }
    public func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        capturedDisplayBottomSeparatorBottomSeparator.append(bottomSeparator)
        messages.append(.displayBottomSeparator(bottomSeparator: bottomSeparator))
    }
    public func display(switchControl: SwitchControlPresentableModel?) {
        capturedDisplaySwitchControlSwitchControl.append(switchControl)
        messages.append(.displaySwitchControl(switchControl: switchControl))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPressOnPress.append(onPress)
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(onLongPress: (() -> Void)?) {
        capturedDisplayOnLongPressOnLongPress.append(onLongPress)
        messages.append(.displayOnLongPress(onLongPress: onLongPress))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }
    public func display(isUserInteractionEnabled: Bool?) {
        capturedDisplayIsUserInteractionEnabledIsUserInteractionEnabled.append(isUserInteractionEnabled)
        messages.append(.displayIsUserInteractionEnabled(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    public func display(isGradientBorderEnabled: Bool) {
        capturedDisplayIsGradientBorderEnabledIsGradientBorderEnabled.append(isGradientBorderEnabled)
        messages.append(.displayIsGradientBorderEnabled(isGradientBorderEnabled: isGradientBorderEnabled))
    }

    // MARK: - Properties
}
