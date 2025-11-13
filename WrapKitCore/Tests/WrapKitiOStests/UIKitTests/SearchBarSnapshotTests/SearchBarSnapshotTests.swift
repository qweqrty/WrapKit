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
        // GIVEN
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
        
        // WHEN
        let (sut, container) = makeSUT(textField: textField)

        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SEARCHBAR_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SEARCHBAR_DEFAULT_STATE_DARK")
    }
    
    func test_SearchBar_with_placeholder() {
        // GIVEN
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
                    placeholder: .init(color: .black, font: .systemFont(ofSize: 22))
                ))
        
        // WHEN
        let (sut, container) = makeSUT(textField: textField)
        sut.textfield.placeholder = "type here..."
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SEARCHBAR_WITH_PLACEHOLDER_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SEARCHBAR_WITH_PLACEHOLDER_DARK")
    }
    
    func test_SearchBar_with_leftView() {
        // GIVEN
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
                    placeholder: .init(color: .black, font: .systemFont(ofSize: 22))
                ))
        
        // WHEN
        let leftVIew = Button(style: .init(backgroundColor: .red, titleColor: .black), title: "Left view")
        let (sut, container) = makeSUT(leftView: leftVIew, textField: textField)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SEARCHBAR_WITH_LEFTVIEW_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SEARCHBAR_WITH_LEFTVIEW_DARK")
    }
    
    func test_SearchBar_with_rightView() {
        // GIVEN
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
                    placeholder: .init(color: .black, font: .systemFont(ofSize: 22))
                ))
        
        let rightView = Button(style: .init(backgroundColor: .red, titleColor: .black), title: "Right view")
        
        let (sut, container) = makeSUT(textField: textField, rightView: rightView)
        
        // WHEN
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SEARCHBAR_WITH_RIGHTVIEW_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SEARCHBAR_WITH_RIGHTVIEW_DARK")
    }
    
    func test_SearchBar_with_rightView_leftView() {
        // GIVEN
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
                    placeholder: .init(color: .black, font: .systemFont(ofSize: 22))
                ))
        
        let rightView = Button(style: .init(backgroundColor: .red, titleColor: .black), title: "Right view")
        let leftView = Button(style: .init(backgroundColor: .red, titleColor: .black), title: "Left view")
        
        let (sut, container) = makeSUT(leftView: leftView, textField: textField, rightView: rightView)
        
        // WHEN
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "SEARCHBAR_WITH_RIGHT_LEFT_VIEWS_DARK")
    }
}

extension SearchBarSnapshotTests {
    func makeSUT(
        leftView: Button = Button(isHidden: true),
        textField: Textfield,
        spacing: CGFloat = 0,
        rightView: Button = Button(isHidden: true),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: SearchBar, container: UIView) {
        
        let sut = SearchBar(leftView: leftView, textfield: textField, rightView: rightView, spacing: spacing)
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
