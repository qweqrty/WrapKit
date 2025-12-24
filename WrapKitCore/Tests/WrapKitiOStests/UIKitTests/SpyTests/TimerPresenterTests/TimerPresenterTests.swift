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
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let seconds = 5
        
        // WHEN
        let exp = expectation(description: "Wait for timer tick")
        exp.expectedFulfillmentCount = 4
        var counter: Int? = seconds - 1
        
        sut.onSecondsRemaining = { secondsRemained in
            // THEN
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
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let seconds = 5
        
        // WHEN
        let exp = expectation(description: "Wait in background")
        sut.start(seconds: seconds)
        
        // THEN
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertEqual(viewSpy.capturedDisplayTimerInput.map { $0.secondsRemaining }, [4, 3, 2, 1, nil])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 7.0)
    }
    
    func test_start_onSecondsRemaining_endsWithNil() {
        // GIVE
        let components = makeSUT()
        let sut = components.sut
        
        // WHEN
        let exp = expectation(description: "Wait for nil")

        sut.onSecondsRemaining = { value in
            if value == nil {
                // THEN
                XCTAssertEqual(value, nil)
                exp.fulfill()
            }
        }

        sut.start(seconds: 5)

        wait(for: [exp], timeout: 6)
    }
    
    func test_stop_shouldNotDisplaySecondsRemaining() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let timerSpy = components.viewSpy
        
        // WHEN
        sut.start(seconds: 5)
        sut.stop()
        
        let exp1 = expectation(description: "Wait for first tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: 3.0)
        
        // THEN
        XCTAssertEqual(timerSpy.messages.count, 0)
        
        sut.start(seconds: 5)
        let exp2 = expectation(description: "Wait for first tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            sut.stop()
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 3.0)
        
        XCTAssertEqual(timerSpy.capturedDisplayTimerInput[0].secondsRemaining, 4)
        XCTAssertEqual(timerSpy.messages.count, 1)
    }
    
    func test_applicationWillEnterForeground_shouldDisplayUpdatedSeconds() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let expectedTime = 8

        // WHEN
        let exp = expectation(description: "Wait for secondsRemaining update")
        sut.onSecondsRemaining = { secondsRemained in
            // THEN
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
    }//
    
    func test_applicationWillEnterForeground_view_shouldDisplayUpdatedSeconds() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        let expectedTime = 8

        // WHEN
        sut.start(seconds: 10)
        sut.applicationDidEnterBackground()

        let waitInBackground = expectation(description: "Wait in background")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            waitInBackground.fulfill()
        }
        wait(for: [waitInBackground], timeout: 3.0)

        sut.applicationWillEnterForeground()

        // THEN
        let lastDisplayedValue = viewSpy.capturedDisplayTimerInput[0].secondsRemaining
        
        XCTAssertEqual(lastDisplayedValue, expectedTime)
    }

    
    func test_stop_shouldCancelTimer() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy

        // WHEN
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
        
        // THEN
        XCTAssertEqual(viewSpy.capturedDisplayTimerInput[0].secondsRemaining, 4)
        XCTAssertEqual(viewSpy.capturedDisplayTimerInput[1].secondsRemaining, 3)
    }
    
    func test_applicationWillEnterForeground_whenTimeExpired_shouldCallDisplayWithNil() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy
        
        // WHEN
        sut.start(seconds: 1)
        sut.applicationDidEnterBackground()
        
        let exp1 = expectation(description: "Wait in background")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 3.0)
        
        sut.applicationWillEnterForeground()
        
        // THEN
        XCTAssertEqual(viewSpy.capturedDisplayTimerInput[0].secondsRemaining, nil)
    }
    
    func test_start_calledMultipleTimes_shouldUseLastStartOnly() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy

        // WHEN
        let exp = expectation(description: "Wait for ticks from last start")
        exp.expectedFulfillmentCount = 3

        sut.onSecondsRemaining = { value in
            exp.fulfill()
        }

        sut.start(seconds: 5)
        sut.start(seconds: 10)
        sut.start(seconds: 4)

        wait(for: [exp], timeout: 5.0)

        // THEN
        XCTAssertEqual(viewSpy.capturedDisplayTimerInput.map { $0.secondsRemaining }, [3, 2, 1])
    }
    
    func test_stop_calledMultipleTimes_shouldNotProduceNewDisplayCalls() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.viewSpy

        sut.start(seconds: 5)

        let firstTick = expectation(description: "Wait first tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            firstTick.fulfill()
        }
        wait(for: [firstTick], timeout: 2.0)

        sut.stop()
        sut.stop()
        sut.stop()

        let waitAfterStop = expectation(description: "Wait after stop")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            waitAfterStop.fulfill()
        }
        wait(for: [waitAfterStop], timeout: 2.5)

        print("AWD\(viewSpy.capturedDisplayTimerInput)")
        
        XCTAssertEqual(viewSpy.capturedDisplayTimerInput.count, 2)
//        XCTAssertEqual(viewSpy.capturedDisplayTimerInput.map { $0.secondsRemaining }, [4, 3])
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
