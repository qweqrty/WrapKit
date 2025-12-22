// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif

public final class SelectionFlowSpy: SelectionFlow {

    public init() {}

    public enum Message: HashableWithReflection {
        case showSelectionModel(model: SelectionPresenterModel)
        case showSelectionModelGeneric
        case closeResult(with: SelectionType?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedShowSelectionModel: [SelectionPresenterModel] = []
    public private(set) var showSelectionModelGenericCallCount = 0
    public private(set) var capturedCloseResult: [SelectionType?] = []


    // MARK: - SelectionFlow methods
    public func showSelection(model: SelectionPresenterModel) {
        capturedShowSelectionModel.append(model)
        messages.append(.showSelectionModel(model: model))
    }
    public func showSelection<Request, Response>(model: ServicedSelectionModel<Request, Response>) {
        showSelectionModelGenericCallCount += 1
        messages.append(.showSelectionModelGeneric)
    }
    public func close(with result: SelectionType?) {
        capturedCloseResult.append(result)
        messages.append(.closeResult(with: result))
    }

    // MARK: - Properties

    // MARK: - Reset
    public func reset() {
        messages.removeAll()
        capturedShowSelectionModel.removeAll()
        showSelectionModelGenericCallCount = 0
        capturedCloseResult.removeAll()
    }
}
