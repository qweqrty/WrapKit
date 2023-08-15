//
//  QueueTests.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import XCTest
import WrapKit

class QueueTests: XCTestCase {
    func test_enqueueAddsElementToQueue() {
        var sut: Queue<Int> = makeSUT()
        sut.enqueue(5)

        XCTAssertEqual(sut.head, 5)
        XCTAssertEqual(sut.tail, 5)
    }

    func test_dequeueRemovesElementFromQueue() {
        var sut: Queue<Int> = makeSUT()
        sut.enqueue(5)
        sut.enqueue(10)
        let dequeued = sut.dequeue()

        XCTAssertEqual(dequeued, 5)
        XCTAssertEqual(sut.head, 10)
        XCTAssertEqual(sut.tail, 10)
    }

    func test_dequeueReturnsNilIfQueueIsEmpty() {
        var sut: Queue<Int> = makeSUT()

        XCTAssertNil(sut.dequeue())
    }

    func test_headReturnsFirstElementInQueue() {
        var sut: Queue<Int> = makeSUT()
        sut.enqueue(5)
        sut.enqueue(10)

        XCTAssertEqual(sut.head, 5)
    }

    func test_tailReturnsLastElementInQueue() {
        var sut: Queue<Int> = makeSUT()
        sut.enqueue(5)
        sut.enqueue(10)

        XCTAssertEqual(sut.tail, 10)
    }
}

extension QueueTests {
    private func makeSUT<T>() -> Queue<T> {
        return Queue<T>()
    }
}
