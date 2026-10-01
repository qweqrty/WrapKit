// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(Dispatch)
import Dispatch
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(Kingfisher)
import Kingfisher
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
public class ImageViewOutputSwiftUIAdapter: ObservableObject, ImageViewOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()


    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModelCompletion(DisplayModelCompletionState)
        case displayImageCompletion(DisplayImageCompletionState)
        case displaySize(DisplaySizeState)
        case displayOnPress(DisplayOnPressState)
        case displayOnLongPress(DisplayOnLongPressState)
        case displayContentModeIsFit(DisplayContentModeIsFitState)
        case displayBorderWidth(DisplayBorderWidthState)
        case displayBorderColor(DisplayBorderColorState)
        case displayCornerRadius(DisplayCornerRadiusState)
        case displayAlpha(DisplayAlphaState)
        case displayIsHidden(DisplayIsHiddenState)
        case displayModel(DisplayModelState)
        case displayImage(DisplayImageState)
    }

    private var bufferedOutputReplayEvents: [OutputReplayEvent] = []
    private var isBufferingOutputReplayEvents = true
    private var outputReplayCheckpointStorage: Any?
    private var pendingOutputReplayCheckpointStorage: Any?
    private var outputReplayDeliveryDepth = 0
    private var nextOutputReplayConsumerGeneration: UInt64 = 0
    private var activeOutputReplayConsumerGeneration: UInt64 = 0
    private let outputReplayCheckpointRequest = PassthroughSubject<Void, Never>()
    private let outputReplayStateDelivery = PassthroughSubject<Any, Never>()

    struct OutputReplayConsumer {
        fileprivate let generation: UInt64
    }

    func claimOutputReplayConsumer() -> OutputReplayConsumer {
        requireMainOutputReplayQueue()
        nextOutputReplayConsumerGeneration &+= 1
        activeOutputReplayConsumerGeneration = nextOutputReplayConsumerGeneration
        return OutputReplayConsumer(generation: activeOutputReplayConsumerGeneration)
    }

    func outputReplayPublisher<State>(
        _ publisher: Published<State?>.Publisher,
        consumer: OutputReplayConsumer
    ) -> AnyPublisher<State?, Never> {
        requireMainOutputReplayQueue()
        let livePublisher = publisher
            .dropFirst()
            .eraseToAnyPublisher()
        let replayPublisher = outputReplayStateDelivery
            .compactMap { $0 as? State }
            .map(Optional.some)
            .eraseToAnyPublisher()
        return Publishers.Merge(livePublisher, replayPublisher)
            .filter { [weak self] _ in
                self?.isActiveOutputReplayConsumer(consumer) == true
            }
            .eraseToAnyPublisher()
    }

    func activeOutputReplayPublisher<Value>(
        _ publisher: Published<Value>.Publisher,
        consumer: OutputReplayConsumer,
        dropFirst: Bool
    ) -> AnyPublisher<Value, Never> {
        requireMainOutputReplayQueue()
        let publisher = dropFirst
            ? publisher.dropFirst().eraseToAnyPublisher()
            : publisher.eraseToAnyPublisher()
        return publisher
            .filter { [weak self] _ in
                self?.isActiveOutputReplayConsumer(consumer) == true
            }
            .eraseToAnyPublisher()
    }

    func bufferedOutputReplayPublisher(
        consumer: OutputReplayConsumer
    ) -> AnyPublisher<OutputReplayEvent, Never> {
        requireMainOutputReplayQueue()
        guard isActiveOutputReplayConsumer(consumer) else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        guard isBufferingOutputReplayEvents else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        isBufferingOutputReplayEvents = false
        let events = bufferedOutputReplayEvents
        bufferedOutputReplayEvents.removeAll(keepingCapacity: false)
        return events.publisher.eraseToAnyPublisher()
    }

    func replayOutputEvent(
        _ event: OutputReplayEvent,
        consumer: OutputReplayConsumer
    ) {
        requireMainOutputReplayQueue()
        guard isActiveOutputReplayConsumer(consumer) else { return }
        beginOutputReplayDelivery(event)
        switch event {
        case .displayModelCompletion(let state):
            outputReplayStateDelivery.send(state)
        case .displayImageCompletion(let state):
            outputReplayStateDelivery.send(state)
        case .displaySize(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnLongPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayContentModeIsFit(let state):
            outputReplayStateDelivery.send(state)
        case .displayBorderWidth(let state):
            outputReplayStateDelivery.send(state)
        case .displayBorderColor(let state):
            outputReplayStateDelivery.send(state)
        case .displayCornerRadius(let state):
            outputReplayStateDelivery.send(state)
        case .displayAlpha(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsHidden(let state):
            outputReplayStateDelivery.send(state)
        case .displayModel(let state):
            outputReplayStateDelivery.send(state)
        case .displayImage(let state):
            outputReplayStateDelivery.send(state)
        }
        finishOutputReplayDelivery()
    }

    private func bufferOutputReplayEvent(_ event: OutputReplayEvent) {
        guard isBufferingOutputReplayEvents else { return }
        bufferedOutputReplayEvents.append(event)
    }

    private func beginOutputReplayDelivery(_ event: OutputReplayEvent) {
        requireMainOutputReplayQueue()
        outputReplayDeliveryDepth += 1
        bufferOutputReplayEvent(event)
    }

    private func finishOutputReplayDelivery() {
        requireMainOutputReplayQueue()
        outputReplayCheckpointRequest.send(())
        outputReplayDeliveryDepth -= 1
        if outputReplayDeliveryDepth == 0,
           let checkpoint = pendingOutputReplayCheckpointStorage {
            pendingOutputReplayCheckpointStorage = nil
            commitOutputReplayCheckpoint(checkpoint)
        }
    }

    private func requireMainOutputReplayQueue() {
        dispatchPrecondition(condition: .onQueue(.main))
    }

    func isActiveOutputReplayConsumer(_ consumer: OutputReplayConsumer?) -> Bool {
        requireMainOutputReplayQueue()
        guard let consumer else { return false }
        return consumer.generation == activeOutputReplayConsumerGeneration
    }

    func outputReplayCheckpoint<Checkpoint>(
        as _: Checkpoint.Type,
        consumer: OutputReplayConsumer
    ) -> Checkpoint? {
        requireMainOutputReplayQueue()
        guard isActiveOutputReplayConsumer(consumer) else { return nil }
        return outputReplayCheckpointStorage as? Checkpoint
    }

    func updateOutputReplayCheckpoint<Checkpoint>(
        consumer: OutputReplayConsumer?,
        _ checkpoint: Checkpoint
    ) {
        requireMainOutputReplayQueue()
        guard let consumer, isActiveOutputReplayConsumer(consumer) else { return }
        if outputReplayDeliveryDepth > 0 {
            pendingOutputReplayCheckpointStorage = checkpoint
            return
        }
        commitOutputReplayCheckpoint(checkpoint)
    }

    private func commitOutputReplayCheckpoint(_ checkpoint: Any) {
        requireMainOutputReplayQueue()
        outputReplayCheckpointStorage = checkpoint
        bufferedOutputReplayEvents.removeAll(keepingCapacity: true)
        isBufferingOutputReplayEvents = true
    }

    func outputReplayCheckpointRequestPublisher(
        consumer: OutputReplayConsumer
    ) -> AnyPublisher<Void, Never> {
        requireMainOutputReplayQueue()
        return outputReplayCheckpointRequest
            .filter { [weak self] in
                self?.isActiveOutputReplayConsumer(consumer) == true
            }
            .eraseToAnyPublisher()
    }




    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelCompletionState: DisplayModelCompletionState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayModelCompletion(state))
        }
        didSet {
            guard displayModelCompletionState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayModelCompletionState {
        let outputSequence: UInt64
        public let model: ImageViewPresentableModel?
        public let completion: ((Image?) -> Void)?
    }
    public func display(model: ImageViewPresentableModel?, completion: ((Image?) -> Void)?) {
        requireMainOutputReplayQueue()
        outputReplayClosureStore.invalidate(path: "completion")
        let model = outputReplayClosureStore.sanitize(
            model,
            path: "model"
        )
        let completion = outputReplayClosureStore.sanitizeOnce(
            completion,
            path: "completion"
        )
        nextOutputSequence &+= 1
        displayModelCompletionState = .init(
            outputSequence: nextOutputSequence,
            model: model, 
            completion: completion
        )
    }
    @Published public var displayImageCompletionState: DisplayImageCompletionState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayImageCompletion(state))
        }
        didSet {
            guard displayImageCompletionState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayImageCompletionState {
        let outputSequence: UInt64
        public let image: ImageEnum?
        public let completion: ((Image?) -> Void)?
    }
    public func display(image: ImageEnum?, completion: ((Image?) -> Void)?) {
        requireMainOutputReplayQueue()
        outputReplayClosureStore.invalidate(path: "completion")
        let image = outputReplayClosureStore.sanitize(
            image,
            path: "image"
        )
        let completion = outputReplayClosureStore.sanitizeOnce(
            completion,
            path: "completion"
        )
        nextOutputSequence &+= 1
        displayImageCompletionState = .init(
            outputSequence: nextOutputSequence,
            image: image, 
            completion: completion
        )
    }
    @Published public var displaySizeState: DisplaySizeState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displaySize(state))
        }
        didSet {
            guard displaySizeState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplaySizeState {
        let outputSequence: UInt64
        public let size: CGSize?
    }
    public func display(size: CGSize?) {
        requireMainOutputReplayQueue()
        let size = outputReplayClosureStore.sanitize(
            size,
            path: "size"
        )
        nextOutputSequence &+= 1
        displaySizeState = .init(
            outputSequence: nextOutputSequence,
            size: size
        )
    }
    @Published public var displayOnPressState: DisplayOnPressState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayOnPress(state))
        }
        didSet {
            guard displayOnPressState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayOnPressState {
        let outputSequence: UInt64
        public let onPress: (() -> Void)?
    }
    public func display(onPress: (() -> Void)?) {
        requireMainOutputReplayQueue()
        let onPress = outputReplayClosureStore.sanitizePersistentAction(
            onPress,
            path: "onPress"
        )
        nextOutputSequence &+= 1
        displayOnPressState = .init(
            outputSequence: nextOutputSequence,
            onPress: onPress
        )
    }
    @Published public var displayOnLongPressState: DisplayOnLongPressState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayOnLongPress(state))
        }
        didSet {
            guard displayOnLongPressState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayOnLongPressState {
        let outputSequence: UInt64
        public let onLongPress: (() -> Void)?
    }
    public func display(onLongPress: (() -> Void)?) {
        requireMainOutputReplayQueue()
        let onLongPress = outputReplayClosureStore.sanitizePersistentAction(
            onLongPress,
            path: "onLongPress"
        )
        nextOutputSequence &+= 1
        displayOnLongPressState = .init(
            outputSequence: nextOutputSequence,
            onLongPress: onLongPress
        )
    }
    @Published public var displayContentModeIsFitState: DisplayContentModeIsFitState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayContentModeIsFit(state))
        }
        didSet {
            guard displayContentModeIsFitState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayContentModeIsFitState {
        let outputSequence: UInt64
        public let contentModeIsFit: Bool
    }
    public func display(contentModeIsFit: Bool) {
        requireMainOutputReplayQueue()
        let contentModeIsFit = outputReplayClosureStore.sanitize(
            contentModeIsFit,
            path: "contentModeIsFit"
        )
        nextOutputSequence &+= 1
        displayContentModeIsFitState = .init(
            outputSequence: nextOutputSequence,
            contentModeIsFit: contentModeIsFit
        )
    }
    @Published public var displayBorderWidthState: DisplayBorderWidthState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayBorderWidth(state))
        }
        didSet {
            guard displayBorderWidthState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayBorderWidthState {
        let outputSequence: UInt64
        public let borderWidth: CGFloat?
    }
    public func display(borderWidth: CGFloat?) {
        requireMainOutputReplayQueue()
        let borderWidth = outputReplayClosureStore.sanitize(
            borderWidth,
            path: "borderWidth"
        )
        nextOutputSequence &+= 1
        displayBorderWidthState = .init(
            outputSequence: nextOutputSequence,
            borderWidth: borderWidth
        )
    }
    @Published public var displayBorderColorState: DisplayBorderColorState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayBorderColor(state))
        }
        didSet {
            guard displayBorderColorState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayBorderColorState {
        let outputSequence: UInt64
        public let borderColor: Color?
    }
    public func display(borderColor: Color?) {
        requireMainOutputReplayQueue()
        let borderColor = outputReplayClosureStore.sanitize(
            borderColor,
            path: "borderColor"
        )
        nextOutputSequence &+= 1
        displayBorderColorState = .init(
            outputSequence: nextOutputSequence,
            borderColor: borderColor
        )
    }
    @Published public var displayCornerRadiusState: DisplayCornerRadiusState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayCornerRadius(state))
        }
        didSet {
            guard displayCornerRadiusState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayCornerRadiusState {
        let outputSequence: UInt64
        public let cornerRadius: CGFloat?
    }
    public func display(cornerRadius: CGFloat?) {
        requireMainOutputReplayQueue()
        let cornerRadius = outputReplayClosureStore.sanitize(
            cornerRadius,
            path: "cornerRadius"
        )
        nextOutputSequence &+= 1
        displayCornerRadiusState = .init(
            outputSequence: nextOutputSequence,
            cornerRadius: cornerRadius
        )
    }
    @Published public var displayAlphaState: DisplayAlphaState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayAlpha(state))
        }
        didSet {
            guard displayAlphaState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayAlphaState {
        let outputSequence: UInt64
        public let alpha: CGFloat?
    }
    public func display(alpha: CGFloat?) {
        requireMainOutputReplayQueue()
        let alpha = outputReplayClosureStore.sanitize(
            alpha,
            path: "alpha"
        )
        nextOutputSequence &+= 1
        displayAlphaState = .init(
            outputSequence: nextOutputSequence,
            alpha: alpha
        )
    }
    @Published public var displayIsHiddenState: DisplayIsHiddenState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsHidden(state))
        }
        didSet {
            guard displayIsHiddenState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsHiddenState {
        let outputSequence: UInt64
        public let isHidden: Bool
    }
    public func display(isHidden: Bool) {
        requireMainOutputReplayQueue()
        let isHidden = outputReplayClosureStore.sanitize(
            isHidden,
            path: "isHidden"
        )
        nextOutputSequence &+= 1
        displayIsHiddenState = .init(
            outputSequence: nextOutputSequence,
            isHidden: isHidden
        )
    }
    @Published public var displayModelState: DisplayModelState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayModel(state))
        }
        didSet {
            guard displayModelState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayModelState {
        let outputSequence: UInt64
        public let model: ImageViewPresentableModel?
    }
    public func display(model: ImageViewPresentableModel?) {
        requireMainOutputReplayQueue()
        outputReplayClosureStore.invalidate(path: "completion")
        let model = outputReplayClosureStore.sanitize(
            model,
            path: "model"
        )
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: model
        )
    }
    @Published public var displayImageState: DisplayImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayImage(state))
        }
        didSet {
            guard displayImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayImageState {
        let outputSequence: UInt64
        public let image: ImageEnum?
    }
    public func display(image: ImageEnum?) {
        requireMainOutputReplayQueue()
        outputReplayClosureStore.invalidate(path: "completion")
        let image = outputReplayClosureStore.sanitize(
            image,
            path: "image"
        )
        nextOutputSequence &+= 1
        displayImageState = .init(
            outputSequence: nextOutputSequence,
            image: image
        )
    }
}
