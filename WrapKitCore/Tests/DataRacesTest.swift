import XCTest
import WrapKit
import Combine

final class CounterViewModelTests: XCTestCase {
    var vm: CounterViewModel!
    
    override func setUp() {
        super.setUp()
        vm = CounterViewModel()
    }
    
    override func tearDown() {
        vm = nil
        super.tearDown()
    }
    
    func testSingleIncrement() {
        let expectation = XCTestExpectation(description: "Single increment completes")
        
        vm.increment { newCount in
            XCTAssertEqual(newCount, 1, "Single increment failed")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testConcurrentIncrements() {
        let concurrentCount = 100
        let expectation = XCTestExpectation(description: "Concurrent increments complete")
        expectation.expectedFulfillmentCount = concurrentCount
        
        let queue = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        
        for _ in 0..<concurrentCount {
            group.enter()
            queue.async {
                self.vm.increment { _ in
                    expectation.fulfill()
                    group.leave()
                }
            }
        }
        
        group.wait()
        
        XCTAssertEqual(self.vm.count, concurrentCount, "Concurrent increments failed due to data race (count should be 100, but likely less)")
    }
    
    func testTest() {
        CounterViewModel.qwer()
    }
}
