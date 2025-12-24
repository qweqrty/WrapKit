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
    
    func test_start_shouldFireOnSecondsRemaining() {
        let components = makeSUT()
        let sut = components.sut
        let seconds = 5
        
        let exp = expectation(description: "Wait for timer tick")
        exp.expectedFulfillmentCount = 4
        var counter: Int? = seconds - 1
        
        sut.onSecondsRemaining = { secondsRemained in
            XCTAssertEqual(secondsRemained, counter)
            counter = (counter ?? 0) - 1
            if counter == 0 {
                counter = nil
            }
            exp.fulfill()
        }
        
        sut.start(seconds: seconds)
        
        wait(for: [exp], timeout: 6.0)
    }
    
    func test_start_timerOutput_display() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let seconds = 5
        let exp = expectation(description: "Wait in background")
        sut.start(seconds: seconds)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertEqual(viewSpy.capturedDisplayTimerInput.map { $0.secondsRemaining }, [4, 3, 2, 1, nil])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 7.0)
    }
    
    func test_stop_shouldNotDisplaySecondsRemaining() {
        let components = makeSUT()
        let sut = components.sut
        let timerSpy = components.viewSpy
        
        sut.start(seconds: 5)
        sut.stop()
        
        let exp1 = expectation(description: "Wait for first tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: 3.0)
        
        XCTAssertEqual(timerSpy.capturedDisplayTimerInput.last?.secondsRemaining, nil)
    }
    
    func test_applicationWillEnterForeground_shouldDisplayUpdatedSeconds() {
        let components = makeSUT()
        let sut = components.sut
        let expectedTime = 8

        let exp = expectation(description: "Wait for secondsRemaining update")
        sut.onSecondsRemaining = { secondsRemained in
            XCTAssertEqual(secondsRemained, expectedTime)
            exp.fulfill()
        }

        sut.start(seconds: 10)
        sut.applicationDidEnterBackground()

        let exp1 = expectation(description: "Wait for first tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: 3.0)

        sut.applicationWillEnterForeground()

        wait(for: [exp], timeout: 1.0)
    }

    func test_timerCompletion_shouldCallDisplayWithNil() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let seconds = 1
        
        sut.start(seconds: seconds)
        
        let exp1 = expectation(description: "Wait for first tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: 3.0)
        
        XCTAssertEqual(viewSpy.capturedDisplayTimerInput.last?.secondsRemaining, nil)
    }
    
    func test_stop_shouldCancelTimer() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy

        sut.start(seconds: 5)

        let firstTick = expectation(description: "Wait for first tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            firstTick.fulfill()
        }
        wait(for: [firstTick], timeout: 2)

        sut.stop()

        let noMoreTicks = expectation(description: "No more ticks")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            noMoreTicks.fulfill()
        }

        wait(for: [noMoreTicks], timeout: 2.5)

        XCTAssertEqual(viewSpy.capturedDisplayTimerInput.first?.secondsRemaining, 4)
    }
    
    func test_applicationWillEnterForeground_whenTimeExpired_shouldCallDisplayWithNil() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        
        sut.start(seconds: 1)
        sut.applicationDidEnterBackground()
        
        let exp1 = expectation(description: "Wait in background")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 3.0)
        
        sut.applicationWillEnterForeground()
        
        XCTAssertEqual(viewSpy.capturedDisplayTimerInput[0].secondsRemaining, nil)
    }
}

extension TimerPresenterTests {
    struct SUTComponents {
        let sut: TimerPresenter
        let viewSpy: TimerOutputSpy
    }
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUTComponents {
        let viewSpy = TimerOutputSpy()
        let sut = TimerPresenter()
        sut.view = viewSpy
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(viewSpy, file: file, line: line)
        return SUTComponents(sut: sut, viewSpy: viewSpy)
    }
}
