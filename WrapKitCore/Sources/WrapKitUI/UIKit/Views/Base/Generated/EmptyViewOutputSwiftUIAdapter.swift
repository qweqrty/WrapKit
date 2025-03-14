// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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
public class EmptyViewOutputSwiftUIAdapter: ObservableObject, EmptyViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: EmptyViewPresentableModel?
    }
    public func display(model: EmptyViewPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayTitleState: DisplayTitleState? = nil
    public struct DisplayTitleState {
        public let title: TextOutputPresentableModel?
    }
    public func display(title: TextOutputPresentableModel?) {
        displayTitleState = .init(
            title: title
        )
    }
    @Published public var displaySubtitleState: DisplaySubtitleState? = nil
    public struct DisplaySubtitleState {
        public let subtitle: TextOutputPresentableModel?
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        displaySubtitleState = .init(
            subtitle: subtitle
        )
    }
    @Published public var displayButtonModelState: DisplayButtonModelState? = nil
    public struct DisplayButtonModelState {
        public let buttonModel: ButtonPresentableModel?
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        displayButtonModelState = .init(
            buttonModel: buttonModel
        )
    }
    @Published public var displayImageState: DisplayImageState? = nil
    public struct DisplayImageState {
        public let image: ImageViewPresentableModel?
    }
    public func display(image: ImageViewPresentableModel?) {
        displayImageState = .init(
            image: image
        )
    }
}
