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
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> PairedSearchBarSnapshotSUT {
        let appearance = makeTextFieldAppearance()
        let textField = Textfield(appearance: appearance)
        let container = makeContainer()
        let sut = PairedSearchBarSnapshotSUT(
            textField: textField,
            textFieldAppearance: appearance,
            uiKitContainer: container
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
