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
#if canImport(SwiftUI)
import SwiftUI
#endif
public class ButtonOutputSwiftUIAdapter: ObservableObject, ButtonOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()


    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModel(DisplayModelState)
        case displayEnabled(DisplayEnabledState)
        case displayImage(DisplayImageState)
        case displayStyle(DisplayStyleState)
        case displayTitle(DisplayTitleState)
        case displaySpacing(DisplaySpacingState)
        case displayOnPress(DisplayOnPressState)
        case displayHeight(DisplayHeightState)
        case displayIsHidden(DisplayIsHiddenState)
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
        case .displayModel(let state):
            outputReplayStateDelivery.send(state)
        case .displayEnabled(let state):
            outputReplayStateDelivery.send(state)
        case .displayImage(let state):
            outputReplayStateDelivery.send(state)
        case .displayStyle(let state):
            outputReplayStateDelivery.send(state)
        case .displayTitle(let state):
            outputReplayStateDelivery.send(state)
        case .displaySpacing(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayHeight(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsHidden(let state):
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
        public let model: ButtonPresentableModel?
    }
    public func display(model: ButtonPresentableModel?) {
        requireMainOutputReplayQueue()
        let model = outputReplayClosureStore.sanitize(
            model,
            path: "model"
        )
        display(isHidden: model == nil)
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: model
        )
    }
    @Published public var displayEnabledState: DisplayEnabledState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayEnabled(state))
        }
        didSet {
            guard displayEnabledState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayEnabledState {
        let outputSequence: UInt64
        public let enabled: Bool
    }
    public func display(enabled: Bool) {
        requireMainOutputReplayQueue()
        let enabled = outputReplayClosureStore.sanitize(
            enabled,
            path: "enabled"
        )
        nextOutputSequence &+= 1
        displayEnabledState = .init(
            outputSequence: nextOutputSequence,
            enabled: enabled
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
        public let image: Image?
    }
    public func display(image: Image?) {
        requireMainOutputReplayQueue()
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
    @Published public var displayStyleState: DisplayStyleState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayStyle(state))
        }
        didSet {
            guard displayStyleState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayStyleState {
        let outputSequence: UInt64
        public let style: ButtonStyle?
    }
    public func display(style: ButtonStyle?) {
        requireMainOutputReplayQueue()
        let style = outputReplayClosureStore.sanitize(
            style,
            path: "style"
        )
        nextOutputSequence &+= 1
        displayStyleState = .init(
            outputSequence: nextOutputSequence,
            style: style
        )
    }
    @Published public var displayTitleState: DisplayTitleState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTitle(state))
        }
        didSet {
            guard displayTitleState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTitleState {
        let outputSequence: UInt64
        public let title: String?
    }
    public func display(title: String?) {
        requireMainOutputReplayQueue()
        let title = outputReplayClosureStore.sanitize(
            title,
            path: "title"
        )
        nextOutputSequence &+= 1
        displayTitleState = .init(
            outputSequence: nextOutputSequence,
            title: title
        )
    }
    @Published public var displaySpacingState: DisplaySpacingState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displaySpacing(state))
        }
        didSet {
            guard displaySpacingState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplaySpacingState {
        let outputSequence: UInt64
        public let spacing: CGFloat
    }
    public func display(spacing: CGFloat) {
        requireMainOutputReplayQueue()
        let spacing = outputReplayClosureStore.sanitize(
            spacing,
            path: "spacing"
        )
        nextOutputSequence &+= 1
        displaySpacingState = .init(
            outputSequence: nextOutputSequence,
            spacing: spacing
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
    @Published public var displayHeightState: DisplayHeightState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayHeight(state))
        }
        didSet {
            guard displayHeightState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayHeightState {
        let outputSequence: UInt64
        public let height: CGFloat
    }
    public func display(height: CGFloat) {
        requireMainOutputReplayQueue()
        let height = outputReplayClosureStore.sanitize(
            height,
            path: "height"
        )
        nextOutputSequence &+= 1
        displayHeightState = .init(
            outputSequence: nextOutputSequence,
            height: height
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
}
