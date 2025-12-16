// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif

public final class SelectionOutputSpy: SelectionOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String)
        case display(shouldShowSearchBar: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayItems: [[TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>]] = []
    public private(set) var capturedDisplaySelectedCountTitle: [String] = []
    public private(set) var capturedDisplayShouldShowSearchBar: [Bool] = []


    // MARK: - SelectionOutput methods
    public func display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String) {
        capturedDisplayItems.append(items)
        capturedDisplaySelectedCountTitle.append(selectedCountTitle)
        messages.append(.display(items: items, selectedCountTitle: selectedCountTitle))
    }
    public func display(shouldShowSearchBar: Bool) {
        capturedDisplayShouldShowSearchBar.append(shouldShowSearchBar)
        messages.append(.display(shouldShowSearchBar: shouldShowSearchBar))
    }

    // MARK: - Properties
}
