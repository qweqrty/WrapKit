//
//  SelectionPresenterSpyTests.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 18/12/25.
//

import Foundation
import XCTest
import WrapKit

final class SelectionPresenterSpyTests: XCTestCase {
    func test_viewDidLoad_selectionOutput_shouldShowSearchBar() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        
        sut.viewDidLoad()
        
        XCTAssertEqual(viewSpy.capturedDisplayShouldShowSearchBar.count, 1)
        XCTAssertEqual(viewSpy.capturedDisplayShouldShowSearchBar.first, true, "Should show search bar when items count > 15")
        XCTAssertEqual(viewSpy.messages.first, .displayShouldShowSearchBar(shouldShowSearchBar: true))
    }
    
    func test_viewDidLoad_HeaderOutput_displayModel() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let headerSpy = components.headerSpy
        
        let expectedTitle = "Select"
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        guard case let .displayModel(receivedModel) = headerSpy.messages.first else {
            XCTFail("Ожидался вызов displayModel")
            return
        }
        
        if case let .text(title) = receivedModel?.leadingCard?.title {
            XCTAssertEqual(title, expectedTitle)
        } else {
            XCTFail("Title should be: \(expectedTitle)")
        }
        
        XCTAssertNotNil(receivedModel?.primeTrailingImage?.image, "Должна быть иконка обратного действия")
        
        let style = receivedModel?.style
        XCTAssertEqual(style?.backgroundColor, .red)
    }
    
    func test_viewDidLoad_emptyViewOutput_displayModel() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let emptyViewSpy = components.emptyViewSpy
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        let model = emptyViewSpy.capturedDisplayModel.first ?? nil
        
        XCTAssertEqual(model?.title, .text("Empty View"))
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
        let model = resetButtonSpy.capturedDisplayModel.first ?? nil
        
        XCTAssertEqual(model?.title, config.texts.resetTitle)
        XCTAssertEqual(model?.enabled, false, "Button should be enabled")
        XCTAssertEqual(model?.height, 48)
        XCTAssertEqual(model?.style?.backgroundColor, config.resetButton?.backgroundColor)
    }
    
    func test_viewDidLoad_selectButtonOutput_displayModel() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let selectButtonSpy = components.selectButtonSpy
        
        let config = nurSelection()
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        let model = selectButtonSpy.capturedDisplayModel.first ?? nil
        
        XCTAssertEqual(model?.title, config.texts.selectTitle)
        XCTAssertEqual(model?.enabled, true, "Button should be enabled")
        XCTAssertEqual(model?.height, 48)
    }
    
        func test_viewDidLoad_selectionOutput_shouldSasdhowSearchBar() {
            let components = makeSUT()
            let sut = components.sut
            let headerSpy = components.headerSpy
            
            let config = nurSelection()
    
            sut.viewDidLoad()
    
            headerSpy.capturedDisplayModel.first??.primeTrailingImage?.onPress?()
            
            let expectedModel = HeaderPresentableModel(
                style: config.navBar,
                centerView: nil,
                leadingCard: .init(id: headerSpy.capturedDisplayModel.first??.leadingCard?.id ?? "", title: .text("Select")),
                primeTrailingImage: config.content.backButtonImage.map { .init(image: $0, onPress: headerSpy.capturedDisplayModel.first??.primeTrailingImage?.onPress) }
            )
    
            XCTAssertEqual(headerSpy.messages.first, .displayModel(model: expectedModel) )
        }
}

fileprivate extension SelectionPresenterSpyTests {
    
    struct SUTComponents {
        let sut: SelectionPresenter
        let headerSpy: HeaderOutputSpy
        let resetSpy: ButtonOutputSpy
        let viewSpy: SelectionOutputSpy
        let selectButtonSpy: ButtonOutputSpy
        let emptyViewSpy: EmptyViewOutputSpy
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
        
        let factory = SelectionFactoryMock()
        
        let flow = SelectionFlowiOS(
            configuration: nurSelection(),
            navigationController: UINavigationController(),
            factory: factory)
        
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
            selectButtonSpy: selectButtonSpy,
            emptyViewSpy: emptyViewSpy
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
                borderColor: .clear
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

fileprivate class SelectionFactoryMock: ISelectionFactory {
    func resolveSelection(
        configuration: SelectionConfiguration,
        flow: SelectionFlow,
        model: SelectionPresenterModel
    ) -> UIViewController {
        return UIViewController()
    }
    
    func resolveSelection<Request, Response>(
        configuration: SelectionConfiguration,
        flow: SelectionFlow,
        model: ServicedSelectionModel<Request, Response>
    ) -> UIViewController {
        return UIViewController()
    }
}
