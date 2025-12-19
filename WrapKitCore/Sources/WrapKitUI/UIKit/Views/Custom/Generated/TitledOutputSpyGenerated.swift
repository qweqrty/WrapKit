// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif
import WrapKit
#if canImport(SwiftUI)
import SwiftUI
#endif
import WrapKit

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
    public private(set) var capturedDisplayModel: [(TitledViewPresentableModel?)] = []
    public private(set) var capturedDisplayTitles: [(Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)] = []
    public private(set) var capturedDisplayBottomTitles: [(Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)] = []
    public private(set) var capturedDisplayLeadingBottomTitle: [(TextOutputPresentableModel?)] = []
    public private(set) var capturedDisplayTrailingBottomTitle: [(TextOutputPresentableModel?)] = []
    public private(set) var capturedDisplayIsUserInteractionEnabled: [(Bool)] = []
    public private(set) var capturedDisplayIsHidden: [(Bool)] = []

    // MARK: - TitledOutput methods
    public func display(model: TitledViewPresentableModel?) {
        capturedDisplayModel.append((model))
        messages.append(.displayModel(model: model))
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        capturedDisplayTitles.append((titles))
        messages.append(.displayTitles(titles: titles))
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        capturedDisplayBottomTitles.append((bottomTitles))
        messages.append(.displayBottomTitles(bottomTitles: bottomTitles))
    }
    public func display(leadingBottomTitle: TextOutputPresentableModel?) {
        capturedDisplayLeadingBottomTitle.append((leadingBottomTitle))
        messages.append(.displayLeadingBottomTitle(leadingBottomTitle: leadingBottomTitle))
    }
    public func display(trailingBottomTitle: TextOutputPresentableModel?) {
        capturedDisplayTrailingBottomTitle.append((trailingBottomTitle))
        messages.append(.displayTrailingBottomTitle(trailingBottomTitle: trailingBottomTitle))
    }
    public func display(isUserInteractionEnabled: Bool) {
        capturedDisplayIsUserInteractionEnabled.append((isUserInteractionEnabled))
        messages.append(.displayIsUserInteractionEnabled(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append((isHidden))
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
