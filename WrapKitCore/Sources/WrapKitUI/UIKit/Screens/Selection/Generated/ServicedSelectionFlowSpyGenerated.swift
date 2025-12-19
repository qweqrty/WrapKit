// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
import WrapKit

public class ServicedSelectionFlowSpy<Request: Any,Response: Any>: ServicedSelectionFlow {

    public init() {}

    public enum Message: HashableWithReflection {
        case showSelectionModel(model: ServicedSelectionModel<Request, Response>)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedShowSelectionModel: [(ServicedSelectionModel<Request, Response>)] = []

    // MARK: - ServicedSelectionFlow methods
    public func showSelection(model: ServicedSelectionModel<Request, Response>) {
        capturedShowSelectionModel.append((model))
        messages.append(.showSelectionModel(model: model))
    }

    // MARK: - Properties
}
