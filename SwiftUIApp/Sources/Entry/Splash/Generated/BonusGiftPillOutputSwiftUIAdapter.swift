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
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(WrapKit)
import WrapKit
#endif
public class BonusGiftPillOutputSwiftUIAdapter: ObservableObject, BonusGiftPillOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: BonusGiftPillPresentableModel
    }
    public func display(model: BonusGiftPillPresentableModel) {
        displayModelState = .init(
            model: model
        )
    }
}
