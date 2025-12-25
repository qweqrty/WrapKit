// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class SegmentedControlOutputSpy: SegmentedControlOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayAppearence(appearence: SegmentedControlAppearance)
        case displaySegments(segments: [SegmentControlModel])
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayAppearence: [SegmentedControlAppearance] = []
    public private(set) var capturedDisplaySegments: [[SegmentControlModel]] = []


    // MARK: - SegmentedControlOutput methods
    public func display(appearence: SegmentedControlAppearance) {
        capturedDisplayAppearence.append(appearence)
        messages.append(.displayAppearence(appearence: appearence))
    }
    public func display(segments: [SegmentControlModel]) {
        capturedDisplaySegments.append(segments)
        messages.append(.displaySegments(segments: segments))
    }

    // MARK: - Properties
}
