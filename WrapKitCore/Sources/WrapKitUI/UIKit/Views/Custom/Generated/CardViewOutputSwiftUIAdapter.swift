// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
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
public class CardViewOutputSwiftUIAdapter: ObservableObject, CardViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: CardViewPresentableModel?
    }
    public func display(model: CardViewPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayStyleState: DisplayStyleState? = nil
    public struct DisplayStyleState {
        public let style: CardViewPresentableModel.Style?
    }
    public func display(style: CardViewPresentableModel.Style?) {
        displayStyleState = .init(
            style: style
        )
    }
    @Published public var displayBackgroundImageState: DisplayBackgroundImageState? = nil
    public struct DisplayBackgroundImageState {
        public let backgroundImage: ImageViewPresentableModel?
    }
    public func display(backgroundImage: ImageViewPresentableModel?) {
        displayBackgroundImageState = .init(
            backgroundImage: backgroundImage
        )
    }
    @Published public var displayTitleState: DisplayTitleState? = nil
    public struct DisplayTitleState {
        public let title: TextOutputPresentableModel?
    }
    public func display(title: TextOutputPresentableModel?) {
        displayTitleState = .init(
            title: title
        )
    }
    @Published public var displayLeadingTitlesState: DisplayLeadingTitlesState? = nil
    public struct DisplayLeadingTitlesState {
        public let leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    }
    public func display(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        displayLeadingTitlesState = .init(
            leadingTitles: leadingTitles
        )
    }
    @Published public var displayTrailingTitlesState: DisplayTrailingTitlesState? = nil
    public struct DisplayTrailingTitlesState {
        public let trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    }
    public func display(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        displayTrailingTitlesState = .init(
            trailingTitles: trailingTitles
        )
    }
    @Published public var displayLeadingImageState: DisplayLeadingImageState? = nil
    public struct DisplayLeadingImageState {
        public let leadingImage: ImageViewPresentableModel?
    }
    public func display(leadingImage: ImageViewPresentableModel?) {
        displayLeadingImageState = .init(
            leadingImage: leadingImage
        )
    }
    @Published public var displaySecondaryLeadingImageState: DisplaySecondaryLeadingImageState? = nil
    public struct DisplaySecondaryLeadingImageState {
        public let secondaryLeadingImage: ImageViewPresentableModel?
    }
    public func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        displaySecondaryLeadingImageState = .init(
            secondaryLeadingImage: secondaryLeadingImage
        )
    }
    @Published public var displayTrailingImageState: DisplayTrailingImageState? = nil
    public struct DisplayTrailingImageState {
        public let trailingImage: ImageViewPresentableModel?
    }
    public func display(trailingImage: ImageViewPresentableModel?) {
        displayTrailingImageState = .init(
            trailingImage: trailingImage
        )
    }
    @Published public var displayTrailingImageLeadingSpacingState: DisplayTrailingImageLeadingSpacingState? = nil
    public struct DisplayTrailingImageLeadingSpacingState {
        public let trailingImage: ImageViewPresentableModel?
        public let leadingSpacing: CGFloat?
    }
    public func display(trailingImage: ImageViewPresentableModel?, leadingSpacing: CGFloat?) {
        displayTrailingImageLeadingSpacingState = .init(
            trailingImage: trailingImage, 
            leadingSpacing: leadingSpacing
        )
    }
    @Published public var displaySecondaryTrailingImageState: DisplaySecondaryTrailingImageState? = nil
    public struct DisplaySecondaryTrailingImageState {
        public let secondaryTrailingImage: ImageViewPresentableModel?
    }
    public func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        displaySecondaryTrailingImageState = .init(
            secondaryTrailingImage: secondaryTrailingImage
        )
    }
    @Published public var displaySubTitleState: DisplaySubTitleState? = nil
    public struct DisplaySubTitleState {
        public let subTitle: TextOutputPresentableModel?
    }
    public func display(subTitle: TextOutputPresentableModel?) {
        displaySubTitleState = .init(
            subTitle: subTitle
        )
    }
    @Published public var displayValueTitleState: DisplayValueTitleState? = nil
    public struct DisplayValueTitleState {
        public let valueTitle: TextOutputPresentableModel?
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        displayValueTitleState = .init(
            valueTitle: valueTitle
        )
    }
    @Published public var displayBottomSeparatorState: DisplayBottomSeparatorState? = nil
    public struct DisplayBottomSeparatorState {
        public let bottomSeparator: CardViewPresentableModel.BottomSeparator?
    }
    public func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        displayBottomSeparatorState = .init(
            bottomSeparator: bottomSeparator
        )
    }
    @Published public var displaySwitchControlState: DisplaySwitchControlState? = nil
    public struct DisplaySwitchControlState {
        public let switchControl: SwitchControlPresentableModel?
    }
    public func display(switchControl: SwitchControlPresentableModel?) {
        displaySwitchControlState = .init(
            switchControl: switchControl
        )
    }
    @Published public var displayOnPressState: DisplayOnPressState? = nil
    public struct DisplayOnPressState {
        public let onPress: (() -> Void)?
    }
    public func display(onPress: (() -> Void)?) {
        displayOnPressState = .init(
            onPress: onPress
        )
    }
    @Published public var displayOnLongPressState: DisplayOnLongPressState? = nil
    public struct DisplayOnLongPressState {
        public let onLongPress: (() -> Void)?
    }
    public func display(onLongPress: (() -> Void)?) {
        displayOnLongPressState = .init(
            onLongPress: onLongPress
        )
    }
    @Published public var displayIsHiddenState: DisplayIsHiddenState? = nil
    public struct DisplayIsHiddenState {
        public let isHidden: Bool
    }
    public func display(isHidden: Bool) {
        displayIsHiddenState = .init(
            isHidden: isHidden
        )
    }
    @Published public var displayIsUserInteractionEnabledState: DisplayIsUserInteractionEnabledState? = nil
    public struct DisplayIsUserInteractionEnabledState {
        public let isUserInteractionEnabled: Bool?
    }
    public func display(isUserInteractionEnabled: Bool?) {
        displayIsUserInteractionEnabledState = .init(
            isUserInteractionEnabled: isUserInteractionEnabled
        )
    }
    @Published public var displayIsGradientBorderEnabledState: DisplayIsGradientBorderEnabledState? = nil
    public struct DisplayIsGradientBorderEnabledState {
        public let isGradientBorderEnabled: Bool
    }
    public func display(isGradientBorderEnabled: Bool) {
        displayIsGradientBorderEnabledState = .init(
            isGradientBorderEnabled: isGradientBorderEnabled
        )
    }
}
