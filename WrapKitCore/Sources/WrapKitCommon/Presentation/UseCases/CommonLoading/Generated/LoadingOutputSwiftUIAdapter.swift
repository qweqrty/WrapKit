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
public class LoadingOutputSwiftUIAdapter: ObservableObject, LoadingOutput {
        @Published public var isLoading: Bool? = nil

    // Initializer
    public init(
    ) {
    }

    @Published public var displayIsLoadingState: DisplayIsLoadingState? = nil
    public struct DisplayIsLoadingState {
        public let isLoading: Bool
    }
    public func display(isLoading: Bool) {
        displayIsLoadingState = .init(
            isLoading: isLoading
        )
    }
}
