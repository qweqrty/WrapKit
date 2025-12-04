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
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let model = SearchBarPresentableModel(textField: .init(text: "Some text"))
        
        sut.display(model: model)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_SearchBar_with_placeholder() {
        let snapshotName = "SEARCHBAR_WITH_PLACEHOLDER"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(placeholder: "Search...")
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_SearchBar_with_leftView() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let buttonStyle = ButtonStyle(backgroundColor: .red, titleColor: .black)
        let buttonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        sut.display(leftView: buttonModel)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_SearchBar_with_leftView() {
        let snapshotName = "SEARCHBAR_WITH_LEFTVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let buttonStyle = ButtonStyle(backgroundColor: .systemRed, titleColor: .black)
        let buttonModel = ButtonPresentableModel(title: "Left View", style: buttonStyle)
        sut.display(leftView: buttonModel)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_SearchBar_with_rightView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_VIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let buttonStyle = ButtonStyle(backgroundColor: .blue, titleColor: .black)
        let buttonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)
        sut.display(rightView: buttonModel)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_SearchBar_with_rightView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_VIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let buttonStyle = ButtonStyle(backgroundColor: .systemBlue, titleColor: .black)
        let buttonModel = ButtonPresentableModel(title: "Right View", style: buttonStyle)
        sut.display(rightView: buttonModel)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_SearchBar_with_rightView_leftView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_VIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let buttonStyle = ButtonStyle(backgroundColor: .yellow, titleColor: .black)
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
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_SearchBar_with_rightView_leftView() {
        let snapshotName = "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_VIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let buttonStyle = ButtonStyle(backgroundColor: .systemYellow, titleColor: .black)
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
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
}

extension SearchBarSnapshotTests {
    func makeSUT(
        leftView: Button = Button(isHidden: true),
        spacing: CGFloat = 0,
        rightView: Button = Button(isHidden: true),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: SearchBar, container: UIView) {
        
        let textField = Textfield(appearance:
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
                ))
        
        let sut = SearchBar(textfield: textField)
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
