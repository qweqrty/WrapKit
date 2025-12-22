//
//  TimerPresenterTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 22/12/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils

final class TimerPresenterTests: XCTestCase {
    
    func test_start_shouldDisplayInitialSeconds() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        
        // WHEN
        sut.start(seconds: 5)
        
        // THEN
//        XCTAssertGreaterThanOrEqual(viewSpy.capturedDisplayTimerInputSecondsRemaining.item(at: 0), 1, "Should receive at least one update")
//        XCTAssertEqual(viewSpy.capturedDisplayTimerInputSecondsRemaining.first ?? nil, 4)
    }
    
}


extension TimerPresenterTests {
    struct SUTComponents {
        let sut: TimerPresenter
        let viewSpy: TimerOutputSpy
    }
    
    func makeSUT() -> SUTComponents {
        
        let viewSpy = TimerOutputSpy()
        let sut = TimerPresenter()
        
        sut.view = viewSpy
            .mainQueueDispatched
            .weakReferenced
        
        return SUTComponents(sut: sut, viewSpy: viewSpy)
    }
}
