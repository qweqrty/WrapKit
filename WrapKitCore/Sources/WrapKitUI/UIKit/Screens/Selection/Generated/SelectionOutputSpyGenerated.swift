// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
import WrapKit

public final class SelectionOutputSpy: SelectionOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayItems(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String)
        case displayShouldShowSearchBar(shouldShowSearchBar: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayItemsSelectedCountTitle: [([TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], String)] = []
    public private(set) var capturedDisplayShouldShowSearchBar: [(Bool)] = []

    // MARK: - SelectionOutput methods
    public func display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String) {
        capturedDisplayItemsSelectedCountTitle.append((items, selectedCountTitle))
        messages.append(.displayItems(items: items, selectedCountTitle: selectedCountTitle))
    }
    public func display(shouldShowSearchBar: Bool) {
        capturedDisplayShouldShowSearchBar.append((shouldShowSearchBar))
        messages.append(.displayShouldShowSearchBar(shouldShowSearchBar: shouldShowSearchBar))
    }

    // MARK: - Properties
}
