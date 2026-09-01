//
//  SearchBarSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 12/11/25.
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

final class SearchBarSnapshotTests: XCTestCase {
    func test_SearchBar_defaul_state() {
        let snapshotName = "SEARCHBAR_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(model: SearchBarPresentableModel(textField: .init(text: "Some text")))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_SearchBar_defaul_state() {
        let snapshotName = "SEARCHBAR_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(model: SearchBarPresentableModel(textField: .init(text: "Some text.")))

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_SearchBar_with_placeholder() {
        let snapshotName = "SEARCHBAR_WITH_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Search...")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_SearchBar_with_placeholder() {
        let snapshotName = "SEARCHBAR_WITH_PLACEHOLDER"
        let sut = makeSUT()

        sut.display(placeholder: "Search....")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_SearchBar_with_leftView() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        let sut = makeSUT()

        let buttonStyle = ButtonStyle(
            backgroundColor: .red,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        let buttonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        sut.display(leftView: buttonModel)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_SearchBar_with_leftView() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        let sut = makeSUT()

        let buttonStyle = ButtonStyle(
            backgroundColor: .systemRed,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        let buttonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        sut.display(leftView: buttonModel)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_fail_SearchBar_with_leftView_cornerRadius() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        let sut = makeSUT()

        let buttonStyle = ButtonStyle(
            backgroundColor: .red,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius + 1
        )
        sut.display(leftView: .init(title: "Left View", style: buttonStyle))

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_fail_SearchBar_with_leftView_onePixelSpacing() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        let sut = makeSUT()

        let buttonStyle = ButtonStyle(
            backgroundColor: .red,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        sut.display(leftView: .init(title: "Left View", style: buttonStyle))
        sut.display(spacing: 8 + 1 / UIScreen.main.scale)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_SearchBar_with_rightView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_VIEW"
        let sut = makeSUT()

        let buttonStyle = ButtonStyle(
            backgroundColor: .blue,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        let buttonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)
        sut.display(rightView: buttonModel)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_SearchBar_with_rightView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_VIEW"
        let sut = makeSUT()

        let buttonStyle = ButtonStyle(
            backgroundColor: .systemBlue,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        let buttonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)
        sut.display(rightView: buttonModel)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_SearchBar_with_rightView_leftView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_VIEW"
        let sut = makeSUT()

        let buttonStyle = ButtonStyle(
            backgroundColor: .yellow,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        let leftButtonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        let rightButtonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)

        sut.display(model: .init(
            textField: .init(),
            leftView: leftButtonModel,
            rightView: rightButtonModel,
            placeholder: "Type here..."
        ))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_SearchBar_with_symbolSideControlsAndContentInsets() {
        let sut = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))

        sut.display(model: .init(
            textField: .init(text: "WrapKit"),
            leftView: makeSymbolButton(
                identifier: "search.leading",
                accessibilityLabel: "Search",
                systemName: "magnifyingglass"
            ),
            rightView: makeSymbolButton(
                identifier: "search.trailing",
                accessibilityLabel: "Clear",
                systemName: "xmark.circle.fill"
            ),
            backgroundColor: .secondarySystemBackground,
            spacing: 8
        ))

        assertParity(
            snapshot: sut,
            named: "SEARCHBAR_WITH_SYMBOL_SIDE_CONTROLS_AND_CONTENT_INSETS",
            reason: "Exact outer/inner inset geometry and side-control callbacks are covered independently."
        )
    }

    func test_contentInsets_placeBothSideControlsAndTextFieldAtExactOffsets() {
        let sut = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))
        sut.display(model: .init(
            textField: .init(),
            leftView: makeGeometryButton(systemName: "magnifyingglass"),
            rightView: makeGeometryButton(systemName: "xmark"),
            spacing: 8
        ))

        layout(sut)

        XCTAssertEqual(sut.uiKitView.leftView.frame.minX, 8, accuracy: 0.001)
        XCTAssertEqual(
            sut.uiKitView.textfield.frame.minX - sut.uiKitView.leftView.frame.maxX,
            8,
            accuracy: 0.001
        )
        XCTAssertEqual(
            sut.uiKitView.rightView.frame.minX - sut.uiKitView.textfield.frame.maxX,
            8,
            accuracy: 0.001
        )
        XCTAssertEqual(
            sut.uiKitView.bounds.width - sut.uiKitView.rightView.frame.maxX,
            8,
            accuracy: 0.001
        )
    }

    func test_contentInsets_preserveExactOffsetsWithOnlyLeadingControl() {
        let sut = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))
        sut.display(model: .init(
            textField: .init(),
            leftView: makeGeometryButton(systemName: "magnifyingglass"),
            spacing: 8
        ))

        layout(sut)

        XCTAssertEqual(sut.uiKitView.leftView.frame.minX, 8, accuracy: 0.001)
        XCTAssertEqual(
            sut.uiKitView.textfield.frame.minX - sut.uiKitView.leftView.frame.maxX,
            8,
            accuracy: 0.001
        )
        XCTAssertEqual(
            sut.uiKitView.bounds.width - sut.uiKitView.textfield.frame.maxX,
            8,
            accuracy: 0.001
        )
        XCTAssertTrue(sut.uiKitView.rightView.isHidden)
    }

    func test_contentInsets_preserveExactOffsetsWithOnlyTrailingControl() {
        let sut = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))
        sut.display(model: .init(
            textField: .init(),
            rightView: makeGeometryButton(systemName: "xmark"),
            spacing: 8
        ))

        layout(sut)

        XCTAssertEqual(sut.uiKitView.textfield.frame.minX, 8, accuracy: 0.001)
        XCTAssertEqual(
            sut.uiKitView.rightView.frame.minX - sut.uiKitView.textfield.frame.maxX,
            8,
            accuracy: 0.001
        )
        XCTAssertEqual(
            sut.uiKitView.bounds.width - sut.uiKitView.rightView.frame.maxX,
            8,
            accuracy: 0.001
        )
        XCTAssertTrue(sut.uiKitView.leftView.isHidden)
    }

    func test_displayNilTextField_hidesOnlyTextFieldAndKeepsSideCallbacks() {
        let sut = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))
        var actions: [String] = []
        sut.display(model: .init(
            textField: nil,
            leftView: makeSymbolButton(
                identifier: "search.leading",
                accessibilityLabel: "Search",
                systemName: "magnifyingglass",
                onPress: { actions.append("leading") }
            ),
            rightView: makeSymbolButton(
                identifier: "search.trailing",
                accessibilityLabel: "Clear",
                systemName: "xmark.circle.fill",
                onPress: { actions.append("trailing") }
            ),
            spacing: 8
        ))

        layout(sut)
        sut.uiKitView.leftView.sendActions(for: .touchUpInside)
        sut.uiKitView.rightView.sendActions(for: .touchUpInside)

        XCTAssertTrue(sut.uiKitView.textfield.isHidden)
        XCTAssertFalse(sut.uiKitView.leftView.isHidden)
        XCTAssertFalse(sut.uiKitView.rightView.isHidden)
        XCTAssertEqual(sut.uiKitView.stackView.layoutMargins.left, 8, accuracy: 0.001)
        XCTAssertEqual(sut.uiKitView.stackView.layoutMargins.right, 8, accuracy: 0.001)
        XCTAssertEqual(actions, ["leading", "trailing"])
    }

    func test_fail_SearchBar_with_rightView_leftView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_VIEW"
        let sut = makeSUT()

        let buttonStyle = ButtonStyle(
            backgroundColor: .systemYellow,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        let leftButtonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        let rightButtonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)

        sut.display(model: .init(
            textField: .init(),
            leftView: leftButtonModel,
            rightView: rightButtonModel,
            placeholder: "Type here..."
        ))

        assertFail(snapshot: sut, named: snapshotName)
    }
}

private extension SearchBarSnapshotTests {
    func makeSUT(
        contentInsets: WrapKit.EdgeInsets = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PairedSearchBarSnapshotSUT {
        let appearance = makeTextFieldAppearance()
        let textField = Textfield(appearance: appearance)
        let container = makeContainer()
        let sut = PairedSearchBarSnapshotSUT(
            textField: textField,
            textFieldAppearance: appearance,
            uiKitContainer: container,
            contentInsets: contentInsets
        )

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )

        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
    }

    func layout(_ sut: PairedSearchBarSnapshotSUT) {
        sut.uiKitView.setNeedsLayout()
        sut.uiKitView.superview?.setNeedsLayout()
        sut.uiKitView.superview?.layoutIfNeeded()
        sut.uiKitView.layoutIfNeeded()
    }

    func makeGeometryButton(systemName: String) -> ButtonPresentableModel {
        .init(
            image: ImageFactory.systemImage(named: systemName),
            height: 44,
            width: 44,
            style: .init(
                backgroundColor: .clear,
                titleColor: .label,
                cornerStyle: .none
            )
        )
    }

    func makeSymbolButton(
        identifier: String,
        accessibilityLabel: String,
        systemName: String,
        onPress: (() -> Void)? = nil
    ) -> ButtonPresentableModel {
        .init(
            accessibilityIdentifier: identifier,
            accessibility: .init(label: accessibilityLabel),
            image: ImageFactory.systemImage(named: systemName),
            height: 44,
            width: 44,
            style: .init(
                backgroundColor: .clear,
                titleColor: .secondaryLabel,
                cornerStyle: .automatic
            ),
            onPress: onPress
        )
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
