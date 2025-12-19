// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public final class TitledOutputSpy: TitledOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: TitledViewPresentableModel?)
        case displayTitles(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
        case displayBottomTitles(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
        case displayLeadingBottomTitle(leadingBottomTitle: TextOutputPresentableModel?)
        case displayTrailingBottomTitle(trailingBottomTitle: TextOutputPresentableModel?)
        case displayIsUserInteractionEnabled(isUserInteractionEnabled: Bool)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [TitledViewPresentableModel?] = []
    public private(set) var capturedDisplayTitlesTitles: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>] = []
    public private(set) var capturedDisplayBottomTitlesBottomTitles: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>] = []
    public private(set) var capturedDisplayLeadingBottomTitleLeadingBottomTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayTrailingBottomTitleTrailingBottomTitle: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayIsUserInteractionEnabledIsUserInteractionEnabled: [Bool] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - TitledOutput methods
    public func display(model: TitledViewPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        capturedDisplayTitlesTitles.append(titles)
        messages.append(.displayTitles(titles: titles))
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        capturedDisplayBottomTitlesBottomTitles.append(bottomTitles)
        messages.append(.displayBottomTitles(bottomTitles: bottomTitles))
    }
    public func display(leadingBottomTitle: TextOutputPresentableModel?) {
        capturedDisplayLeadingBottomTitleLeadingBottomTitle.append(leadingBottomTitle)
        messages.append(.displayLeadingBottomTitle(leadingBottomTitle: leadingBottomTitle))
    }
    public func display(trailingBottomTitle: TextOutputPresentableModel?) {
        capturedDisplayTrailingBottomTitleTrailingBottomTitle.append(trailingBottomTitle)
        messages.append(.displayTrailingBottomTitle(trailingBottomTitle: trailingBottomTitle))
    }
    public func display(isUserInteractionEnabled: Bool) {
        capturedDisplayIsUserInteractionEnabledIsUserInteractionEnabled.append(isUserInteractionEnabled)
        messages.append(.displayIsUserInteractionEnabled(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
