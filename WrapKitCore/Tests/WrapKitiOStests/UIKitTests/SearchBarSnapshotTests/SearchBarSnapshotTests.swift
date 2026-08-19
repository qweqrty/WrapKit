//
//  SearchBarSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 12/11/25.
//

import SwiftUI
import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

final class SearchBarSnapshotTests: XCTestCase {
    private weak var currentPairedSUT: PairedSearchBarSnapshotSUT?

    private var swiftUISnapshotPrecision: Float {
        0.98
    }

    private var swiftUIFailSnapshotPrecision: Float {
        1
    }

    func test_SearchBar_defaul_state() {
        let snapshotName = "SEARCHBAR_DEFAULT_STATE"
        let (sut, container) = makeSUT()

        sut.display(model: SearchBarPresentableModel(textField: .init(text: "Some text")))

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_SearchBar_defaul_state() {
        let snapshotName = "SEARCHBAR_DEFAULT_STATE"
        let (sut, container) = makeSUT()

        sut.display(model: SearchBarPresentableModel(textField: .init(text: "Some text.")))

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_SearchBar_with_placeholder() {
        let snapshotName = "SEARCHBAR_WITH_PLACEHOLDER"
        let (sut, container) = makeSUT()

        sut.display(placeholder: "Search...")

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_SearchBar_with_placeholder() {
        let snapshotName = "SEARCHBAR_WITH_PLACEHOLDER"
        let (sut, container) = makeSUT()

        sut.display(placeholder: "Search....")

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_SearchBar_with_leftView() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        let (sut, container) = makeSUT()

        let buttonStyle = ButtonStyle(backgroundColor: .red, titleColor: .black)
        let buttonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        sut.display(leftView: buttonModel)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_SearchBar_with_leftView() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        let (sut, container) = makeSUT()

        let buttonStyle = ButtonStyle(backgroundColor: .systemRed, titleColor: .black)
        let buttonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        sut.display(leftView: buttonModel)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_SearchBar_with_rightView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_VIEW"
        let (sut, container) = makeSUT()

        let buttonStyle = ButtonStyle(backgroundColor: .blue, titleColor: .black)
        let buttonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)
        sut.display(rightView: buttonModel)

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_SearchBar_with_rightView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_VIEW"
        let (sut, container) = makeSUT()

        let buttonStyle = ButtonStyle(backgroundColor: .systemBlue, titleColor: .black)
        let buttonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)
        sut.display(rightView: buttonModel)

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }

    func test_SearchBar_with_rightView_leftView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_VIEW"
        let (sut, container) = makeSUT()

        let buttonStyle = ButtonStyle(backgroundColor: .yellow, titleColor: .black)
        let leftButtonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        let rightButtonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)

        sut.display(model: .init(
            textField: .init(),
            leftView: leftButtonModel,
            rightView: rightButtonModel,
            placeholder: "Type here..."
        ))

        assertPairedSnapshots(container: container, snapshotName: snapshotName)
    }

    func test_fail_SearchBar_with_rightView_leftView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_VIEW"
        let (sut, container) = makeSUT()

        let buttonStyle = ButtonStyle(backgroundColor: .systemYellow, titleColor: .black)
        let leftButtonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        let rightButtonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)

        sut.display(model: .init(
            textField: .init(),
            leftView: leftButtonModel,
            rightView: rightButtonModel,
            placeholder: "Type here..."
        ))

        assertPairedSnapshotsFail(container: container, snapshotName: snapshotName)
    }
}

private extension SearchBarSnapshotTests {
    func assertPairedSnapshots(container: UIView, snapshotName: String, file: StaticString = #filePath, line: UInt = #line) {
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }

    func recordPairedSnapshots(container: UIView, snapshotName: String, file: StaticString = #filePath, line: UInt = #line) {
        if #available(iOS 26, *) {
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            recordPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }

    func assertPairedSnapshotsFail(container: UIView, snapshotName: String, file: StaticString = #filePath, line: UInt = #line) {
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK", file: file, line: line)
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT", file: file, line: line)
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK", file: file, line: line)
        }
    }

    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let uiKitSnapshotName = resolvedUIKitSnapshotName(for: name, file: file)
        assert(snapshot: snapshot, named: uiKitSnapshotName, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assert(
                snapshot: swiftUISnapshot,
                named: uiKitSnapshotName,
                precision: swiftUISnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func assertPairedSnapshotFail(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let uiKitSnapshotName = resolvedUIKitSnapshotName(for: name, file: file)
        assertFail(snapshot: snapshot, named: uiKitSnapshotName, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assertFail(
                snapshot: swiftUISnapshot,
                named: uiKitSnapshotName,
                precision: swiftUIFailSnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func recordPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        record(snapshot: snapshot, named: recordedSnapshotName(for: name), file: file, line: line)
    }

    func resolvedUIKitSnapshotName(for snapshotName: String, file: StaticString) -> String {
        let prefixed = recordedSnapshotName(for: snapshotName)
        if snapshotExists(named: prefixed, file: file) {
            return prefixed
        }
        return snapshotName
    }

    func snapshotExists(named name: String, file: StaticString) -> Bool {
        let url = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        return FileManager.default.fileExists(atPath: url.path)
    }

    func colorScheme(from snapshotName: String) -> ColorScheme {
        normalizedSnapshotName(from: snapshotName).hasSuffix("_DARK") ? .dark : .light
    }

    func recordedSnapshotName(for snapshotName: String) -> String {
        "UIKit_\(normalizedSnapshotName(from: snapshotName))"
    }

    func normalizedSnapshotName(from snapshotName: String) -> String {
        if snapshotName.hasPrefix("UIKit_") {
            return String(snapshotName.dropFirst("UIKit_".count))
        }
        if snapshotName.hasPrefix("SiwftUI_") {
            return String(snapshotName.dropFirst("SiwftUI_".count))
        }
        if snapshotName.hasPrefix("SwiftUI_") {
            return String(snapshotName.dropFirst("SwiftUI_".count))
        }
        return snapshotName
    }

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: PairedSearchBarSnapshotSUT, container: UIView) {
        let appearance = makeTextFieldAppearance()
        let textField = Textfield(appearance: appearance)
        let sut = PairedSearchBarSnapshotSUT(
            textField: textField,
            textFieldAppearance: appearance
        )
        let container = makeContainer()

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )

        container.layoutIfNeeded()
        currentPairedSUT = sut

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return (sut, container)
    }

    func makeTextFieldAppearance() -> TextfieldAppearance {
        .init(
            colors: .init(
                textColor: .black,
                selectedBorderColor: .green,
                selectedBackgroundColor: .cyan,
                selectedErrorBorderColor: .red,
                errorBorderColor: .systemRed,
                errorBackgroundColor: .yellow,
                deselectedBorderColor: .cyan,
                deselectedBackgroundColor: .systemBlue,
                disabledTextColor: .brown,
                disabledBackgroundColor: .purple
            ),
            font: .systemFont(ofSize: 32),
            border: .init(idleBorderWidth: 0, selectedBorderWidth: 0),
            placeholder: .init(color: .systemGray, font: .systemFont(ofSize: 22))
        )
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
