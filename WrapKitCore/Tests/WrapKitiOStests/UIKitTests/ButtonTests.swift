//
//  ButtonTests.swift
//  WrapKitTests
//
//  Created by Улан Бейшенкулов on 25/3/24.
//
#if canImport(UIKit)
import XCTest
import WrapKit
import UIKit

class ButtonTests: XCTestCase {
    
    func test_button_press() {
        let buttonExpactation = expectation(description: "onPress closure triggered")
        let sut = makeSUT()
        sut.onPress = {
            buttonExpactation.fulfill()
        }
        
        DispatchQueue.main.async {
            sut.sendActions(for: .touchDown)
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Button onPress closure was not triggered: \(error)")
            }
        }
    }
    
    func test_button_press_directCall() {
        let sut = makeSUT()
        var onPressCalled = false

        sut.onPress = {
            onPressCalled = true
        }

        DispatchQueue.main.async {
            sut.sendActions(for: .touchDown)
        }

        XCTAssertTrue(onPressCalled, "Button onPress closure was not called")
    }
    
    func makeSUT() -> Button {
        let sut = Button()
        return sut
    }
}
#endif
