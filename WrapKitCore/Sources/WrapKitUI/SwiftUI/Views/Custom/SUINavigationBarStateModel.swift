import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine

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

    let primeTrailingButtonStateModel: SUIButtonStateModel
    let secondaryTrailingButtonStateModel: SUIButtonStateModel
    let tertiaryTrailingButtonStateModel: SUIButtonStateModel

    private var effectiveLeadingCardStyle = SUINavigationBarStateModel.defaultLeadingCardStyle
    private var cancellables: Set<AnyCancellable> = []

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
        let leadingCardAdapter = CardViewOutputSwiftUIAdapter()
        let primeTrailingButtonAdapter = ButtonOutputSwiftUIAdapter()
        let secondaryTrailingButtonAdapter = ButtonOutputSwiftUIAdapter()
        let tertiaryTrailingButtonAdapter = ButtonOutputSwiftUIAdapter()

        self.leadingCardAdapter = leadingCardAdapter
        self.primeTrailingButtonAdapter = primeTrailingButtonAdapter
        self.secondaryTrailingButtonAdapter = secondaryTrailingButtonAdapter
        self.tertiaryTrailingButtonAdapter = tertiaryTrailingButtonAdapter
        self.primeTrailingButtonStateModel = SUIButtonStateModel(adapter: primeTrailingButtonAdapter)
        self.secondaryTrailingButtonStateModel = SUIButtonStateModel(adapter: secondaryTrailingButtonAdapter)
        self.tertiaryTrailingButtonStateModel = SUIButtonStateModel(adapter: tertiaryTrailingButtonAdapter)
        leadingCardAdapter.display(style: effectiveLeadingCardStyle)

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.setModel(state.model)
            }
            .store(in: &cancellables)

        adapter.$displayStyleState
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let style = state.style else { return }
                guard let self else { return }
                self.updateModel { current in
                    HeaderPresentableModel(
                        style: style,
                        centerView: current.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
                self.applyHeaderStyleToLeadingCard(style)
            }
            .store(in: &cancellables)

        adapter.$displayCenterViewState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: state.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
            }
            .store(in: &cancellables)

        adapter.$displayLeadingCardState
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                self.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: current.centerView,
                        leadingCard: state.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
                self.syncLeadingCardAdapter()
            }
            .store(in: &cancellables)

        adapter.$displayPrimeTrailingImageState
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                self.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: current.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: state.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
                self.primeTrailingButtonAdapter.display(model: state.primeTrailingImage)
            }
            .store(in: &cancellables)

        adapter.$displaySecondaryTrailingImageState
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                self.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: current.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: state.secondaryTrailingImage,
                        tertiaryTrailingImage: current.tertiaryTrailingImage
                    )
                }
                self.secondaryTrailingButtonAdapter.display(model: state.secondaryTrailingImage)
            }
            .store(in: &cancellables)

        adapter.$displayTertiaryTrailingImageState
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                self.updateModel { current in
                    HeaderPresentableModel(
                        style: current.style,
                        centerView: current.centerView,
                        leadingCard: current.leadingCard,
                        primeTrailingImage: current.primeTrailingImage,
                        secondaryTrailingImage: current.secondaryTrailingImage,
                        tertiaryTrailingImage: state.tertiaryTrailingImage
                    )
                }
                self.tertiaryTrailingButtonAdapter.display(model: state.tertiaryTrailingImage)
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.isHidden = state.isHidden
            }
            .store(in: &cancellables)

    }

    private func setModel(_ model: HeaderPresentableModel?) {
        isHidden = model == nil
        guard let model else { return }

        if let style = model.style {
            applyHeaderStyleToLeadingCard(style)
        }

        self.model = .init(
            style: model.style ?? self.model.style ?? Self.defaultStyle,
            centerView: model.centerView,
            leadingCard: model.leadingCard,
            primeTrailingImage: model.primeTrailingImage,
            secondaryTrailingImage: model.secondaryTrailingImage,
            tertiaryTrailingImage: model.tertiaryTrailingImage
        )
        syncChildAdapters()
    }

    private func updateModel(_ transform: (HeaderPresentableModel) -> HeaderPresentableModel) {
        model = transform(model)
    }

    private func syncLeadingCardAdapter() {
        leadingCardAdapter.display(model: model.leadingCard)
        if let style = model.leadingCard?.style {
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

    private func syncChildAdapters() {
        syncLeadingCardAdapter()
        primeTrailingButtonAdapter.display(model: model.primeTrailingImage)
        secondaryTrailingButtonAdapter.display(model: model.secondaryTrailingImage)
        tertiaryTrailingButtonAdapter.display(model: model.tertiaryTrailingImage)
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
