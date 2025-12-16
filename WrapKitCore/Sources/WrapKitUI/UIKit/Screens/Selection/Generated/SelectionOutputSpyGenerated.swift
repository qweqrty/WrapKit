// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif

final class SelectionOutputSpy: SelectionOutput {
    enum Message: HashableWithReflection {
        case display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String)
        case display(shouldShowSearchBar: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayItems: [[TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>]] = []
    private(set) var capturedDisplaySelectedCountTitle: [String] = []
    private(set) var capturedDisplayShouldShowSearchBar: [Bool] = []


    // MARK: - SelectionOutput methods
    func display(items: [TableSection<Void, SelectionType.SelectionCellPresentableModel, Void>], selectedCountTitle: String) {
        capturedDisplayItems.append(items)
        capturedDisplaySelectedCountTitle.append(selectedCountTitle)
        messages.append(.display(items: items, selectedCountTitle: selectedCountTitle))
    }
    func display(shouldShowSearchBar: Bool) {
        capturedDisplayShouldShowSearchBar.append(shouldShowSearchBar)
        messages.append(.display(shouldShowSearchBar: shouldShowSearchBar))
    }

    // MARK: - Properties
}
