import UIKit
@testable import WrapKit
import XCTest

final class DiffableTableViewDataSourceTests: XCTestCase {
    func test_display_coalescesSynchronousUpdatesAndReloadsLatestSections() {
        let tableView = ReloadTrackingTableView()
        let sut = makeSUT(tableView: tableView)
        let initialReloadCount = tableView.reloadCount
        let reloadExpectation = expectation(description: "Reload latest sections")
        tableView.onReload = reloadExpectation.fulfill

        sut.display(sections: makeSections(["first"]))
        sut.display(sections: makeSections(["latest", "value"]))

        XCTAssertEqual(tableView.reloadCount, initialReloadCount)
        wait(for: [reloadExpectation], timeout: 1)
        XCTAssertEqual(tableView.reloadCount, initialReloadCount + 1)
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2)
    }

    func test_display_fromBackgroundQueue_updatesAndReloadsOnMainThread() {
        let tableView = ReloadTrackingTableView()
        let sut = makeSUT(tableView: tableView)
        let sections = makeSections(["value"])
        let reloadExpectation = expectation(description: "Reload on main thread")
        tableView.onReload = {
            XCTAssertTrue(Thread.isMainThread)
            reloadExpectation.fulfill()
        }

        DispatchQueue.global().async {
            sut.display(sections: sections)
        }

        wait(for: [reloadExpectation], timeout: 1)
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
    }

    func test_olderBackgroundUpdate_doesNotOverwriteNewerMainThreadUpdate() {
        XCTAssertTrue(Thread.isMainThread)
        let tableView = ReloadTrackingTableView()
        let sut = makeSUT(tableView: tableView)
        let backgroundCallReturned = DispatchSemaphore(value: 0)
        let reloadExpectation = expectation(description: "Reload latest sections")
        let olderSections = makeSections(["older"])
        tableView.onReload = reloadExpectation.fulfill

        DispatchQueue.global().async {
            sut.display(sections: olderSections)
            backgroundCallReturned.signal()
        }

        XCTAssertEqual(backgroundCallReturned.wait(timeout: .now() + 1), .success)
        sut.display(sections: makeSections(["newer", "value"]))

        wait(for: [reloadExpectation], timeout: 1)
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2)
    }

    func test_display_afterPreviousReload_schedulesAnotherReload() {
        let tableView = ReloadTrackingTableView()
        let sut = makeSUT(tableView: tableView)
        let initialReloadCount = tableView.reloadCount
        let firstReloadExpectation = expectation(description: "First reload")
        tableView.onReload = firstReloadExpectation.fulfill

        sut.display(sections: makeSections(["first"]))
        wait(for: [firstReloadExpectation], timeout: 1)

        let secondReloadExpectation = expectation(description: "Second reload")
        tableView.onReload = secondReloadExpectation.fulfill
        sut.display(sections: makeSections(["second"]))
        wait(for: [secondReloadExpectation], timeout: 1)

        XCTAssertEqual(tableView.reloadCount, initialReloadCount + 2)
    }

    private func makeSUT(
        tableView: UITableView
    ) -> DiffableTableViewDataSource<Void, String, Void> {
        DiffableTableViewDataSource(tableView: tableView) { _, _, value in
            let cell = UITableViewCell()
            cell.textLabel?.text = value
            return cell
        }
    }

    private func makeSections(_ values: [String]) -> [TableSection<Void, String, Void>] {
        [.init(cells: values.enumerated().map {
            .init(accessibilityIdentifier: "cell-\($0.offset)", cell: $0.element)
        })]
    }
}

private final class ReloadTrackingTableView: UITableView {
    private(set) var reloadCount = 0
    var onReload: (() -> Void)?

    override func reloadData() {
        reloadCount += 1
        super.reloadData()
        onReload?()
    }
}
