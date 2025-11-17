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
public class SelectionOutputSwiftUIAdapter: ObservableObject, SelectionOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayItemsSelectedCountTitleState: DisplayItemsSelectedCountTitleState? = nil
    public struct DisplayItemsSelectedCountTitleState {
        public let items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>]
        public let selectedCountTitle: String
    }
    public func display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String) {
        displayItemsSelectedCountTitleState = .init(
            items: items, 
            selectedCountTitle: selectedCountTitle
        )
    }
    @Published public var displayShouldShowSearchBarState: DisplayShouldShowSearchBarState? = nil
    public struct DisplayShouldShowSearchBarState {
        public let shouldShowSearchBar: Bool
    }
    public func display(shouldShowSearchBar: Bool) {
        displayShouldShowSearchBarState = .init(
            shouldShowSearchBar: shouldShowSearchBar
        )
    }
}
