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
#if canImport(QuartzCore)
import QuartzCore
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
public class CardViewOutputSwiftUIAdapter: ObservableObject, CardViewOutput {
    private let outputReplayClosureStore = SwiftUIOutputReplayClosureStore()


    private var nextOutputSequence: UInt64 = 0

    enum OutputReplayEvent {
        case displayModel(DisplayModelState)
        case displayStyle(DisplayStyleState)
        case displayBackgroundImage(DisplayBackgroundImageState)
        case displayTitle(DisplayTitleState)
        case displayLeadingTitles(DisplayLeadingTitlesState)
        case displayTrailingTitles(DisplayTrailingTitlesState)
        case displayLeadingImage(DisplayLeadingImageState)
        case displaySecondaryLeadingImage(DisplaySecondaryLeadingImageState)
        case displayTrailingImage(DisplayTrailingImageState)
        case displaySecondaryTrailingImage(DisplaySecondaryTrailingImageState)
        case displaySubTitle(DisplaySubTitleState)
        case displayValueTitle(DisplayValueTitleState)
        case displayBottomImage(DisplayBottomImageState)
        case displayBottomSeparator(DisplayBottomSeparatorState)
        case displaySwitchControl(DisplaySwitchControlState)
        case displayOnPress(DisplayOnPressState)
        case displayOnLongPress(DisplayOnLongPressState)
        case displayIsHidden(DisplayIsHiddenState)
        case displayIsUserInteractionEnabled(DisplayIsUserInteractionEnabledState)
        case displayIsGradientBorderEnabled(DisplayIsGradientBorderEnabledState)
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
        case .displayStyle(let state):
            outputReplayStateDelivery.send(state)
        case .displayBackgroundImage(let state):
            outputReplayStateDelivery.send(state)
        case .displayTitle(let state):
            outputReplayStateDelivery.send(state)
        case .displayLeadingTitles(let state):
            outputReplayStateDelivery.send(state)
        case .displayTrailingTitles(let state):
            outputReplayStateDelivery.send(state)
        case .displayLeadingImage(let state):
            outputReplayStateDelivery.send(state)
        case .displaySecondaryLeadingImage(let state):
            outputReplayStateDelivery.send(state)
        case .displayTrailingImage(let state):
            outputReplayStateDelivery.send(state)
        case .displaySecondaryTrailingImage(let state):
            outputReplayStateDelivery.send(state)
        case .displaySubTitle(let state):
            outputReplayStateDelivery.send(state)
        case .displayValueTitle(let state):
            outputReplayStateDelivery.send(state)
        case .displayBottomImage(let state):
            outputReplayStateDelivery.send(state)
        case .displayBottomSeparator(let state):
            outputReplayStateDelivery.send(state)
        case .displaySwitchControl(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayOnLongPress(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsHidden(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsUserInteractionEnabled(let state):
            outputReplayStateDelivery.send(state)
        case .displayIsGradientBorderEnabled(let state):
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
        public let model: CardViewPresentableModel?
    }
    public func display(model: CardViewPresentableModel?) {
        requireMainOutputReplayQueue()
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
        public let style: CardViewPresentableModel.Style?
    }
    public func display(style: CardViewPresentableModel.Style?) {
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
    @Published public var displayBackgroundImageState: DisplayBackgroundImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayBackgroundImage(state))
        }
        didSet {
            guard displayBackgroundImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayBackgroundImageState {
        let outputSequence: UInt64
        public let backgroundImage: ImageViewPresentableModel?
    }
    public func display(backgroundImage: ImageViewPresentableModel?) {
        requireMainOutputReplayQueue()
        let backgroundImage = outputReplayClosureStore.sanitize(
            backgroundImage,
            path: "backgroundImage"
        )
        nextOutputSequence &+= 1
        displayBackgroundImageState = .init(
            outputSequence: nextOutputSequence,
            backgroundImage: backgroundImage
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
        public let title: TextOutputPresentableModel?
    }
    public func display(title: TextOutputPresentableModel?) {
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
    @Published public var displayLeadingTitlesState: DisplayLeadingTitlesState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayLeadingTitles(state))
        }
        didSet {
            guard displayLeadingTitlesState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayLeadingTitlesState {
        let outputSequence: UInt64
        public let leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    }
    public func display(leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        requireMainOutputReplayQueue()
        let leadingTitles = outputReplayClosureStore.sanitize(
            leadingTitles,
            path: "leadingTitles"
        )
        nextOutputSequence &+= 1
        displayLeadingTitlesState = .init(
            outputSequence: nextOutputSequence,
            leadingTitles: leadingTitles
        )
    }
    @Published public var displayTrailingTitlesState: DisplayTrailingTitlesState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTrailingTitles(state))
        }
        didSet {
            guard displayTrailingTitlesState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTrailingTitlesState {
        let outputSequence: UInt64
        public let trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    }
    public func display(trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        requireMainOutputReplayQueue()
        let trailingTitles = outputReplayClosureStore.sanitize(
            trailingTitles,
            path: "trailingTitles"
        )
        nextOutputSequence &+= 1
        displayTrailingTitlesState = .init(
            outputSequence: nextOutputSequence,
            trailingTitles: trailingTitles
        )
    }
    @Published public var displayLeadingImageState: DisplayLeadingImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayLeadingImage(state))
        }
        didSet {
            guard displayLeadingImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayLeadingImageState {
        let outputSequence: UInt64
        public let leadingImage: ImageViewPresentableModel?
    }
    public func display(leadingImage: ImageViewPresentableModel?) {
        requireMainOutputReplayQueue()
        let leadingImage = outputReplayClosureStore.sanitize(
            leadingImage,
            path: "leadingImage"
        )
        nextOutputSequence &+= 1
        displayLeadingImageState = .init(
            outputSequence: nextOutputSequence,
            leadingImage: leadingImage
        )
    }
    @Published public var displaySecondaryLeadingImageState: DisplaySecondaryLeadingImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displaySecondaryLeadingImage(state))
        }
        didSet {
            guard displaySecondaryLeadingImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplaySecondaryLeadingImageState {
        let outputSequence: UInt64
        public let secondaryLeadingImage: ImageViewPresentableModel?
    }
    public func display(secondaryLeadingImage: ImageViewPresentableModel?) {
        requireMainOutputReplayQueue()
        let secondaryLeadingImage = outputReplayClosureStore.sanitize(
            secondaryLeadingImage,
            path: "secondaryLeadingImage"
        )
        nextOutputSequence &+= 1
        displaySecondaryLeadingImageState = .init(
            outputSequence: nextOutputSequence,
            secondaryLeadingImage: secondaryLeadingImage
        )
    }
    @Published public var displayTrailingImageState: DisplayTrailingImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayTrailingImage(state))
        }
        didSet {
            guard displayTrailingImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayTrailingImageState {
        let outputSequence: UInt64
        public let trailingImage: ImageViewPresentableModel?
    }
    public func display(trailingImage: ImageViewPresentableModel?) {
        requireMainOutputReplayQueue()
        let trailingImage = outputReplayClosureStore.sanitize(
            trailingImage,
            path: "trailingImage"
        )
        nextOutputSequence &+= 1
        displayTrailingImageState = .init(
            outputSequence: nextOutputSequence,
            trailingImage: trailingImage
        )
    }
    @Published public var displaySecondaryTrailingImageState: DisplaySecondaryTrailingImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displaySecondaryTrailingImage(state))
        }
        didSet {
            guard displaySecondaryTrailingImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplaySecondaryTrailingImageState {
        let outputSequence: UInt64
        public let secondaryTrailingImage: ImageViewPresentableModel?
    }
    public func display(secondaryTrailingImage: ImageViewPresentableModel?) {
        requireMainOutputReplayQueue()
        let secondaryTrailingImage = outputReplayClosureStore.sanitize(
            secondaryTrailingImage,
            path: "secondaryTrailingImage"
        )
        nextOutputSequence &+= 1
        displaySecondaryTrailingImageState = .init(
            outputSequence: nextOutputSequence,
            secondaryTrailingImage: secondaryTrailingImage
        )
    }
    @Published public var displaySubTitleState: DisplaySubTitleState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displaySubTitle(state))
        }
        didSet {
            guard displaySubTitleState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplaySubTitleState {
        let outputSequence: UInt64
        public let subTitle: TextOutputPresentableModel?
    }
    public func display(subTitle: TextOutputPresentableModel?) {
        requireMainOutputReplayQueue()
        let subTitle = outputReplayClosureStore.sanitize(
            subTitle,
            path: "subTitle"
        )
        nextOutputSequence &+= 1
        displaySubTitleState = .init(
            outputSequence: nextOutputSequence,
            subTitle: subTitle
        )
    }
    @Published public var displayValueTitleState: DisplayValueTitleState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayValueTitle(state))
        }
        didSet {
            guard displayValueTitleState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayValueTitleState {
        let outputSequence: UInt64
        public let valueTitle: TextOutputPresentableModel?
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        requireMainOutputReplayQueue()
        let valueTitle = outputReplayClosureStore.sanitize(
            valueTitle,
            path: "valueTitle"
        )
        nextOutputSequence &+= 1
        displayValueTitleState = .init(
            outputSequence: nextOutputSequence,
            valueTitle: valueTitle
        )
    }
    @Published public var displayBottomImageState: DisplayBottomImageState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayBottomImage(state))
        }
        didSet {
            guard displayBottomImageState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayBottomImageState {
        let outputSequence: UInt64
        public let bottomImage: ImageViewPresentableModel?
    }
    public func display(bottomImage: ImageViewPresentableModel?) {
        requireMainOutputReplayQueue()
        let bottomImage = outputReplayClosureStore.sanitize(
            bottomImage,
            path: "bottomImage"
        )
        nextOutputSequence &+= 1
        displayBottomImageState = .init(
            outputSequence: nextOutputSequence,
            bottomImage: bottomImage
        )
    }
    @Published public var displayBottomSeparatorState: DisplayBottomSeparatorState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayBottomSeparator(state))
        }
        didSet {
            guard displayBottomSeparatorState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayBottomSeparatorState {
        let outputSequence: UInt64
        public let bottomSeparator: CardViewPresentableModel.BottomSeparator?
    }
    public func display(bottomSeparator: CardViewPresentableModel.BottomSeparator?) {
        requireMainOutputReplayQueue()
        let bottomSeparator = outputReplayClosureStore.sanitize(
            bottomSeparator,
            path: "bottomSeparator"
        )
        nextOutputSequence &+= 1
        displayBottomSeparatorState = .init(
            outputSequence: nextOutputSequence,
            bottomSeparator: bottomSeparator
        )
    }
    @Published public var displaySwitchControlState: DisplaySwitchControlState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displaySwitchControl(state))
        }
        didSet {
            guard displaySwitchControlState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplaySwitchControlState {
        let outputSequence: UInt64
        public let switchControl: SwitchControlPresentableModel?
    }
    public func display(switchControl: SwitchControlPresentableModel?) {
        requireMainOutputReplayQueue()
        let switchControl = outputReplayClosureStore.sanitize(
            switchControl,
            path: "switchControl"
        )
        nextOutputSequence &+= 1
        displaySwitchControlState = .init(
            outputSequence: nextOutputSequence,
            switchControl: switchControl
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
    @Published public var displayIsUserInteractionEnabledState: DisplayIsUserInteractionEnabledState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsUserInteractionEnabled(state))
        }
        didSet {
            guard displayIsUserInteractionEnabledState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsUserInteractionEnabledState {
        let outputSequence: UInt64
        public let isUserInteractionEnabled: Bool?
    }
    public func display(isUserInteractionEnabled: Bool?) {
        requireMainOutputReplayQueue()
        let isUserInteractionEnabled = outputReplayClosureStore.sanitize(
            isUserInteractionEnabled,
            path: "isUserInteractionEnabled"
        )
        nextOutputSequence &+= 1
        displayIsUserInteractionEnabledState = .init(
            outputSequence: nextOutputSequence,
            isUserInteractionEnabled: isUserInteractionEnabled
        )
    }
    @Published public var displayIsGradientBorderEnabledState: DisplayIsGradientBorderEnabledState? = nil {
        willSet {
            guard let state = newValue else { return }
            beginOutputReplayDelivery(.displayIsGradientBorderEnabled(state))
        }
        didSet {
            guard displayIsGradientBorderEnabledState != nil else { return }
            finishOutputReplayDelivery()
        }
    }
    public struct DisplayIsGradientBorderEnabledState {
        let outputSequence: UInt64
        public let isGradientBorderEnabled: Bool
    }
    public func display(isGradientBorderEnabled: Bool) {
        requireMainOutputReplayQueue()
        let isGradientBorderEnabled = outputReplayClosureStore.sanitize(
            isGradientBorderEnabled,
            path: "isGradientBorderEnabled"
        )
        nextOutputSequence &+= 1
        displayIsGradientBorderEnabledState = .init(
            outputSequence: nextOutputSequence,
            isGradientBorderEnabled: isGradientBorderEnabled
        )
    }
}
