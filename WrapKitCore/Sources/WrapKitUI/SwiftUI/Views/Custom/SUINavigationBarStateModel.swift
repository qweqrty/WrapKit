import Foundation

#if canImport(SwiftUI)
    import Combine
    import SwiftUI

    final class SUINavigationBarStateModel: ObservableObject {
        static let defaultStyle: HeaderPresentableModel.Style = .init(
            backgroundColor: .clear,
            horizontalSpacing: 12,
            primeFont: .systemFont(ofSize: 18),
            primeColor: .label,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .secondaryLabel,
            numberOfLines: 1
        )
        @Published var model: HeaderPresentableModel = .init(style: SUINavigationBarStateModel.defaultStyle)
        @Published var isHidden: Bool = false
        @Published private(set) var leadingCardImageTint: Color = .blue

        let leadingCardAdapter: CardViewOutputSwiftUIAdapter
        let primeTrailingButtonAdapter: ButtonOutputSwiftUIAdapter
        let secondaryTrailingButtonAdapter: ButtonOutputSwiftUIAdapter
        let tertiaryTrailingButtonAdapter: ButtonOutputSwiftUIAdapter
        let centerKeyAdapter: TextOutputSwiftUIAdapter
        let centerValueAdapter: TextOutputSwiftUIAdapter
        let centerTitledImageAdapter: ImageViewOutputSwiftUIAdapter
        let centerTitledImageTitleAdapter: TextOutputSwiftUIAdapter

        let primeTrailingButtonStateModel: SUIButtonStateModel
        let secondaryTrailingButtonStateModel: SUIButtonStateModel
        let tertiaryTrailingButtonStateModel: SUIButtonStateModel
        let centerKeyStateModel: SUILabelStateModel
        let centerValueStateModel: SUILabelStateModel
        let centerTitledImageTitleStateModel: SUILabelStateModel

        private let adapter: HeaderOutputSwiftUIAdapter

        private var outputReplayConsumer: HeaderOutputSwiftUIAdapter.OutputReplayConsumer?
        private var effectiveLeadingCardStyle = SUINavigationBarStateModel.defaultLeadingCardStyle
        private var cancellables: Set<AnyCancellable> = []
        private var latestVisibilityOutputSequence: UInt64 = 0
        private var latestStyleOutputSequence: UInt64 = 0
        private var latestCenterViewOutputSequence: UInt64 = 0
        private var latestLeadingCardOutputSequence: UInt64 = 0
        private var latestLeadingCardStyleOutputSequence: UInt64 = 0
        private var latestPrimeTrailingImageOutputSequence: UInt64 = 0
        private var latestSecondaryTrailingImageOutputSequence: UInt64 = 0
        private var latestTertiaryTrailingImageOutputSequence: UInt64 = 0

        private struct OutputReplayCheckpoint {
            let model: HeaderPresentableModel
            let isHidden: Bool
            let leadingCardImageTint: Color
            let effectiveLeadingCardStyle: CardViewPresentableModel.Style
            let latestVisibilityOutputSequence: UInt64
            let latestStyleOutputSequence: UInt64
            let latestCenterViewOutputSequence: UInt64
            let latestLeadingCardOutputSequence: UInt64
            let latestLeadingCardStyleOutputSequence: UInt64
            let latestPrimeTrailingImageOutputSequence: UInt64
            let latestSecondaryTrailingImageOutputSequence: UInt64
            let latestTertiaryTrailingImageOutputSequence: UInt64
            let leadingCardAdapter: CardViewOutputSwiftUIAdapter
            let primeTrailingButtonAdapter: ButtonOutputSwiftUIAdapter
            let secondaryTrailingButtonAdapter: ButtonOutputSwiftUIAdapter
            let tertiaryTrailingButtonAdapter: ButtonOutputSwiftUIAdapter
            let centerKeyAdapter: TextOutputSwiftUIAdapter
            let centerValueAdapter: TextOutputSwiftUIAdapter
            let centerTitledImageAdapter: ImageViewOutputSwiftUIAdapter
            let centerTitledImageTitleAdapter: TextOutputSwiftUIAdapter
        }

        private static let defaultLeadingCardStyle: CardViewPresentableModel.Style = .init(
            backgroundColor: .clear,
            vStacklayoutMargins: .init(top: 0, leading: 10, bottom: 0, trailing: 10),
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
            subtitleNumberOfLines: 1,
            cornerRadius: 0,
            stackSpace: 0,
            hStackViewSpacing: 8,
            titleKeyNumberOfLines: 1,
            titleValueNumberOfLines: 1
        )

        init(adapter: HeaderOutputSwiftUIAdapter) {
            let outputReplayConsumer = adapter.claimOutputReplayConsumer()
            self.outputReplayConsumer = outputReplayConsumer
            let replayCheckpoint = adapter.outputReplayCheckpoint(as: OutputReplayCheckpoint.self, consumer: outputReplayConsumer)
            let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)
            let leadingCardAdapter = replayCheckpoint?.leadingCardAdapter
                ?? CardViewOutputSwiftUIAdapter()
            let primeTrailingButtonAdapter = replayCheckpoint?.primeTrailingButtonAdapter
                ?? ButtonOutputSwiftUIAdapter()
            let secondaryTrailingButtonAdapter = replayCheckpoint?.secondaryTrailingButtonAdapter
                ?? ButtonOutputSwiftUIAdapter()
            let tertiaryTrailingButtonAdapter = replayCheckpoint?.tertiaryTrailingButtonAdapter
                ?? ButtonOutputSwiftUIAdapter()
            let centerKeyAdapter = replayCheckpoint?.centerKeyAdapter
                ?? TextOutputSwiftUIAdapter()
            let centerValueAdapter = replayCheckpoint?.centerValueAdapter
                ?? TextOutputSwiftUIAdapter()
            let centerTitledImageAdapter = replayCheckpoint?.centerTitledImageAdapter
                ?? ImageViewOutputSwiftUIAdapter()
            let centerTitledImageTitleAdapter = replayCheckpoint?.centerTitledImageTitleAdapter
                ?? TextOutputSwiftUIAdapter()

            self.adapter = adapter
            self.leadingCardAdapter = leadingCardAdapter
            self.primeTrailingButtonAdapter = primeTrailingButtonAdapter
            self.secondaryTrailingButtonAdapter = secondaryTrailingButtonAdapter
            self.tertiaryTrailingButtonAdapter = tertiaryTrailingButtonAdapter
            self.centerKeyAdapter = centerKeyAdapter
            self.centerValueAdapter = centerValueAdapter
            self.centerTitledImageAdapter = centerTitledImageAdapter
            self.centerTitledImageTitleAdapter = centerTitledImageTitleAdapter
            primeTrailingButtonStateModel = SUIButtonStateModel(adapter: primeTrailingButtonAdapter)
            secondaryTrailingButtonStateModel = SUIButtonStateModel(adapter: secondaryTrailingButtonAdapter)
            tertiaryTrailingButtonStateModel = SUIButtonStateModel(adapter: tertiaryTrailingButtonAdapter)
            centerKeyStateModel = SUILabelStateModel(adapter: centerKeyAdapter)
            centerValueStateModel = SUILabelStateModel(adapter: centerValueAdapter)
            centerTitledImageTitleStateModel = SUILabelStateModel(adapter: centerTitledImageTitleAdapter)
            if replayCheckpoint == nil {
                leadingCardAdapter.display(style: effectiveLeadingCardStyle)
            }

            adapter.outputReplayPublisher(
                adapter.$displayModelReplayState,
                consumer: outputReplayConsumer
            )
                .compactMap { $0 }
                .sink { [weak self] state in
                    self?.apply(model: state.model, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayStyleState,
                consumer: outputReplayConsumer
            )
                .compactMap { $0 }
                .sink { [weak self] state in
                    self?.apply(style: state.style, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayCenterViewState,
                consumer: outputReplayConsumer
            )
                .compactMap { $0 }
                .sink { [weak self] state in
                    self?.apply(centerView: state.centerView, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayLeadingCardState,
                consumer: outputReplayConsumer
            )
                .compactMap { $0 }
                .sink { [weak self] state in
                    self?.apply(leadingCard: state.leadingCard, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayPrimeTrailingImageState,
                consumer: outputReplayConsumer
            )
                .compactMap { $0 }
                .sink { [weak self] state in
                    self?.apply(
                        primeTrailingImage: state.primeTrailingImage,
                        outputSequence: state.outputSequence
                    )
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displaySecondaryTrailingImageState,
                consumer: outputReplayConsumer
            )
                .compactMap { $0 }
                .sink { [weak self] state in
                    self?.apply(
                        secondaryTrailingImage: state.secondaryTrailingImage,
                        outputSequence: state.outputSequence
                    )
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayTertiaryTrailingImageState,
                consumer: outputReplayConsumer
            )
                .compactMap { $0 }
                .sink { [weak self] state in
                    self?.apply(
                        tertiaryTrailingImage: state.tertiaryTrailingImage,
                        outputSequence: state.outputSequence
                    )
                }
                .store(in: &cancellables)

            adapter.outputReplayPublisher(
                adapter.$displayIsHiddenState,
                consumer: outputReplayConsumer
            )
                .compactMap { $0 }
                .sink { [weak self] state in
                    self?.apply(isHidden: state.isHidden, outputSequence: state.outputSequence)
                }
                .store(in: &cancellables)

            adapter.outputReplayCheckpointRequestPublisher(consumer: outputReplayConsumer)
                .sink { [weak self] in self?.persistReplayCheckpoint() }
                .store(in: &cancellables)

            if let replayCheckpoint {
                restore(replayCheckpoint)
            }

            bufferedOutputReplayPublisher
                .sink { [weak adapter] event in
                    adapter?.replayOutputEvent(event, consumer: outputReplayConsumer)
                }
                .store(in: &cancellables)

            persistReplayCheckpoint()
        }

        private func apply(model: HeaderPresentableModel?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            apply(isHidden: model == nil, outputSequence: outputSequence)
            guard let model else { return }

            apply(centerView: model.centerView, outputSequence: outputSequence)
            if let style = model.style {
                apply(style: style, outputSequence: outputSequence)
            }
            apply(leadingCard: model.leadingCard, outputSequence: outputSequence)
            apply(primeTrailingImage: model.primeTrailingImage, outputSequence: outputSequence)
            apply(secondaryTrailingImage: model.secondaryTrailingImage, outputSequence: outputSequence)
            apply(tertiaryTrailingImage: model.tertiaryTrailingImage, outputSequence: outputSequence)
        }

        private func apply(isHidden: Bool, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestVisibilityOutputSequence else { return }
            latestVisibilityOutputSequence = outputSequence
            self.isHidden = isHidden
        }

        private func apply(style: HeaderPresentableModel.Style?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard let style else { return }
            guard outputSequence >= latestStyleOutputSequence else { return }
            latestStyleOutputSequence = outputSequence
            updateModel { current in
                HeaderPresentableModel(
                    style: style,
                    centerView: current.centerView,
                    leadingCard: current.leadingCard,
                    primeTrailingImage: current.primeTrailingImage,
                    secondaryTrailingImage: current.secondaryTrailingImage,
                    tertiaryTrailingImage: current.tertiaryTrailingImage
                )
            }
            if outputSequence >= latestLeadingCardStyleOutputSequence {
                latestLeadingCardStyleOutputSequence = outputSequence
                applyHeaderStyleToLeadingCard(style)
            }
        }

        private func apply(centerView: HeaderPresentableModel.CenterView?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestCenterViewOutputSequence else { return }
            latestCenterViewOutputSequence = outputSequence
            updateModel { current in
                HeaderPresentableModel(
                    style: current.style,
                    centerView: centerView,
                    leadingCard: current.leadingCard,
                    primeTrailingImage: current.primeTrailingImage,
                    secondaryTrailingImage: current.secondaryTrailingImage,
                    tertiaryTrailingImage: current.tertiaryTrailingImage
                )
            }
            syncCenterAdapters(for: centerView)
        }

        private func apply(leadingCard: CardViewPresentableModel?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestLeadingCardOutputSequence else { return }
            latestLeadingCardOutputSequence = outputSequence
            updateModel { current in
                HeaderPresentableModel(
                    style: current.style,
                    centerView: current.centerView,
                    leadingCard: leadingCard,
                    primeTrailingImage: current.primeTrailingImage,
                    secondaryTrailingImage: current.secondaryTrailingImage,
                    tertiaryTrailingImage: current.tertiaryTrailingImage
                )
            }
            syncLeadingCardAdapter(outputSequence: outputSequence)
        }

        private func apply(primeTrailingImage: ButtonPresentableModel?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestPrimeTrailingImageOutputSequence else { return }
            latestPrimeTrailingImageOutputSequence = outputSequence
            updateModel { current in
                HeaderPresentableModel(
                    style: current.style,
                    centerView: current.centerView,
                    leadingCard: current.leadingCard,
                    primeTrailingImage: primeTrailingImage,
                    secondaryTrailingImage: current.secondaryTrailingImage,
                    tertiaryTrailingImage: current.tertiaryTrailingImage
                )
            }
            primeTrailingButtonAdapter.display(model: primeTrailingImage)
        }

        private func apply(secondaryTrailingImage: ButtonPresentableModel?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestSecondaryTrailingImageOutputSequence else { return }
            latestSecondaryTrailingImageOutputSequence = outputSequence
            updateModel { current in
                HeaderPresentableModel(
                    style: current.style,
                    centerView: current.centerView,
                    leadingCard: current.leadingCard,
                    primeTrailingImage: current.primeTrailingImage,
                    secondaryTrailingImage: secondaryTrailingImage,
                    tertiaryTrailingImage: current.tertiaryTrailingImage
                )
            }
            secondaryTrailingButtonAdapter.display(model: secondaryTrailingImage)
        }

        private func apply(tertiaryTrailingImage: ButtonPresentableModel?, outputSequence: UInt64) {
            defer { persistReplayCheckpoint() }
            guard outputSequence >= latestTertiaryTrailingImageOutputSequence else { return }
            latestTertiaryTrailingImageOutputSequence = outputSequence
            updateModel { current in
                HeaderPresentableModel(
                    style: current.style,
                    centerView: current.centerView,
                    leadingCard: current.leadingCard,
                    primeTrailingImage: current.primeTrailingImage,
                    secondaryTrailingImage: current.secondaryTrailingImage,
                    tertiaryTrailingImage: tertiaryTrailingImage
                )
            }
            tertiaryTrailingButtonAdapter.display(model: tertiaryTrailingImage)
        }

        private func updateModel(_ transform: (HeaderPresentableModel) -> HeaderPresentableModel) {
            model = transform(model)
        }

        private func restore(_ checkpoint: OutputReplayCheckpoint) {
            model = checkpoint.model
            isHidden = checkpoint.isHidden
            leadingCardImageTint = checkpoint.leadingCardImageTint
            effectiveLeadingCardStyle = checkpoint.effectiveLeadingCardStyle
            latestVisibilityOutputSequence = checkpoint.latestVisibilityOutputSequence
            latestStyleOutputSequence = checkpoint.latestStyleOutputSequence
            latestCenterViewOutputSequence = checkpoint.latestCenterViewOutputSequence
            latestLeadingCardOutputSequence = checkpoint.latestLeadingCardOutputSequence
            latestLeadingCardStyleOutputSequence = checkpoint.latestLeadingCardStyleOutputSequence
            latestPrimeTrailingImageOutputSequence = checkpoint.latestPrimeTrailingImageOutputSequence
            latestSecondaryTrailingImageOutputSequence = checkpoint.latestSecondaryTrailingImageOutputSequence
            latestTertiaryTrailingImageOutputSequence = checkpoint.latestTertiaryTrailingImageOutputSequence

        }

        private func persistReplayCheckpoint() {
            adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer,
                OutputReplayCheckpoint(
                    model: model,
                    isHidden: isHidden,
                    leadingCardImageTint: leadingCardImageTint,
                    effectiveLeadingCardStyle: effectiveLeadingCardStyle,
                    latestVisibilityOutputSequence: latestVisibilityOutputSequence,
                    latestStyleOutputSequence: latestStyleOutputSequence,
                    latestCenterViewOutputSequence: latestCenterViewOutputSequence,
                    latestLeadingCardOutputSequence: latestLeadingCardOutputSequence,
                    latestLeadingCardStyleOutputSequence: latestLeadingCardStyleOutputSequence,
                    latestPrimeTrailingImageOutputSequence: latestPrimeTrailingImageOutputSequence,
                    latestSecondaryTrailingImageOutputSequence: latestSecondaryTrailingImageOutputSequence,
                    latestTertiaryTrailingImageOutputSequence: latestTertiaryTrailingImageOutputSequence,
                    leadingCardAdapter: leadingCardAdapter,
                    primeTrailingButtonAdapter: primeTrailingButtonAdapter,
                    secondaryTrailingButtonAdapter: secondaryTrailingButtonAdapter,
                    tertiaryTrailingButtonAdapter: tertiaryTrailingButtonAdapter,
                    centerKeyAdapter: centerKeyAdapter,
                    centerValueAdapter: centerValueAdapter,
                    centerTitledImageAdapter: centerTitledImageAdapter,
                    centerTitledImageTitleAdapter: centerTitledImageTitleAdapter
                )
            )
        }

        private func syncCenterAdapters(for centerView: HeaderPresentableModel.CenterView?) {
            switch centerView {
            case .keyValue(let pair):
                centerKeyAdapter.display(model: pair.first)
                centerValueAdapter.display(model: pair.second)
                centerTitledImageAdapter.display(model: nil)
                centerTitledImageTitleAdapter.display(model: nil)
            case .titledImage(let pair):
                centerKeyAdapter.display(model: nil)
                centerValueAdapter.display(model: nil)
                centerTitledImageAdapter.display(model: pair.first)
                centerTitledImageTitleAdapter.display(model: pair.second)
            case .none:
                centerKeyAdapter.display(model: nil)
                centerValueAdapter.display(model: nil)
                centerTitledImageAdapter.display(model: nil)
                centerTitledImageTitleAdapter.display(model: nil)
            }
        }

        private func syncLeadingCardAdapter(outputSequence: UInt64) {
            leadingCardAdapter.display(model: model.leadingCard)
            if let style = model.leadingCard?.style,
               outputSequence >= latestLeadingCardStyleOutputSequence {
                latestLeadingCardStyleOutputSequence = outputSequence
                effectiveLeadingCardStyle = style
            }
            // Keep a single persistent Card child at the same effective style as UIKit.
            // Re-publishing after the model also preserves Header.style -> Card.style order
            // when a SwiftUI subscriber is created after both Output events.
            leadingCardAdapter.display(style: effectiveLeadingCardStyle)
        }

        private func applyHeaderStyleToLeadingCard(_ style: HeaderPresentableModel.Style) {
            leadingCardImageTint = style.primeColor
            effectiveLeadingCardStyle = effectiveLeadingCardStyle.replacingTitleStyle(
                font: style.primeFont,
                color: style.primeColor
            )
            leadingCardAdapter.display(style: effectiveLeadingCardStyle)
        }
    }

    private extension CardViewPresentableModel.Style {
        func replacingTitleStyle(font: Font, color: Color) -> Self {
            .init(
                backgroundColor: backgroundColor,
                vStacklayoutMargins: vStacklayoutMargins,
                hStacklayoutMargins: hStacklayoutMargins,
                hStackViewDistribution: hStackViewDistribution,
                leadingTitleKeyTextColor: leadingTitleKeyTextColor,
                titleKeyTextColor: color,
                trailingTitleKeyTextColor: trailingTitleKeyTextColor,
                titleValueTextColor: titleValueTextColor,
                subTitleTextColor: subTitleTextColor,
                leadingTitleKeyLabelFont: leadingTitleKeyLabelFont,
                titleKeyLabelFont: font,
                trailingTitleKeyLabelFont: trailingTitleKeyLabelFont,
                titleValueLabelFont: titleValueLabelFont,
                subTitleLabelFont: subTitleLabelFont,
                subtitleNumberOfLines: subtitleNumberOfLines,
                cornerStyle: cornerStyle,
                stackSpace: stackSpace,
                hStackViewSpacing: hStackViewSpacing,
                titleKeyNumberOfLines: titleKeyNumberOfLines,
                titleValueNumberOfLines: titleValueNumberOfLines,
                borderColor: borderColor,
                borderWidth: borderWidth,
                gradientBorderColors: gradientBorderColors,
                trailingImageLeadingSpacing: trailingImageLeadingSpacing,
                secondaryTrailingImageLeadingSpacing: secondaryTrailingImageLeadingSpacing
            )
        }
    }
#endif
