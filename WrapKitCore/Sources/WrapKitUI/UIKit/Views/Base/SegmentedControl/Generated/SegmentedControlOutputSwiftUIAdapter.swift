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
#if canImport(UIKit)
import UIKit
#endif
public class SegmentedControlOutputSwiftUIAdapter: ObservableObject, SegmentedControlOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayAppearenceState: DisplayAppearenceState? = nil
    public struct DisplayAppearenceState {
        public let appearence: SegmentedControlAppearance
    }
    public func display(appearence: SegmentedControlAppearance) {
        displayAppearenceState = .init(
            appearence: appearence
        )
    }
    @Published public var displaySegmentsState: DisplaySegmentsState? = nil
    public struct DisplaySegmentsState {
        public let segments: [SegmentControlModel]
    }
    public func display(segments: [SegmentControlModel]) {
        displaySegmentsState = .init(
            segments: segments
        )
    }
}
