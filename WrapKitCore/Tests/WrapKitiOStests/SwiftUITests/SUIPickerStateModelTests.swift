#if canImport(SwiftUI)
@testable import WrapKit
import SwiftUI
import XCTest

final class SUIPickerStateModelTests: XCTestCase {
    func test_premountSelectionBeforeProvidersRemainsNoOpLikeUIKit() {
        let adapter = PickerViewOutputSwiftUIAdapter()

        adapter.display(selectedRow: .init(row: 1))
        adapter.display(model: .init(
            componentsCount: { 1 },
            rowsCount: { 2 },
            titleForRowAt: { "Row \($0)" },
            selectedRow: .init(row: 0)
        ))

        let sut = SUIPickerStateModel(adapter: adapter)

        XCTAssertEqual(sut.selectedRows, [0: 0])
    }

    func test_premountModelSelectionWinsOverOlderValidSelectionLikeUIKit() {
        let adapter = PickerViewOutputSwiftUIAdapter()
        adapter.display(model: .init(
            componentsCount: { 1 },
            rowsCount: { 2 },
            titleForRowAt: { "Row \($0)" }
        ))
        adapter.display(selectedRow: .init(row: 1))
        adapter.display(model: .init(
            componentsCount: { 1 },
            rowsCount: { 2 },
            titleForRowAt: { "Updated row \($0)" },
            selectedRow: .init(row: 0)
        ))

        let sut = SUIPickerStateModel(adapter: adapter)

        XCTAssertEqual(sut.selectedRows, [0: 0])
    }

    func test_modelSynchronizesPublicProvidersLikeUIKit() {
        let adapter = PickerViewOutputSwiftUIAdapter()
        var selectedRow: Int?

        adapter.display(model: .init(
            componentsCount: { 2 },
            rowsCount: { 3 },
            titleForRowAt: { "Row \($0)" },
            didSelectAt: { selectedRow = $0 }
        ))

        XCTAssertEqual(adapter.componentsCount?(), 2)
        XCTAssertEqual(adapter.rowsCount?(), 3)
        XCTAssertEqual(adapter.titleForRowAt?(1), "Row 1")
        adapter.didSelectAt?(2)
        XCTAssertEqual(selectedRow, 2)

        adapter.display(model: nil)

        XCTAssertNil(adapter.componentsCount)
        XCTAssertNil(adapter.rowsCount)
        XCTAssertNil(adapter.titleForRowAt)
        XCTAssertNil(adapter.didSelectAt)
    }

    func test_rowsKeepProviderCountWhenSomeTitlesAreNil() {
        let adapter = PickerViewOutputSwiftUIAdapter()
        let sut = SUIPickerStateModel(adapter: adapter)

        adapter.display(model: .init(
            componentsCount: { 1 },
            rowsCount: { 3 },
            titleForRowAt: { $0 == 1 ? nil : "Row \($0)" }
        ))

        XCTAssertEqual(sut.rows, ["Row 0", "", "Row 2"])
    }

    func test_selectedRowRejectsComponentAndRowAtUpperBounds() {
        let adapter = PickerViewOutputSwiftUIAdapter()
        let sut = SUIPickerStateModel(adapter: adapter)
        var completions = 0
        adapter.display(model: .init(
            componentsCount: { 1 },
            rowsCount: { 2 },
            titleForRowAt: { "Row \($0)" }
        ))

        adapter.display(selectedRow: .init(
            row: 0,
            component: 1,
            selectedRowCompletion: { _ in completions += 1 }
        ))
        adapter.display(selectedRow: .init(
            row: 2,
            component: 0,
            selectedRowCompletion: { _ in completions += 1 }
        ))

        XCTAssertEqual(completions, 0)
        XCTAssertTrue(sut.selectedRows.isEmpty)
    }

    func test_rowsShrink_clampsSelectionInSecondComponentWithoutSelectionCallback() {
        let adapter = PickerViewOutputSwiftUIAdapter()
        let sut = SUIPickerStateModel(adapter: adapter)
        var selectionCallbacks = 0
        adapter.display(model: .init(
            componentsCount: { 2 },
            rowsCount: { 4 },
            titleForRowAt: { "Row \($0)" },
            didSelectAt: { _ in selectionCallbacks += 1 }
        ))
        adapter.display(selectedRow: .init(row: 3, component: 1))

        adapter.rowsCount = { 2 }

        XCTAssertEqual(sut.rows, ["Row 0", "Row 1"])
        XCTAssertEqual(sut.selectedRows[1], 1)
        XCTAssertEqual(selectionCallbacks, 0)
    }

    func test_componentsShrink_removesSelectionsForMissingComponents() {
        let adapter = PickerViewOutputSwiftUIAdapter()
        let sut = SUIPickerStateModel(adapter: adapter)
        adapter.display(model: .init(
            componentsCount: { 3 },
            rowsCount: { 2 },
            titleForRowAt: { "Row \($0)" }
        ))
        adapter.display(selectedRow: .init(row: 1, component: 0))
        adapter.display(selectedRow: .init(row: 1, component: 2))

        adapter.componentsCount = { 1 }

        XCTAssertEqual(sut.selectedRows, [0: 1])
    }

    func test_emptyRows_clearsEveryComponentSelectionWithoutSelectionCallback() {
        let adapter = PickerViewOutputSwiftUIAdapter()
        let sut = SUIPickerStateModel(adapter: adapter)
        var selectionCallbacks = 0
        adapter.display(model: .init(
            componentsCount: { 2 },
            rowsCount: { 2 },
            titleForRowAt: { "Row \($0)" },
            didSelectAt: { _ in selectionCallbacks += 1 }
        ))
        adapter.display(selectedRow: .init(row: 1, component: 1))

        adapter.rowsCount = { 0 }

        XCTAssertTrue(sut.rows.isEmpty)
        XCTAssertTrue(sut.selectedRows.isEmpty)
        XCTAssertEqual(selectionCallbacks, 0)
    }

    func test_selectionCallback_runsForBindingWriteButNotProgrammaticDisplay() {
        let adapter = PickerViewOutputSwiftUIAdapter()
        let stateModel = SUIPickerStateModel(adapter: adapter)
        var receivedSelections: [Int] = []
        adapter.display(model: .init(
            componentsCount: { 1 },
            rowsCount: { 2 },
            titleForRowAt: { "Row \($0)" },
            didSelectAt: { receivedSelections.append($0) }
        ))
        let content = SUIPickerContent(
            componentsCount: stateModel.componentsCount,
            rows: stateModel.rows,
            selectedRows: Binding(
                get: { stateModel.selectedRows },
                set: { stateModel.selectedRows = $0 }
            ),
            didSelectAt: stateModel.didSelectAt
        )

        adapter.display(selectedRow: .init(row: 1))
        XCTAssertTrue(receivedSelections.isEmpty)

        content.selectedRowBinding(for: 0).wrappedValue = 0

        XCTAssertEqual(receivedSelections, [0])
    }
}
#endif
