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
public class CommonToastOutputSwiftUIAdapter: ObservableObject, CommonToastOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayToastState: DisplayToastState? = nil
    public struct DisplayToastState {
        public let toast: CommonToast
    }
    public func display(_ toast: CommonToast) {
        displayToastState = .init(
            toast: toast
        )
    }
    @Published public var hideState: HideState? = nil
    public struct HideState {
    }
    public func hide() {
        hideState = .init(
        )
    }
}
