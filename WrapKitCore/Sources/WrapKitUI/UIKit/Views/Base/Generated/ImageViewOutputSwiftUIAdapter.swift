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
#if canImport(SwiftUICore)
import SwiftUICore
#endif
public class ImageViewOutputSwiftUIAdapter: ObservableObject, ImageViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: ImageViewPresentableModel?
    }
    public func display(model: ImageViewPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayImageState: DisplayImageState? = nil
    public struct DisplayImageState {
        public let image: ImageEnum?
    }
    public func display(image: ImageEnum?) {
        displayImageState = .init(
            image: image
        )
    }
    @Published public var displaySizeState: DisplaySizeState? = nil
    public struct DisplaySizeState {
        public let size: CGSize?
    }
    public func display(size: CGSize?) {
        displaySizeState = .init(
            size: size
        )
    }
    @Published public var displayOnPressState: DisplayOnPressState? = nil
    public struct DisplayOnPressState {
        public let onPress: (() -> Void)?
    }
    public func display(onPress: (() -> Void)?) {
        displayOnPressState = .init(
            onPress: onPress
        )
    }
    @Published public var displayOnLongPressState: DisplayOnLongPressState? = nil
    public struct DisplayOnLongPressState {
        public let onLongPress: (() -> Void)?
    }
    public func display(onLongPress: (() -> Void)?) {
        displayOnLongPressState = .init(
            onLongPress: onLongPress
        )
    }
    @Published public var displayContentModeIsFitState: DisplayContentModeIsFitState? = nil
    public struct DisplayContentModeIsFitState {
        public let contentModeIsFit: Bool
    }
    public func display(contentModeIsFit: Bool) {
        displayContentModeIsFitState = .init(
            contentModeIsFit: contentModeIsFit
        )
    }
    @Published public var displayBorderWidthState: DisplayBorderWidthState? = nil
    public struct DisplayBorderWidthState {
        public let borderWidth: CGFloat?
    }
    public func display(borderWidth: CGFloat?) {
        displayBorderWidthState = .init(
            borderWidth: borderWidth
        )
    }
    @Published public var displayBorderColorState: DisplayBorderColorState? = nil
    public struct DisplayBorderColorState {
        public let borderColor: Color?
    }
    public func display(borderColor: Color?) {
        displayBorderColorState = .init(
            borderColor: borderColor
        )
    }
    @Published public var displayCornerRadiusState: DisplayCornerRadiusState? = nil
    public struct DisplayCornerRadiusState {
        public let cornerRadius: CGFloat?
    }
    public func display(cornerRadius: CGFloat?) {
        displayCornerRadiusState = .init(
            cornerRadius: cornerRadius
        )
    }
    @Published public var displayAlphaState: DisplayAlphaState? = nil
    public struct DisplayAlphaState {
        public let alpha: CGFloat?
    }
    public func display(alpha: CGFloat?) {
        displayAlphaState = .init(
            alpha: alpha
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
