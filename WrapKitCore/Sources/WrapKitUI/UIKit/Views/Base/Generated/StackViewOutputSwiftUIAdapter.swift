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
public class StackViewOutputSwiftUIAdapter: ObservableObject, StackViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: StackViewPresentableModel
    }
    public func display(model: StackViewPresentableModel) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displaySpacingState: DisplaySpacingState? = nil
    public struct DisplaySpacingState {
        public let spacing: CGFloat?
    }
    public func display(spacing: CGFloat?) {
        displaySpacingState = .init(
            spacing: spacing
        )
    }
    @Published public var displayAxisState: DisplayAxisState? = nil
    public struct DisplayAxisState {
        public let axis: StackViewAxis
    }
    public func display(axis: StackViewAxis) {
        displayAxisState = .init(
            axis: axis
        )
    }
    @Published public var displayDistributionState: DisplayDistributionState? = nil
    public struct DisplayDistributionState {
        public let distribution: StackViewDistribution
    }
    public func display(distribution: StackViewDistribution) {
        displayDistributionState = .init(
            distribution: distribution
        )
    }
    @Published public var displayAlignmentState: DisplayAlignmentState? = nil
    public struct DisplayAlignmentState {
        public let alignment: StackViewAlignment
    }
    public func display(alignment: StackViewAlignment) {
        displayAlignmentState = .init(
            alignment: alignment
        )
    }
    @Published public var displayLayoutMarginsState: DisplayLayoutMarginsState? = nil
    public struct DisplayLayoutMarginsState {
        public let layoutMargins: EdgeInsets
    }
    public func display(layoutMargins: EdgeInsets) {
        displayLayoutMarginsState = .init(
            layoutMargins: layoutMargins
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
