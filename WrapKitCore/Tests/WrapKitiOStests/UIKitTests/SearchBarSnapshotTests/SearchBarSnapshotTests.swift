//
//  SearchBarSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 12/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class SearchBarSnapshotTests: XCTestCase {
    func test_SearchBar_defaul_state() {
        let snapshotName = "SEARCHBAR_DEFAULT_STATE"

        let (sut, container) = makeSUT()
        sut.display(model: SearchBarPresentableModel(textField: .init(text: "Some text")))

        assertUIKitSnapshots(container, named: snapshotName)
    }

    func test_fail_SearchBar_defaul_state() {
        let snapshotName = "SEARCHBAR_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let model = SearchBarPresentableModel(textField: .init(text: "Some text."))
        
        sut.display(model: model)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_SearchBar_with_placeholder() {
        let snapshotName = "SEARCHBAR_WITH_PLACEHOLDER"

        let (sut, container) = makeSUT()
        sut.display(placeholder: "Search...")

        assertUIKitSnapshots(container, named: snapshotName)
    }

    func test_fail_SearchBar_with_placeholder() {
        let snapshotName = "SEARCHBAR_WITH_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Search....")
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_SearchBar_with_leftView() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"

        let (sut, container) = makeSUT()
        let buttonStyle = ButtonStyle(
            backgroundColor: .red,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        sut.display(leftView: .init(title: "Left View", style: buttonStyle))

        assertUIKitSnapshots(container, named: snapshotName)
    }

    func test_fail_SearchBar_with_leftView() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let buttonStyle = ButtonStyle(
            backgroundColor: .systemRed,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        let buttonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        sut.display(leftView: buttonModel)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_SearchBar_with_rightView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_VIEW"

        let (sut, container) = makeSUT()
        let buttonStyle = ButtonStyle(
            backgroundColor: .blue,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        sut.display(rightView: .init(title: "Right View", style: buttonStyle))

        assertUIKitSnapshots(container, named: snapshotName)
    }

    func test_fail_SearchBar_with_rightView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_VIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let buttonStyle = ButtonStyle(
            backgroundColor: .systemBlue,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        let buttonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)
        sut.display(rightView: buttonModel)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_SearchBar_with_rightView_leftView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_VIEW"

        let (sut, container) = makeSUT()
        let buttonStyle = ButtonStyle(
            backgroundColor: .yellow,
            titleColor: .black,
            cornerRadius: ButtonStyle.defaultCornerRadius
        )
        sut.display(model: .init(
            textField: .init(),
            leftView: .init(title: "Left View", style: buttonStyle),
            rightView: .init(title: "Right View", style: buttonStyle),
            placeholder: "Type here..."
        ))

        assertUIKitSnapshots(container, named: snapshotName)
    }

    func test_SearchBar_with_symbolSideControlsAndContentInsets() {
        let snapshotName = "SEARCHBAR_WITH_SYMBOL_SIDE_CONTROLS_AND_CONTENT_INSETS"
        let (sut, container) = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))

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

        assertUIKitSnapshots(container, named: snapshotName)
    }

    func test_fail_SearchBar_with_symbolSideControlsAndContentInsets() {
        let snapshotName = "SEARCHBAR_WITH_SYMBOL_SIDE_CONTROLS_AND_CONTENT_INSETS"
        let (sut, container) = makeSUT(contentInsets: .init(horizontal: 9, vertical: 0))

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

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_contentInsets_placeBothSideControlsAndTextFieldAtExactOffsets() {
        let (sut, _) = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))
        sut.display(model: .init(
            textField: .init(),
            leftView: makeGeometryButton(systemName: "magnifyingglass"),
            rightView: makeGeometryButton(systemName: "xmark"),
            spacing: 8
        ))

        layout(sut)

        XCTAssertEqual(sut.leftView.frame.minX, 8, accuracy: 0.001)
        XCTAssertEqual(sut.textfield.frame.minX - sut.leftView.frame.maxX, 8, accuracy: 0.001)
        XCTAssertEqual(sut.rightView.frame.minX - sut.textfield.frame.maxX, 8, accuracy: 0.001)
        XCTAssertEqual(sut.bounds.width - sut.rightView.frame.maxX, 8, accuracy: 0.001)
    }

    func test_contentInsets_preserveExactOffsetsWithOnlyLeadingControl() {
        let (sut, _) = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))
        sut.display(model: .init(
            textField: .init(),
            leftView: makeGeometryButton(systemName: "magnifyingglass"),
            spacing: 8
        ))

        layout(sut)

        XCTAssertEqual(sut.leftView.frame.minX, 8, accuracy: 0.001)
        XCTAssertEqual(sut.textfield.frame.minX - sut.leftView.frame.maxX, 8, accuracy: 0.001)
        XCTAssertEqual(sut.bounds.width - sut.textfield.frame.maxX, 8, accuracy: 0.001)
        XCTAssertTrue(sut.rightView.isHidden)
    }

    func test_contentInsets_preserveExactOffsetsWithOnlyTrailingControl() {
        let (sut, _) = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))
        sut.display(model: .init(
            textField: .init(),
            rightView: makeGeometryButton(systemName: "xmark"),
            spacing: 8
        ))

        layout(sut)

        XCTAssertEqual(sut.textfield.frame.minX, 8, accuracy: 0.001)
        XCTAssertEqual(sut.rightView.frame.minX - sut.textfield.frame.maxX, 8, accuracy: 0.001)
        XCTAssertEqual(sut.bounds.width - sut.rightView.frame.maxX, 8, accuracy: 0.001)
        XCTAssertTrue(sut.leftView.isHidden)
    }

    func test_displayNilTextField_hidesOnlyTextFieldAndKeepsSideCallbacks() {
        let (sut, _) = makeSUT(contentInsets: .init(horizontal: 8, vertical: 0))
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
        sut.leftView.sendActions(for: .touchUpInside)
        sut.rightView.sendActions(for: .touchUpInside)

        XCTAssertTrue(sut.textfield.isHidden)
        XCTAssertFalse(sut.leftView.isHidden)
        XCTAssertFalse(sut.rightView.isHidden)
        XCTAssertEqual(sut.stackView.layoutMargins.left, 8, accuracy: 0.001)
        XCTAssertEqual(sut.stackView.layoutMargins.right, 8, accuracy: 0.001)
        XCTAssertEqual(actions, ["leading", "trailing"])
    }

    func test_fail_SearchBar_with_rightView_leftView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_VIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
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
            placeholder: "Type here...")
        )
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension SearchBarSnapshotTests {
    func makeSUT(
        contentInsets: WrapKit.EdgeInsets = .zero,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: SearchBar, container: UIView) {
        let textField = Textfield(
            cornerStyle: .fixed(10),
            appearance:
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
                        disabledBackgroundColor: .purple),
                    font: .systemFont(ofSize: 32),
                    border: .init(idleBorderWidth: 0, selectedBorderWidth: 0),
                    placeholder: .init(color: .systemGray, font: .systemFont(ofSize: 22))
                )
        )
        
        let sut = SearchBar(textfield: textField, contentInsets: contentInsets)
        let container = makeContainer()

        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
        )
        sut.heightAnchor.constraint(equalTo: textField.heightAnchor).isActive = true

        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }

    func layout(_ sut: SearchBar) {
        sut.setNeedsLayout()
        sut.superview?.setNeedsLayout()
        sut.superview?.layoutIfNeeded()
        sut.layoutIfNeeded()
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
            width: 44,
            style: .init(
                backgroundColor: .clear,
                titleColor: .secondaryLabel,
                cornerStyle: .automatic
            ),
            onPress: onPress
        )
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .systemBackground
        return container
    }
}
