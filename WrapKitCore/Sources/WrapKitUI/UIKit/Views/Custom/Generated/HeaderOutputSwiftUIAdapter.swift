// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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
public class HeaderOutputSwiftUIAdapter: ObservableObject, HeaderOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: HeaderPresentableModel?
    }
    public func display(model: HeaderPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayStyleState: DisplayStyleState? = nil
    public struct DisplayStyleState {
        public let style: HeaderPresentableModel.Style?
    }
    public func display(style: HeaderPresentableModel.Style?) {
        displayStyleState = .init(
            style: style
        )
    }
    @Published public var displayCenterViewState: DisplayCenterViewState? = nil
    public struct DisplayCenterViewState {
        public let centerView: HeaderPresentableModel.CenterView?
    }
    public func display(centerView: HeaderPresentableModel.CenterView?) {
        displayCenterViewState = .init(
            centerView: centerView
        )
    }
    @Published public var displayLeadingCardState: DisplayLeadingCardState? = nil
    public struct DisplayLeadingCardState {
        public let leadingCard: CardViewPresentableModel?
    }
    public func display(leadingCard: CardViewPresentableModel?) {
        displayLeadingCardState = .init(
            leadingCard: leadingCard
        )
    }
    @Published public var displayPrimeTrailingImageState: DisplayPrimeTrailingImageState? = nil
    public struct DisplayPrimeTrailingImageState {
        public let primeTrailingImage: ButtonPresentableModel?
    }
    public func display(primeTrailingImage: ButtonPresentableModel?) {
        displayPrimeTrailingImageState = .init(
            primeTrailingImage: primeTrailingImage
        )
    }
    @Published public var displaySecondaryTrailingImageState: DisplaySecondaryTrailingImageState? = nil
    public struct DisplaySecondaryTrailingImageState {
        public let secondaryTrailingImage: ButtonPresentableModel?
    }
    public func display(secondaryTrailingImage: ButtonPresentableModel?) {
        displaySecondaryTrailingImageState = .init(
            secondaryTrailingImage: secondaryTrailingImage
        )
    }
    @Published public var displayTertiaryTrailingImageState: DisplayTertiaryTrailingImageState? = nil
    public struct DisplayTertiaryTrailingImageState {
        public let tertiaryTrailingImage: ButtonPresentableModel?
    }
    public func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        displayTertiaryTrailingImageState = .init(
            tertiaryTrailingImage: tertiaryTrailingImage
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
}
