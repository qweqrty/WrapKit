import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine

final class SUICardViewStateModel: ObservableObject {
    private struct SequencedOutput {
        let sequence: UInt64
        let apply: (SUICardViewStateModel) -> Void
    }

    private struct OutputReplayCheckpoint {
        let isHidden: Bool
        let accessibilityIdentifier: String?
        let accessibilityLabel: String?
        let accessibilityHint: String?
        let style: CardViewPresentableModel.Style
        let backgroundImage: ImageViewPresentableModel?
        let title: TextOutputPresentableModel?
        let leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
        let trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
        let leadingImage: ImageViewPresentableModel?
        let secondaryLeadingImage: ImageViewPresentableModel?
        let trailingImage: ImageViewPresentableModel?
        let secondaryTrailingImage: ImageViewPresentableModel?
        let subTitle: TextOutputPresentableModel?
        let valueTitle: TextOutputPresentableModel?
        let bottomImage: ImageViewPresentableModel?
        let bottomSeparator: CardViewPresentableModel.BottomSeparator?
        let switchControl: SwitchControlPresentableModel?
        let onPress: (() -> Void)?
        let onLongPress: (() -> Void)?
        let isUserInteractionEnabled: Bool
        let activeGradientBorderColors: [Color]?
        let trailingImageLeadingSpacing: CGFloat?
        let secondaryTrailingImageLeadingSpacing: CGFloat?
        let retainedBackgroundImage: ImageViewPresentableModel
        let backgroundImageAdapter: ImageViewOutputSwiftUIAdapter
        let leadingImageAdapter: ImageViewOutputSwiftUIAdapter
        let secondaryLeadingImageAdapter: ImageViewOutputSwiftUIAdapter
        let trailingImageAdapter: ImageViewOutputSwiftUIAdapter
        let secondaryTrailingImageAdapter: ImageViewOutputSwiftUIAdapter
        let bottomImageAdapter: ImageViewOutputSwiftUIAdapter
        let leadingTitlesAdapter: KeyValueFieldViewOutputSwiftUIAdapter
        let titleViewsAdapter: KeyValueFieldViewOutputSwiftUIAdapter
        let trailingTitlesAdapter: KeyValueFieldViewOutputSwiftUIAdapter
        let switchControlAdapter: SwitchCotrolOutputSwiftUIAdapter
        let subTitleAdapter: TextOutputSwiftUIAdapter
    }

    @Published var isHidden: Bool = false
    @Published var accessibilityIdentifier: String?
    @Published var accessibilityLabel: String?
    @Published var accessibilityHint: String?
    @Published var style: CardViewPresentableModel.Style = .init(
        backgroundColor: .clear,
        vStacklayoutMargins: .init(top: 0, leading: 8, bottom: 0, trailing: 8),
        hStacklayoutMargins: .zero,
        hStackViewDistribution: .fill,
        leadingTitleKeyTextColor: .black,
        titleKeyTextColor: .black,
        trailingTitleKeyTextColor: .black,
        titleValueTextColor: .black,
        subTitleTextColor: .gray,
        leadingTitleKeyLabelFont: .systemFont(ofSize: 16),
        titleKeyLabelFont: .systemFont(ofSize: 16),
        trailingTitleKeyLabelFont: .systemFont(ofSize: 16),
        titleValueLabelFont: .systemFont(ofSize: 16),
        subTitleLabelFont: .systemFont(ofSize: 16),
        cornerRadius: 0,
        stackSpace: 0,
        hStackViewSpacing: 14,
        titleKeyNumberOfLines: 0,
        titleValueNumberOfLines: 0
    )
    @Published var backgroundImage: ImageViewPresentableModel?
    @Published var title: TextOutputPresentableModel?
    @Published var leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    @Published var trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    @Published var leadingImage: ImageViewPresentableModel?
    @Published var secondaryLeadingImage: ImageViewPresentableModel?
    @Published var trailingImage: ImageViewPresentableModel?
    @Published var secondaryTrailingImage: ImageViewPresentableModel?
    @Published var subTitle: TextOutputPresentableModel?
    @Published var valueTitle: TextOutputPresentableModel?
    @Published var bottomImage: ImageViewPresentableModel?
    @Published var bottomSeparator: CardViewPresentableModel.BottomSeparator?
    @Published var switchControl: SwitchControlPresentableModel?
    @Published var onPress: (() -> Void)?
    @Published var onLongPress: (() -> Void)?
    @Published var isUserInteractionEnabled: Bool = true
    @Published private(set) var activeGradientBorderColors: [Color]?
    @Published private(set) var trailingImageLeadingSpacing: CGFloat?
    @Published private(set) var secondaryTrailingImageLeadingSpacing: CGFloat?

    let backgroundImageAdapter: ImageViewOutputSwiftUIAdapter
    let leadingImageAdapter: ImageViewOutputSwiftUIAdapter
    let secondaryLeadingImageAdapter: ImageViewOutputSwiftUIAdapter
    let trailingImageAdapter: ImageViewOutputSwiftUIAdapter
    let secondaryTrailingImageAdapter: ImageViewOutputSwiftUIAdapter
    let bottomImageAdapter: ImageViewOutputSwiftUIAdapter
    let leadingTitlesAdapter: KeyValueFieldViewOutputSwiftUIAdapter
    let titleViewsAdapter: KeyValueFieldViewOutputSwiftUIAdapter
    let trailingTitlesAdapter: KeyValueFieldViewOutputSwiftUIAdapter
    let switchControlAdapter: SwitchCotrolOutputSwiftUIAdapter
    let subTitleAdapter: TextOutputSwiftUIAdapter
    let subTitleStateModel: SUILabelStateModel

    private let adapter: CardViewOutputSwiftUIAdapter

    private var outputReplayConsumer: CardViewOutputSwiftUIAdapter.OutputReplayConsumer?
    private var retainedBackgroundImage = ImageViewPresentableModel()
    private var cancellables: Set<AnyCancellable> = []
    private var latestVisibilityOutputSequence: UInt64 = 0
    private var latestStyleOutputSequence: UInt64 = 0
    private var latestBackgroundImageOutputSequence: UInt64 = 0
    private var latestTitleOutputSequence: UInt64 = 0
    private var latestLeadingTitlesOutputSequence: UInt64 = 0
    private var latestTrailingTitlesOutputSequence: UInt64 = 0
    private var latestLeadingImageOutputSequence: UInt64 = 0
    private var latestSecondaryLeadingImageOutputSequence: UInt64 = 0
    private var latestTrailingImageOutputSequence: UInt64 = 0
    private var latestSecondaryTrailingImageOutputSequence: UInt64 = 0
    private var latestSubTitleOutputSequence: UInt64 = 0
    private var latestValueTitleOutputSequence: UInt64 = 0
    private var latestBottomImageOutputSequence: UInt64 = 0
    private var latestBottomSeparatorOutputSequence: UInt64 = 0
    private var latestSwitchControlOutputSequence: UInt64 = 0
    private var latestOnPressOutputSequence: UInt64 = 0
    private var latestOnLongPressOutputSequence: UInt64 = 0
    private var latestUserInteractionOutputSequence: UInt64 = 0
    private var latestGradientBorderOutputSequence: UInt64 = 0
    private var isCollectingInitialOutputs = true
    private var initialOutputs: [SequencedOutput] = []

    init(adapter: CardViewOutputSwiftUIAdapter) {
        let outputReplayConsumer = adapter.claimOutputReplayConsumer()
        self.outputReplayConsumer = outputReplayConsumer
        let outputReplayCheckpoint = adapter.outputReplayCheckpoint(
            as: OutputReplayCheckpoint.self,
            consumer: outputReplayConsumer
        )
        let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)
        self.adapter = adapter
        backgroundImageAdapter = outputReplayCheckpoint?.backgroundImageAdapter
            ?? ImageViewOutputSwiftUIAdapter()
        leadingImageAdapter = outputReplayCheckpoint?.leadingImageAdapter
            ?? ImageViewOutputSwiftUIAdapter()
        secondaryLeadingImageAdapter = outputReplayCheckpoint?.secondaryLeadingImageAdapter
            ?? ImageViewOutputSwiftUIAdapter()
        trailingImageAdapter = outputReplayCheckpoint?.trailingImageAdapter
            ?? ImageViewOutputSwiftUIAdapter()
        secondaryTrailingImageAdapter = outputReplayCheckpoint?.secondaryTrailingImageAdapter
            ?? ImageViewOutputSwiftUIAdapter()
        bottomImageAdapter = outputReplayCheckpoint?.bottomImageAdapter
            ?? ImageViewOutputSwiftUIAdapter()
        leadingTitlesAdapter = outputReplayCheckpoint?.leadingTitlesAdapter
            ?? KeyValueFieldViewOutputSwiftUIAdapter()
        titleViewsAdapter = outputReplayCheckpoint?.titleViewsAdapter
            ?? KeyValueFieldViewOutputSwiftUIAdapter()
        trailingTitlesAdapter = outputReplayCheckpoint?.trailingTitlesAdapter
            ?? KeyValueFieldViewOutputSwiftUIAdapter()
        switchControlAdapter = outputReplayCheckpoint?.switchControlAdapter
            ?? SwitchCotrolOutputSwiftUIAdapter()
        subTitleAdapter = outputReplayCheckpoint?.subTitleAdapter
            ?? TextOutputSwiftUIAdapter()
        subTitleStateModel = SUILabelStateModel(adapter: subTitleAdapter)

        if outputReplayCheckpoint == nil {
            synchronizeChildAdapters()
        }

        adapter.outputReplayPublisher(
            adapter.$displayModelState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(model: state.model, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayStyleState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state, let style = state.style else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(style: style, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayBackgroundImageState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(backgroundImage: state.backgroundImage, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTitleState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(title: state.title, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayLeadingTitlesState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(leadingTitles: state.leadingTitles, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTrailingTitlesState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(trailingTitles: state.trailingTitles, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayLeadingImageState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(leadingImage: state.leadingImage, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySecondaryLeadingImageState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(
                        secondaryLeadingImage: state.secondaryLeadingImage,
                        outputSequence: state.outputSequence
                    )
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTrailingImageState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(trailingImage: state.trailingImage, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySecondaryTrailingImageState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(
                        secondaryTrailingImage: state.secondaryTrailingImage,
                        outputSequence: state.outputSequence
                    )
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySubTitleState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(subTitle: state.subTitle, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayValueTitleState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(valueTitle: state.valueTitle, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayBottomImageState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(bottomImage: state.bottomImage, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayBottomSeparatorState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(bottomSeparator: state.bottomSeparator, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySwitchControlState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(switchControl: state.switchControl, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnPressState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(onPress: state.onPress, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayOnLongPressState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(onLongPress: state.onLongPress, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsHiddenState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(isHidden: state.isHidden, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsUserInteractionEnabledState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self,
                      let state,
                      let isEnabled = state.isUserInteractionEnabled else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(isUserInteractionEnabled: isEnabled, outputSequence: state.outputSequence)
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsGradientBorderEnabledState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                receive(outputSequence: state.outputSequence) {
                    $0.apply(
                        isGradientBorderEnabled: state.isGradientBorderEnabled,
                        outputSequence: state.outputSequence
                    )
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayCheckpointRequestPublisher(consumer: outputReplayConsumer)
            .sink { [weak self] in self?.persistReplayCheckpoint() }
            .store(in: &cancellables)

        if let outputReplayCheckpoint {
            restore(outputReplayCheckpoint)
        }

        bufferedOutputReplayPublisher
            .sink { [weak adapter] event in
                adapter?.replayOutputEvent(event, consumer: outputReplayConsumer)
            }
            .store(in: &cancellables)

        replayInitialOutputs()
        persistReplayCheckpoint()
    }

    private func apply(model: CardViewPresentableModel?, outputSequence: UInt64) {
        apply(isHidden: model == nil, outputSequence: outputSequence)
        accessibilityIdentifier = model?.accessibilityIdentifier
        accessibilityLabel = model?.accessibility?.label
        accessibilityHint = model?.accessibility?.hint
        guard let model else {
            persistReplayCheckpoint()
            return
        }

        if let style = model.style {
            apply(style: style, outputSequence: outputSequence)
        }

        apply(backgroundImage: model.backgroundImage, outputSequence: outputSequence)
        apply(leadingTitles: model.leadingTitles, outputSequence: outputSequence)
        apply(title: model.title, outputSequence: outputSequence)
        apply(valueTitle: model.valueTitle, outputSequence: outputSequence)
        apply(subTitle: model.subTitle, outputSequence: outputSequence)
        apply(leadingImage: model.leadingImage, outputSequence: outputSequence)
        apply(secondaryLeadingImage: model.secondaryLeadingImage, outputSequence: outputSequence)
        apply(trailingImage: model.trailingImage, outputSequence: outputSequence)
        apply(secondaryTrailingImage: model.secondaryTrailingImage, outputSequence: outputSequence)
        apply(bottomImage: model.bottomImage, outputSequence: outputSequence)
        apply(bottomSeparator: model.bottomSeparator, outputSequence: outputSequence)
        apply(switchControl: model.switchControl, outputSequence: outputSequence)
        apply(trailingTitles: model.trailingTitles, outputSequence: outputSequence)
        apply(onPress: model.onPress, outputSequence: outputSequence)
        apply(onLongPress: model.onLongPress, outputSequence: outputSequence)
        if let isUserInteractionEnabled = model.isUserInteractionEnabled {
            apply(
                isUserInteractionEnabled: isUserInteractionEnabled,
                outputSequence: outputSequence
            )
        }
        apply(
            isGradientBorderEnabled: model.isGradientBorderEnabled,
            outputSequence: outputSequence
        )
        persistReplayCheckpoint()
    }

    private func receive(
        outputSequence: UInt64,
        apply: @escaping (SUICardViewStateModel) -> Void
    ) {
        let output = SequencedOutput(sequence: outputSequence, apply: apply)
        if isCollectingInitialOutputs {
            initialOutputs.append(output)
        } else {
            output.apply(self)
        }
    }

    private func replayInitialOutputs() {
        isCollectingInitialOutputs = false
        let outputs = initialOutputs.sorted { $0.sequence < $1.sequence }
        initialOutputs.removeAll()
        outputs.forEach { $0.apply(self) }
    }

    private func apply(isHidden: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    private func apply(style: CardViewPresentableModel.Style, outputSequence: UInt64) {
        guard outputSequence >= latestStyleOutputSequence else { return }
        latestStyleOutputSequence = outputSequence
        self.style = style
        persistReplayCheckpoint()
    }

    private func apply(backgroundImage: ImageViewPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestBackgroundImageOutputSequence else { return }
        latestBackgroundImageOutputSequence = outputSequence
        setBackgroundImage(backgroundImage)
        persistReplayCheckpoint()
    }

    private func apply(title: TextOutputPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestTitleOutputSequence else { return }
        latestTitleOutputSequence = outputSequence
        setTitle(title)
        persistReplayCheckpoint()
    }

    private func apply(
        leadingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestLeadingTitlesOutputSequence else { return }
        latestLeadingTitlesOutputSequence = outputSequence
        setLeadingTitles(leadingTitles)
        persistReplayCheckpoint()
    }

    private func apply(
        trailingTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestTrailingTitlesOutputSequence else { return }
        latestTrailingTitlesOutputSequence = outputSequence
        setTrailingTitles(trailingTitles)
        persistReplayCheckpoint()
    }

    private func apply(leadingImage: ImageViewPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestLeadingImageOutputSequence else { return }
        latestLeadingImageOutputSequence = outputSequence
        setLeadingImage(leadingImage)
        persistReplayCheckpoint()
    }

    private func apply(secondaryLeadingImage: ImageViewPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestSecondaryLeadingImageOutputSequence else { return }
        latestSecondaryLeadingImageOutputSequence = outputSequence
        setSecondaryLeadingImage(secondaryLeadingImage)
        persistReplayCheckpoint()
    }

    private func apply(trailingImage: ImageViewPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestTrailingImageOutputSequence else { return }
        latestTrailingImageOutputSequence = outputSequence
        setTrailingImage(trailingImage)
        persistReplayCheckpoint()
    }

    private func apply(secondaryTrailingImage: ImageViewPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestSecondaryTrailingImageOutputSequence else { return }
        latestSecondaryTrailingImageOutputSequence = outputSequence
        setSecondaryTrailingImage(secondaryTrailingImage)
        persistReplayCheckpoint()
    }

    private func apply(subTitle: TextOutputPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestSubTitleOutputSequence else { return }
        latestSubTitleOutputSequence = outputSequence
        setSubTitle(subTitle)
        persistReplayCheckpoint()
    }

    private func apply(valueTitle: TextOutputPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestValueTitleOutputSequence else { return }
        latestValueTitleOutputSequence = outputSequence
        setValueTitle(valueTitle)
        persistReplayCheckpoint()
    }

    private func apply(bottomImage: ImageViewPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestBottomImageOutputSequence else { return }
        latestBottomImageOutputSequence = outputSequence
        setBottomImage(bottomImage)
        persistReplayCheckpoint()
    }

    private func apply(
        bottomSeparator: CardViewPresentableModel.BottomSeparator?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestBottomSeparatorOutputSequence else { return }
        latestBottomSeparatorOutputSequence = outputSequence
        self.bottomSeparator = bottomSeparator
        persistReplayCheckpoint()
    }

    private func apply(switchControl: SwitchControlPresentableModel?, outputSequence: UInt64) {
        guard outputSequence >= latestSwitchControlOutputSequence else { return }
        latestSwitchControlOutputSequence = outputSequence
        setSwitchControl(switchControl)
        persistReplayCheckpoint()
    }

    private func apply(onPress: (() -> Void)?, outputSequence: UInt64) {
        guard outputSequence >= latestOnPressOutputSequence else { return }
        latestOnPressOutputSequence = outputSequence
        self.onPress = onPress
        persistReplayCheckpoint()
    }

    private func apply(onLongPress: (() -> Void)?, outputSequence: UInt64) {
        guard outputSequence >= latestOnLongPressOutputSequence else { return }
        latestOnLongPressOutputSequence = outputSequence
        self.onLongPress = onLongPress
        persistReplayCheckpoint()
    }

    private func apply(isUserInteractionEnabled: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestUserInteractionOutputSequence else { return }
        latestUserInteractionOutputSequence = outputSequence
        self.isUserInteractionEnabled = isUserInteractionEnabled
        persistReplayCheckpoint()
    }

    private func apply(isGradientBorderEnabled: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestGradientBorderOutputSequence else { return }
        latestGradientBorderOutputSequence = outputSequence
        applyGradientBorder(isEnabled: isGradientBorderEnabled)
        persistReplayCheckpoint()
    }

    private func setBackgroundImage(_ model: ImageViewPresentableModel?) {
        guard let model else {
            retainedBackgroundImage = retainedBackgroundImage.clearingForNilModel()
            backgroundImage = nil
            backgroundImageAdapter.display(model: nil)
            return
        }
        retainedBackgroundImage = retainedBackgroundImage.mergingFullModel(model)
        backgroundImage = retainedBackgroundImage
        backgroundImageAdapter.display(model: model)
    }

    private func setLeadingImage(_ model: ImageViewPresentableModel?) {
        leadingImage = normalizeIconImageModel(model)
        leadingImageAdapter.display(model: leadingImage)
    }

    private func setSecondaryLeadingImage(_ model: ImageViewPresentableModel?) {
        secondaryLeadingImage = normalizeIconImageModel(model)
        secondaryLeadingImageAdapter.display(model: secondaryLeadingImage)
    }

    private func setTrailingImage(_ model: ImageViewPresentableModel?) {
        trailingImage = normalizeIconImageModel(model)
        trailingImageAdapter.display(model: trailingImage)
        if let spacing = style.trailingImageLeadingSpacing {
            trailingImageLeadingSpacing = spacing
        }
    }

    private func setSecondaryTrailingImage(_ model: ImageViewPresentableModel?) {
        secondaryTrailingImage = normalizeIconImageModel(model)
        secondaryTrailingImageAdapter.display(model: secondaryTrailingImage)
        if let spacing = style.secondaryTrailingImageLeadingSpacing {
            secondaryTrailingImageLeadingSpacing = spacing
        }
    }

    private func setTitle(_ model: TextOutputPresentableModel?) {
        title = model
        titleViewsAdapter.display(keyTitle: model)
    }

    private func setValueTitle(_ model: TextOutputPresentableModel?) {
        valueTitle = model
        titleViewsAdapter.display(valueTitle: model)
    }

    private func setSubTitle(_ model: TextOutputPresentableModel?) {
        subTitle = model
        subTitleAdapter.display(model: model)
    }

    private func setSwitchControl(_ model: SwitchControlPresentableModel?) {
        switchControl = model
        switchControlAdapter.display(model: model)
    }

    private func setBottomImage(_ model: ImageViewPresentableModel?) {
        bottomImage = model
        bottomImageAdapter.display(model: model)
    }

    private func applyGradientBorder(isEnabled: Bool) {
        if isEnabled {
            // UIKit treats this as an event: enabling before a style with gradient colors is
            // ignored, and later style updates do not retroactively start or replace it.
            guard let colors = style.gradientBorderColors, !colors.isEmpty else { return }
            activeGradientBorderColors = colors
        } else {
            activeGradientBorderColors = nil
        }
    }

    private func setLeadingTitles(_ model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        leadingTitles = model
        leadingTitlesAdapter.display(model: model)
    }

    private func setTrailingTitles(_ model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        trailingTitles = model
        trailingTitlesAdapter.display(model: model)
    }

    private func synchronizeChildAdapters() {
        backgroundImageAdapter.display(model: backgroundImage)
        leadingTitlesAdapter.display(model: leadingTitles)
        // CardView's original setup synchronizes only the value slot. The key slot stays in
        // its initial visible state until a title output is received, matching UIKit layout.
        titleViewsAdapter.display(valueTitle: valueTitle)
        trailingTitlesAdapter.display(model: trailingTitles)
        leadingImageAdapter.display(model: leadingImage)
        secondaryLeadingImageAdapter.display(model: secondaryLeadingImage)
        trailingImageAdapter.display(model: trailingImage)
        secondaryTrailingImageAdapter.display(model: secondaryTrailingImage)
        bottomImageAdapter.display(model: bottomImage)
        switchControlAdapter.display(model: switchControl)
        subTitleAdapter.display(model: subTitle)
    }

    private func normalizeIconImageModel(_ model: ImageViewPresentableModel?) -> ImageViewPresentableModel? {
        guard let model else { return nil }

        let resolvedSize: CGSize? = {
            if let size = model.size {
                return size
            }
            if case .asset(let image) = model.image {
                return image?.size
            }
            if case .symbolName(let name) = model.image {
                return ImageFactory.systemImage(named: name)?.size
            }
            return nil
        }()

        return .init(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            size: resolvedSize,
            image: model.image,
            onPress: model.onPress,
            onLongPress: model.onLongPress,
            contentModeIsFit: model.contentModeIsFit ?? true,
            borderWidth: model.borderWidth,
            borderColor: model.borderColor,
            cornerRadius: model.cornerRadius,
            alpha: model.alpha
        )
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            isHidden: isHidden,
            accessibilityIdentifier: accessibilityIdentifier,
            accessibilityLabel: accessibilityLabel,
            accessibilityHint: accessibilityHint,
            style: style,
            backgroundImage: backgroundImage,
            title: title,
            leadingTitles: leadingTitles,
            trailingTitles: trailingTitles,
            leadingImage: leadingImage,
            secondaryLeadingImage: secondaryLeadingImage,
            trailingImage: trailingImage,
            secondaryTrailingImage: secondaryTrailingImage,
            subTitle: subTitle,
            valueTitle: valueTitle,
            bottomImage: bottomImage,
            bottomSeparator: bottomSeparator,
            switchControl: switchControl,
            onPress: onPress,
            onLongPress: onLongPress,
            isUserInteractionEnabled: isUserInteractionEnabled,
            activeGradientBorderColors: activeGradientBorderColors,
            trailingImageLeadingSpacing: trailingImageLeadingSpacing,
            secondaryTrailingImageLeadingSpacing: secondaryTrailingImageLeadingSpacing,
            retainedBackgroundImage: retainedBackgroundImage,
            backgroundImageAdapter: backgroundImageAdapter,
            leadingImageAdapter: leadingImageAdapter,
            secondaryLeadingImageAdapter: secondaryLeadingImageAdapter,
            trailingImageAdapter: trailingImageAdapter,
            secondaryTrailingImageAdapter: secondaryTrailingImageAdapter,
            bottomImageAdapter: bottomImageAdapter,
            leadingTitlesAdapter: leadingTitlesAdapter,
            titleViewsAdapter: titleViewsAdapter,
            trailingTitlesAdapter: trailingTitlesAdapter,
            switchControlAdapter: switchControlAdapter,
            subTitleAdapter: subTitleAdapter
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        isHidden = checkpoint.isHidden
        accessibilityIdentifier = checkpoint.accessibilityIdentifier
        accessibilityLabel = checkpoint.accessibilityLabel
        accessibilityHint = checkpoint.accessibilityHint
        style = checkpoint.style
        backgroundImage = checkpoint.backgroundImage
        title = checkpoint.title
        leadingTitles = checkpoint.leadingTitles
        trailingTitles = checkpoint.trailingTitles
        leadingImage = checkpoint.leadingImage
        secondaryLeadingImage = checkpoint.secondaryLeadingImage
        trailingImage = checkpoint.trailingImage
        secondaryTrailingImage = checkpoint.secondaryTrailingImage
        subTitle = checkpoint.subTitle
        valueTitle = checkpoint.valueTitle
        bottomImage = checkpoint.bottomImage
        bottomSeparator = checkpoint.bottomSeparator
        switchControl = checkpoint.switchControl
        onPress = checkpoint.onPress
        onLongPress = checkpoint.onLongPress
        isUserInteractionEnabled = checkpoint.isUserInteractionEnabled
        activeGradientBorderColors = checkpoint.activeGradientBorderColors
        trailingImageLeadingSpacing = checkpoint.trailingImageLeadingSpacing
        secondaryTrailingImageLeadingSpacing = checkpoint.secondaryTrailingImageLeadingSpacing
        retainedBackgroundImage = checkpoint.retainedBackgroundImage
    }

}

#endif
