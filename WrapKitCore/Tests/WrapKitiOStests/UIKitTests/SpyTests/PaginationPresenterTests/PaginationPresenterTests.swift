//
//  PaginationPresenterTests.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 25/12/25.
//

//
//  PaginationPresenterTests.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 25/12/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils
import Combine

final class PaginationPresenterTests: XCTestCase {
    
    // MARK:  - refresh() tests
    func test_refresh_sendsCorrectRequestToService() {
        let components = makeSUT()
        let sut = components.sut
        let serviceSpy = components.serviceSpy
        
        sut.refresh()
        
        XCTAssertEqual(serviceSpy.requests[0].page, 1)
        XCTAssertEqual(serviceSpy.requests[0].perPage, 10)
    }
    
    func test_refresh_refresh_paginationOutput_display_subSequentPage() {
        let components = makeSUT()
        let viewSpy = components.viewSpy
        let sut = components.sut
        
        sut.refresh()
        
        XCTAssertEqual(viewSpy.messages[0], .displayIsLoadingSubsequentPage(isLoadingSubsequentPage: false))
    }
    
    func test_refresh_display_isLoadingFirstPage() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        
        sut.refresh()
        
        XCTAssertEqual(viewSpy.messages[1], .displayIsLoadingFirstPage(isLoadingFirstPage: true))
    }
    
    func test_refresh_onSuccess_handlesResponseAndDisplaysModel() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let serviceSpy = components.serviceSpy
        let testItems = [TestItem(id: "1", value: "Test")]
        let response = TestResponse(items: testItems, totalPages: 1)
        
        let expectation = expectation(description: "Completion called")
        
        sut.refresh()
        serviceSpy.complete(with: .success(response), at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewSpy.capturedDisplayModel.count, 1)
            XCTAssertEqual(viewSpy.capturedDisplayModel[0].model.count, 1)
            XCTAssertEqual(viewSpy.capturedDisplayModel[0].model[0].id, "1")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_refresh_onError_handlesErrorAndDisplaysError() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let serviceSpy = components.serviceSpy
        let error = ServiceError.message("test")
        
        let expectation = expectation(description: "Error handled")
        
        sut.refresh()
        serviceSpy.complete(with: .failure(error), at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewSpy.capturedDisplayErrorAtFirstPage.count, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_refresh_onCompletion_stopsLoadingFirstPage() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let serviceSpy = components.serviceSpy
        let response = TestResponse(items: [], totalPages: 1)
        
        let expectation = expectation(description: "Completion called")
        
        sut.refresh()
        XCTAssertEqual(viewSpy.capturedDisplayIsLoadingFirstPage[0], true)
        serviceSpy.complete(with: .success(response), at: 0)
        
        // TODO: - Stas
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewSpy.capturedDisplayIsLoadingFirstPage[1], false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - loadNextPage() tests
    
    func test_loadNextPage_sendsCorrectRequestToService() {
        let components = makeSUT()
        let sut = components.sut
        let serviceSpy = components.serviceSpy
        let response = TestResponse(items: [], totalPages: 2)
        
        let expectation = expectation(description: "First page loaded")
        
        sut.refresh()
        serviceSpy.complete(with: .success(response), at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.loadNextPage()
            
            XCTAssertEqual(serviceSpy.requests.count, 2)
            XCTAssertEqual(serviceSpy.requests[1].page, 2)
            XCTAssertEqual(serviceSpy.requests[1].perPage, 10)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_loadNextPage_display_isLoadingSubsequentPage() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let serviceSpy = components.serviceSpy
        let response = TestResponse(items: [], totalPages: 2)
        
        sut.refresh()
        serviceSpy.complete(with: .success(response), at: 0)
        
        let exp = expectation(description: "Wait for loadPage")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sut.loadNextPage()
            
            XCTAssertEqual(viewSpy.messages[4], .displayIsLoadingSubsequentPage(isLoadingSubsequentPage: true))
            print("aASDASDDAS\(viewSpy.messages)")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadNextPage_onSuccess_handlesResponseAndDisplaysModel() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let serviceSpy = components.serviceSpy
        let firstPageItems = [TestItem(id: "1", value: "First")]
        let secondPageItems = [TestItem(id: "2", value: "Second")]
        let firstResponse = TestResponse(items: firstPageItems, totalPages: 2)
        let secondResponse = TestResponse(items: secondPageItems, totalPages: 2)
        
        let expectation = expectation(description: "Second page loaded")
        
        sut.refresh()
        serviceSpy.complete(with: .success(firstResponse), at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let previousCount = viewSpy.capturedDisplayModel.count
            
            sut.loadNextPage()
            serviceSpy.complete(with: .success(secondResponse), at: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Проверяем что onSuccess добавил новые элементы
                XCTAssertEqual(viewSpy.capturedDisplayModel.count, previousCount + 1)
                let lastModel = viewSpy.capturedDisplayModel[1]
                print("ASDSAD\(viewSpy.capturedDisplayModel)")
                XCTAssertEqual(lastModel.model.count, 2) // Первая + вторая страница
                XCTAssertEqual(lastModel.model[0].id, "1")
                XCTAssertEqual(lastModel.model[1].id, "2")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_loadNextPage_onError_handlesErrorAndDisplaysError() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let serviceSpy = components.serviceSpy
        let response = TestResponse(items: [], totalPages: 2)
        let error = ServiceError.message("test")
        
        let expectation = expectation(description: "Error handled")
        
        sut.refresh()
        serviceSpy.complete(with: .success(response), at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.loadNextPage()
            serviceSpy.complete(with: .failure(error), at: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertEqual(viewSpy.capturedDisplayErrorAtSubsequentPage.count, 1)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_loadNextPage_onCompletion_stopsLoadingSubsequentPage() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let serviceSpy = components.serviceSpy
        let firstResponse = TestResponse(items: [], totalPages: 2)
        let secondResponse = TestResponse(items: [], totalPages: 2)
        
        let expectation = expectation(description: "Completion called")
        
        sut.refresh()
        serviceSpy.complete(with: .success(firstResponse), at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.loadNextPage()
            serviceSpy.complete(with: .success(secondResponse), at: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertEqual(viewSpy.capturedDisplayIsLoadingSubsequentPage[2], false)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

fileprivate extension PaginationPresenterTests {
    typealias SUT = PaginationPresenter<TestRequest, TestResponse, TestItem, TestPresentableItem>
    
    struct TestRequest: Equatable {
        let page: Int
        let date: Date
        let perPage: Int
    }
    
    struct TestResponse: Equatable {
        let items: [TestItem]
        let totalPages: Int
    }
    
    struct TestItem: Equatable, Hashable {
        let id: String
        let value: String
    }
    
    struct TestPresentableItem: Equatable {
        let id: String
        let displayValue: String
    }
    
    struct SUTComponents {
        let sut: SUT
        let viewSpy: PaginationViewOutputSpy<TestPresentableItem>
        let serviceSpy: ServiceSpy<TestRequest, TestResponse>
        let storage: any Storage<[TestItem]>
    }
    
    func makeSUT(
        initialPage: Int = 1,
        perPage: Int = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUTComponents {
        let serviceSpy = ServiceSpy<TestRequest, TestResponse>()
        let storage = InMemoryStorage<[TestItem]>()
        let viewSpy = PaginationViewOutputSpy<TestPresentableItem>()
        
        let sut = PaginationPresenter(
            service: serviceSpy,
            mapRequest: { (paginationRequest: PaginationRequest) -> TestRequest? in
                TestRequest(
                    page: paginationRequest.page,
                    date: paginationRequest.date,
                    perPage: paginationRequest.perPage
                )
            },
            mapToTotalPages: { (response: TestResponse) -> Int in
                response.totalPages
            },
            mapFromResponseToRemoteItems: { (response: TestResponse) -> [TestItem] in
                response.items
            },
            mapFromRemoteItemToPresentable: { (item: TestItem) -> TestPresentableItem in
                TestPresentableItem(id: item.id, displayValue: item.value)
            },
            remoteItemsStorage: storage,
            timestamp: Date(),
            initialPage: initialPage,
            perPage: perPage
        )
        
        sut.view = viewSpy
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(viewSpy, file: file, line: line)
        checkForMemoryLeaks(serviceSpy, file: file, line: line)
        
        return SUTComponents(
            sut: sut,
            viewSpy: viewSpy,
            serviceSpy: serviceSpy,
            storage: storage
        )
    }
}
