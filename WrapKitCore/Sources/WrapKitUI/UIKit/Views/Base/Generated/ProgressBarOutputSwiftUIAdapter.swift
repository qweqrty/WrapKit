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
#if canImport(SwiftUI)
import SwiftUI
#endif
public class ProgressBarOutputSwiftUIAdapter: ObservableObject, ProgressBarOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: ProgressBarPresentableModel?
    }
    public func display(model: ProgressBarPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayProgressState: DisplayProgressState? = nil
    public struct DisplayProgressState {
        public let progress: CGFloat
    }
    public func display(progress: CGFloat) {
        displayProgressState = .init(
            progress: progress
        )
    }
    @Published public var displayStyleState: DisplayStyleState? = nil
    public struct DisplayStyleState {
        public let style: ProgressBarStyle?
    }
    public func display(style: ProgressBarStyle?) {
        displayStyleState = .init(
            style: style
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
