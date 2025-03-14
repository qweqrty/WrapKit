// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
public class KeyValueFieldViewOutputSwiftUIAdapter: ObservableObject, KeyValueFieldViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    }
    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayKeyTitleState: DisplayKeyTitleState? = nil
    public struct DisplayKeyTitleState {
        public let keyTitle: TextOutputPresentableModel?
    }
    public func display(keyTitle: TextOutputPresentableModel?) {
        displayKeyTitleState = .init(
            keyTitle: keyTitle
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
    @Published public var displayBottomImageState: DisplayBottomImageState? = nil
    public struct DisplayBottomImageState {
        public let bottomImage: ImageViewPresentableModel?
    }
    public func display(bottomImage: ImageViewPresentableModel?) {
        displayBottomImageState = .init(
            bottomImage: bottomImage
        )
    }
}
