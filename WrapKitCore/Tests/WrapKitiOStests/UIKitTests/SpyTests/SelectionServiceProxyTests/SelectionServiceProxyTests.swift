import WrapKit
import WrapKitTestUtils
import XCTest
import Combine
import UIKit

// MARK: - Tests

final class SelectionServiceProxyTests: XCTestCase {
    func test_viewDidLoad_startsLoading_callsService_andUpdatesItems() {
        let components = makeSUT()

        let finished = components.loadingViewSpy
            .expectLoadingFinished(testCase: self)

        // WHEN
        components.sut.viewDidLoad()

        // THEN (initial)
        XCTAssertEqual(
            components.loadingViewSpy.messages,
            [.displayIsLoading(isLoading: true)]
        )
        XCTAssertTrue(components.presenterSpy.viewDidLoadCalled)
        XCTAssertEqual(components.serviceSpy.makeCallCount, 1)

        // WHEN service completes
        components.serviceSpy.complete(
            with: .success(MockResponse(value: "Item"))
        )

        wait(for: [finished], timeout: 1.0)

        // THEN final
        XCTAssertEqual(
            components.loadingViewSpy.messages,
            [
                .displayIsLoading(isLoading: true),
                .displayIsLoading(isLoading: false)
            ]
        )
        XCTAssertEqual(components.presenterSpy.items.count, 1)
    }
    
    func test_viewDidLoad_onFailure_stopsLoading_andProvidesEmptyItems() {
        let components = makeSUT()

        let finished = components.loadingViewSpy
            .expectLoadingFinished(testCase: self)

        components.sut.viewDidLoad()

        components.serviceSpy.complete(with: .failure(.internal))

        wait(for: [finished], timeout: 1.0)

        XCTAssertEqual(
            components.loadingViewSpy.messages,
            [
                .displayIsLoading(isLoading: true),
                .displayIsLoading(isLoading: false)
            ]
        )
        XCTAssertTrue(components.presenterSpy.items.isEmpty)
    }
    
    func test_onRefresh_callsService_andUpdatesItems() {
        let components = makeSUT()

        let finished = components.loadingViewSpy
            .expectLoadingFinished(testCase: self)

        components.sut.onRefresh()

        XCTAssertEqual(
            components.loadingViewSpy.messages,
            [.displayIsLoading(isLoading: true)]
        )
        XCTAssertEqual(components.serviceSpy.makeCallCount, 1)

        components.serviceSpy.complete(
            with: .success(.init(value: "Refreshed"))
        )

        wait(for: [finished], timeout: 1.0)

        XCTAssertEqual(
            components.loadingViewSpy.messages,
            [
                .displayIsLoading(isLoading: true),
                .displayIsLoading(isLoading: false)
            ]
        )
        XCTAssertEqual(
            components.presenterSpy.items.first?.title,
            "Refreshed"
        )
    }
    
    func test_onSearch_forwardsCallToPresenter() {
        let components = makeSUT()
        
        components.sut.onSearch("query")
        
        XCTAssertEqual(
            components.presenterSpy.onSearchCalledWith,
            "query"
        )
        XCTAssertTrue(components.loadingViewSpy.messages.isEmpty)
        XCTAssertEqual(components.serviceSpy.makeCallCount, 0)
    }

    func test_onTapFinishSelection_forwardsCallToPresenter() {
        let components = makeSUT()
        
        components.sut.onTapFinishSelection()
        
        XCTAssertTrue(components.presenterSpy.onTapFinishSelectionCalled)
        XCTAssertTrue(components.loadingViewSpy.messages.isEmpty)
        XCTAssertEqual(components.serviceSpy.makeCallCount, 0)
    }

    func test_isNeedToShowSearch_forwardsValueToPresenter() {
        let components = makeSUT()
        
        components.sut.isNeedToShowSearch(true)
        
        XCTAssertEqual(
            components.presenterSpy.isNeedToShowSearchCalledWith,
            true
        )
        XCTAssertTrue(components.loadingViewSpy.messages.isEmpty)
        XCTAssertEqual(components.serviceSpy.makeCallCount, 0)
    }
}

// MARK: - SUT Factory
fileprivate extension SelectionServiceProxyTests {
    struct SUTComponents {
        let sut: SelectionServiceProxy<MockRequest, MockResponse>
        let presenterSpy: SelectionPresenterSpy
        let loadingViewSpy: LoadingOutputSpy
        let serviceSpy: ServiceSpy<MockRequest, MockResponse>
    }
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUTComponents {
        let presenterSpy = SelectionPresenterSpy()
        let loadingViewSpy = LoadingOutputSpy()
        let serviceSpy = ServiceSpy<MockRequest, MockResponse>()
        
        let sut = SelectionServiceProxy(
            decoratee: presenterSpy,
            storage: InMemoryStorage<String>(),
            service: serviceSpy,
            makeRequest: { MockRequest() },
            makeResponse: { result in
                switch result {
                case .success(let response):
                    return [.mock(title: response.value)]
                case .failure:
                    return []
                }
            }
        )
        
        sut.view = loadingViewSpy
            .weakReferenced
            .mainQueueDispatched
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(presenterSpy, file: file, line: line)
        checkForMemoryLeaks(loadingViewSpy, file: file, line: line)
        checkForMemoryLeaks(serviceSpy, file: file, line: line)
        
        return SUTComponents(
            sut: sut,
            presenterSpy: presenterSpy,
            loadingViewSpy: loadingViewSpy,
            serviceSpy: serviceSpy
        )
    }
}

// MARK: - Spies & Mocks
final class SelectionPresenterSpy: SelectionInput, LifeCycleViewOutput {
    var items: [SelectionType.SelectionCellPresentableModel] = []
    var isMultipleSelectionEnabled: Bool = false
    var configuration: SelectionConfiguration = .nurSelection()
    
    private(set) var viewDidLoadCalled = false
    private(set) var onSearchCalledWith: String?
    private(set) var onTapFinishSelectionCalled = false
    private(set) var isNeedToShowSearchCalledWith: Bool?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func onSearch(_ text: String?) {
        onSearchCalledWith = text
    }
    
    func onTapFinishSelection() {
        onTapFinishSelectionCalled = true
    }
    
    func isNeedToShowSearch(_ isNeedToShowSearch: Bool) {
        isNeedToShowSearchCalledWith = isNeedToShowSearch
    }
}

// MARK: - Mock Request / Response
struct MockRequest: Equatable { }

struct MockResponse: Equatable {
    let value: String
}

// MARK: - Cell Factory
extension SelectionType.SelectionCellPresentableModel {
    static func mock(title: String) -> Self {
        .init(
            id: UUID().uuidString,
            title: title,
            isSelected: .init(false),
            onPress: nil,
            configuration: .init(
                titleFont: .systemFont(ofSize: 16),
                trailingFont: .systemFont(ofSize: 13),
                titleColor: .black,
                trailingColor: .gray,
                lineColor: .cyan
            )
        )
    }
}

// MARK: - SelectionConfiguration Factory
extension SelectionConfiguration {
    static func nurSelection(isMultiply: Bool = false) -> SelectionConfiguration {
        SelectionConfiguration(
            texts: SelectionConfiguration.Texts(
                searchTitle: "Поиск",
                resetTitle: "Сбросить",
                selectTitle: "Выбрать",
                selectedCountTitle: "Выбрано"
            ),
            content: SelectionConfiguration.Content(
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
            resetButton: isMultiply
                ? SelectionConfiguration.ActionButton(
                    labelFont: .boldSystemFont(ofSize: 14),
                    textColor: .black,
                    backgroundColor: .systemBackground,
                    borderColor: .clear
                )
                : nil,
            searchButton: SelectionConfiguration.ActionButton(
                labelFont: .boldSystemFont(ofSize: 14),
                textColor: .black,
                backgroundColor: .systemBackground,
                borderColor: .clear
            ),
            searchBar: SelectionConfiguration.SearchBar(
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
    
    private static func nurTextfieldAppearance(
        placeholderText: String?
    ) -> TextfieldAppearance {
        TextfieldAppearance(
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

private extension LoadingOutputSpy {
    func expectLoadingFinished(
        testCase: XCTestCase,
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCTestExpectation {
        let expectation = testCase.expectation(
            description: "Loading finished"
        )
        observeLoadingFinished(expectation, file: file, line: line)
        return expectation
    }

    private func observeLoadingFinished(
        _ expectation: XCTestExpectation,
        file: StaticString,
        line: UInt
    ) {
        let originalCount = messages.count

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.messages.count > originalCount,
               self.messages.last == .displayIsLoading(isLoading: false) {
                expectation.fulfill()
            } else {
                self.observeLoadingFinished(expectation, file: file, line: line)
            }
        }
    }
}
