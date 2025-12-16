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
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public final class TitledOutputSpy: TitledOutput {
    enum Message: HashableWithReflection {
        case display(model: TitledViewPresentableModel?)
        case display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
        case display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
        case display(leadingBottomTitle: TextOutputPresentableModel?)
        case display(trailingBottomTitle: TextOutputPresentableModel?)
        case display(isUserInteractionEnabled: Bool)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [TitledViewPresentableModel?] = []
    private(set) var capturedDisplayTitles: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>] = []
    private(set) var capturedDisplayBottomTitles: [Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>] = []
    private(set) var capturedDisplayLeadingBottomTitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayTrailingBottomTitle: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayIsUserInteractionEnabled: [Bool] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - TitledOutput methods
    func display(model: TitledViewPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        capturedDisplayTitles.append(titles)
        messages.append(.display(titles: titles))
    }
    func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        capturedDisplayBottomTitles.append(bottomTitles)
        messages.append(.display(bottomTitles: bottomTitles))
    }
    func display(leadingBottomTitle: TextOutputPresentableModel?) {
        capturedDisplayLeadingBottomTitle.append(leadingBottomTitle)
        messages.append(.display(leadingBottomTitle: leadingBottomTitle))
    }
    func display(trailingBottomTitle: TextOutputPresentableModel?) {
        capturedDisplayTrailingBottomTitle.append(trailingBottomTitle)
        messages.append(.display(trailingBottomTitle: trailingBottomTitle))
    }
    func display(isUserInteractionEnabled: Bool) {
        capturedDisplayIsUserInteractionEnabled.append(isUserInteractionEnabled)
        messages.append(.display(isUserInteractionEnabled: isUserInteractionEnabled))
    }
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
