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
public class EmptyViewOutputSwiftUIAdapter: ObservableObject, EmptyViewOutput {


    private var nextOutputSequence: UInt64 = 0



    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let outputSequence: UInt64
        public let model: EmptyViewPresentableModel?
    }
    public func display(model: EmptyViewPresentableModel?) {
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: model
        )
    }
    @Published public var displayTitleState: DisplayTitleState? = nil
    public struct DisplayTitleState {
        public let outputSequence: UInt64
        public let title: TextOutputPresentableModel?
    }
    public func display(title: TextOutputPresentableModel?) {
        nextOutputSequence &+= 1
        displayTitleState = .init(
            outputSequence: nextOutputSequence,
            title: title
        )
    }
    @Published public var displaySubtitleState: DisplaySubtitleState? = nil
    public struct DisplaySubtitleState {
        public let outputSequence: UInt64
        public let subtitle: TextOutputPresentableModel?
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        nextOutputSequence &+= 1
        displaySubtitleState = .init(
            outputSequence: nextOutputSequence,
            subtitle: subtitle
        )
    }
    @Published public var displayButtonModelState: DisplayButtonModelState? = nil
    public struct DisplayButtonModelState {
        public let outputSequence: UInt64
        public let buttonModel: ButtonPresentableModel?
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        nextOutputSequence &+= 1
        displayButtonModelState = .init(
            outputSequence: nextOutputSequence,
            buttonModel: buttonModel
        )
    }
    @Published public var displayImageState: DisplayImageState? = nil
    public struct DisplayImageState {
        public let outputSequence: UInt64
        public let image: ImageViewPresentableModel?
    }
    public func display(image: ImageViewPresentableModel?) {
        nextOutputSequence &+= 1
        displayImageState = .init(
            outputSequence: nextOutputSequence,
            image: image
        )
    }
    @Published public var displayIsHiddenState: DisplayIsHiddenState? = nil
    public struct DisplayIsHiddenState {
        public let outputSequence: UInt64
        public let isHidden: Bool
    }
    public func display(isHidden: Bool) {
        nextOutputSequence &+= 1
        displayIsHiddenState = .init(
            outputSequence: nextOutputSequence,
            isHidden: isHidden
        )
    }
}
