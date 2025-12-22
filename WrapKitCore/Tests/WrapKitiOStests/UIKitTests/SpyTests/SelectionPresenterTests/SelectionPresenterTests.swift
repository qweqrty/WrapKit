//
//  SelectionPresenterTests.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 18/12/25.
//

import Foundation
import XCTest
import WrapKit

final class SelectionPresenterTests: XCTestCase {
    func test_viewDidLoad_selectionOutput_shouldShowSearchBar() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        XCTAssertEqual(viewSpy.messages.first, .displayShouldShowSearchBar(shouldShowSearchBar: true))
    }
    
    func test_viewDidLoad_headerOutput_displayModel() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let headerSpy = components.headerSpy
        let config = nurSelection()

        // WHEN
        sut.viewDidLoad()

        let expectedModel = HeaderPresentableModel(
            style: config.navBar,
            centerView: nil,
            leadingCard: .init(id: headerSpy.capturedDisplayModel.first??.leadingCard?.id ?? "", title: .text("Select")),
            primeTrailingImage: config.content.backButtonImage.map { .init(image: $0, onPress: headerSpy.capturedDisplayModel.first??.primeTrailingImage?.onPress) }
        )

        // THEN
        XCTAssertEqual(headerSpy.messages.first, .displayModel(model: expectedModel) )
    }
    
    func test_viewDidLoad_emptyViewOutput_displayModel() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let emptyViewSpy = components.emptyViewSpy
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        let model = EmptyViewPresentableModel(title: .text("Empty View"))
        
        XCTAssertEqual(emptyViewSpy.messages.first, .displayModel(model: model))
    }
    
    func test_viewDidLoad_resetButtonOutput_displayModel() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let resetButtonSpy = components.resetSpy
        let config = nurSelection()
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        let style = ButtonStyle(
            borderWidth: 1,
            cornerRadius: 16
        )
        
        let model = ButtonPresentableModel(
            title: config.texts.resetTitle,
            height: 48.0,
            style: style,
            enabled: false,
            onPress: resetButtonSpy.capturedDisplayModel.first??.onPress
        )
        
        XCTAssertEqual(resetButtonSpy.messages.first, .displayModel(model: model))
    }
    
    func test_viewDidLoad_searchButtonOutput_displayModel() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let searchButtonSpy = components.selectButton
        
        let config = nurSelection()
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        let style = ButtonStyle(
            backgroundColor: config.searchButton.backgroundColor,
            titleColor: config.searchButton.textColor,
            borderWidth: 0.0,
            borderColor: config.searchButton.borderColor,
            cornerRadius: 16.0
        )

        let model = ButtonPresentableModel(
            title: config.texts.selectTitle,
            height: 48.0,
            style: style,
            enabled: true,
            onPress: searchButtonSpy.capturedDisplayModel.first??.onPress
        )
        
        XCTAssertEqual(searchButtonSpy.messages.first, .displayModel(model: model))
    }
    
    func test_viewDidLoad_resetButtonOutput_onPress_shouldUpdateStyle() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let resetButtonSpy = components.resetSpy
        let config = nurSelection()
        
        // WHEN
        sut.items[0].isSelected.set(model: true)
        sut.viewDidLoad()
        
        let onPress = resetButtonSpy.capturedDisplayModel.first??.onPress
        
        resetButtonSpy.reset()
        
        onPress?()
        
        // THEN
        let expectedStyle = ButtonStyle(
            backgroundColor: config.resetButtonColors.inactiveBackgroundColor,
            titleColor: config.resetButtonColors.inactiveTitleColor,
            borderWidth: 0,
            borderColor: config.resetButtonColors.inactiveBorderColor,
            cornerRadius: 12
        )
        
        XCTAssertEqual(resetButtonSpy.messages.first, .displayStyle(style: expectedStyle))
    }
    
    func test_viewDidLoad_selectButtonOutput_onPress() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let selectButtonSpy = components.selectButton
        let flowSpy = components.flowSpy
        
        sut.items[0].isSelected.set(model: true)
        
        // WHEN
        sut.viewDidLoad()
        
        let onPress = selectButtonSpy.capturedDisplayModel.first??.onPress
        onPress?()
        
        XCTAssertEqual(flowSpy.messages.count, 1)
        
        if case .closeResult(let result)? = flowSpy.messages.first,
           case .multipleSelection(let items)? = result {
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first?.id, "1")
        } else {
            XCTFail("Expected flow.close to be called with multipleSelection")
        }
    }
    
}

fileprivate extension SelectionPresenterTests {
    
    struct SUTComponents {
        let sut: SelectionPresenter
        let headerSpy: HeaderOutputSpy
        let resetSpy: ButtonOutputSpy
        let viewSpy: SelectionOutputSpy
        let selectButton: ButtonOutputSpy
        let emptyViewSpy: EmptyViewOutputSpy
        let flowSpy: SelectionFlowSpy
    }
    
    func makeSUT() -> SUTComponents {
        
        let items = (1...16).map { index in
            SelectionType.SelectionCellPresentableModel(
                id: "\(index)",
                title: "Item \(index)",
                onPress: nil,
                configuration: .init(
                    titleFont: .boldSystemFont(ofSize: 14),
                    trailingFont: .boldSystemFont(ofSize: 14),
                    titleColor: .black,
                    trailingColor: .red,
                    lineColor: .gray
                )
            )
        }
        
        let model = SelectionPresenterModel(
            title: "Select",
            isMultipleSelectionEnabled: true,
            items: items,
            callback: nil,
            emptyViewPresentableModel: .init(title: .text("Empty View")),
            screenViewAnalytics: nil)
        
        let flow = SelectionFlowSpy()
        
        let sut = SelectionPresenter(flow: flow.mainQueueDispatched, model: model, configuration: nurSelection())
        let headerSpy = HeaderOutputSpy()
        let resetButtonSpy = ButtonOutputSpy()
        let viewSpy = SelectionOutputSpy()
        let selectButtonSpy = ButtonOutputSpy()
        let emptyViewSpy = EmptyViewOutputSpy()
        sut.navBarView = headerSpy
            .weakReferenced
            .mainQueueDispatched
        sut.resetButton = resetButtonSpy
            .weakReferenced
            .mainQueueDispatched
        sut.selectButton = selectButtonSpy
            .weakReferenced
            .mainQueueDispatched
        sut.emptyView = emptyViewSpy
            .weakReferenced
            .mainQueueDispatched
        sut.view = viewSpy
            .weakReferenced
            .mainQueueDispatched
        
        return SUTComponents(
            sut: sut,
            headerSpy: headerSpy,
            resetSpy: resetButtonSpy,
            viewSpy: viewSpy,
            selectButton: selectButtonSpy,
            emptyViewSpy: emptyViewSpy,
            flowSpy: flow
        )
    }
    
    private func nurSelection(isMultiply: Bool = false) -> SelectionConfiguration{
        SelectionConfiguration(
            texts: SelectionConfiguration.Texts(
                searchTitle: "Поиск",
                resetTitle: "Сбросить",
                selectTitle: "Выбрать",
                selectedCountTitle: "Выбрано"
            ),
            content: SelectionConfiguration.Content.init(
                lineColor: .gray,
                backgroundColor: .systemBackground,
                refreshColor: .placeholderText,
                backButtonImage: Image(systemName: "arrow.backward"),
                navBarFont: .boldSystemFont(ofSize: 14),
                navBarTextColor: .black,
                shadowBackgroundColor: .black.withAlphaComponent(0.5)
            ),
            navBar: .init(
                backgroundColor: .red,
                horizontalSpacing: 0,
                primeFont: .boldSystemFont(ofSize: 14),
                primeColor: .black,
                secondaryFont: .boldSystemFont(ofSize: 14),
                secondaryColor: .systemRed
            ),
            
            resetButton: isMultiply ? SelectionConfiguration.ActionButton.init(
                labelFont: .boldSystemFont(ofSize: 14),
                textColor: .black,
                backgroundColor: .systemBackground,
                borderColor: .clear,
            ) : nil,
            searchButton: SelectionConfiguration.ActionButton.init(
                labelFont: .boldSystemFont(ofSize: 14),
                textColor: .black,
                backgroundColor: .systemBackground,
                borderColor: .clear
            ),
            searchBar: SelectionConfiguration.SearchBar.init(
                textfieldAppearence: nurTextfieldAppearance(placeholderText: "placeholder"),
                searchImage: Image(systemName: "magnifyingglass")!,
                tintColor: .lightGray
            ),
            resetButtonColors: SelectionConfiguration.ResetButtonColors(
                activeTitleColor: .blue,
                activeBorderColor: .clear,
                activeBackgroundColor: .systemBlue,
                inactiveTitleColor: .gray,
                inactiveBorderColor: .clear,
                inactiveBackgroundColor: .darkGray
            )
        )
    }
    
    private func nurTextfieldAppearance(placeholderText: String? = nil) -> TextfieldAppearance {
        TextfieldAppearance (
            colors: .init(
                textColor: .black,
                selectedBorderColor: .blue,
                selectedBackgroundColor: .systemBlue,
                selectedErrorBorderColor: .red,
                errorBorderColor: .red,
                errorBackgroundColor: .systemRed,
                deselectedBorderColor: .black,
                deselectedBackgroundColor: .black,
                disabledTextColor: .lightGray,
                disabledBackgroundColor: .cyan
            ),
            font: .boldSystemFont(ofSize: 14),
            placeholder: .init(
                color: .lightGray,
                disabledColor: .lightGray,
                font: .boldSystemFont(ofSize: 12),
                text: placeholderText
            )
        )
    }
    
}
