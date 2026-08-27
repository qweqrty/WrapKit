import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine

final class SUICardViewStateModel: ObservableObject {
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
    @Published var bottomSeparator: CardViewPresentableModel.BottomSeparator?
    @Published var switchControl: SwitchControlPresentableModel?
    @Published var onPress: (() -> Void)?
    @Published var onLongPress: (() -> Void)?
    @Published var isUserInteractionEnabled: Bool = true
    @Published private(set) var activeGradientBorderColors: [Color]?
    @Published private(set) var trailingImageLeadingSpacing: CGFloat?
    @Published private(set) var secondaryTrailingImageLeadingSpacing: CGFloat?

    let backgroundImageAdapter = ImageViewOutputSwiftUIAdapter()
    let leadingImageAdapter = ImageViewOutputSwiftUIAdapter()
    let secondaryLeadingImageAdapter = ImageViewOutputSwiftUIAdapter()
    let trailingImageAdapter = ImageViewOutputSwiftUIAdapter()
    let secondaryTrailingImageAdapter = ImageViewOutputSwiftUIAdapter()
    let leadingTitlesAdapter = KeyValueFieldViewOutputSwiftUIAdapter()
    let titleViewsAdapter = KeyValueFieldViewOutputSwiftUIAdapter()
    let trailingTitlesAdapter = KeyValueFieldViewOutputSwiftUIAdapter()
    let switchControlAdapter = SwitchCotrolOutputSwiftUIAdapter()

    private var retainedBackgroundImage = ImageViewPresentableModel()
    private var cancellables: Set<AnyCancellable> = []

    init(adapter: CardViewOutputSwiftUIAdapter) {
        adapter.$displayModelState
            .sink { [weak self] state in
                guard let state else { return }
                self?.apply(model: state.model)
            }
            .store(in: &cancellables)

        adapter.$displayStyleState
            .sink { [weak self] state in
                guard let state, let style = state.style else { return }
                self?.style = style
            }
            .store(in: &cancellables)

        adapter.$displayBackgroundImageState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setBackgroundImage(state.backgroundImage)
            }
            .store(in: &cancellables)

        adapter.$displayTitleState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setTitle(state.title)
            }
            .store(in: &cancellables)

        adapter.$displayLeadingTitlesState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setLeadingTitles(state.leadingTitles)
            }
            .store(in: &cancellables)

        adapter.$displayTrailingTitlesState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setTrailingTitles(state.trailingTitles)
            }
            .store(in: &cancellables)

        adapter.$displayLeadingImageState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setLeadingImage(state.leadingImage)
            }
            .store(in: &cancellables)

        adapter.$displaySecondaryLeadingImageState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setSecondaryLeadingImage(state.secondaryLeadingImage)
            }
            .store(in: &cancellables)

        adapter.$displayTrailingImageState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setTrailingImage(state.trailingImage)
            }
            .store(in: &cancellables)

        adapter.$displaySecondaryTrailingImageState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setSecondaryTrailingImage(state.secondaryTrailingImage)
            }
            .store(in: &cancellables)

        adapter.$displaySubTitleState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setSubTitle(state.subTitle)
            }
            .store(in: &cancellables)

        adapter.$displayValueTitleState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setValueTitle(state.valueTitle)
            }
            .store(in: &cancellables)

        adapter.$displayBottomSeparatorState
            .sink { [weak self] state in
                guard let state else { return }
                self?.bottomSeparator = state.bottomSeparator
            }
            .store(in: &cancellables)

        adapter.$displaySwitchControlState
            .sink { [weak self] state in
                guard let state else { return }
                self?.setSwitchControl(state.switchControl)
            }
            .store(in: &cancellables)

        adapter.$displayOnPressState
            .sink { [weak self] state in
                guard let state else { return }
                self?.onPress = state.onPress
            }
            .store(in: &cancellables)

        adapter.$displayOnLongPressState
            .sink { [weak self] state in
                guard let state else { return }
                self?.onLongPress = state.onLongPress
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .sink { [weak self] state in
                guard let state else { return }
                self?.isHidden = state.isHidden
            }
            .store(in: &cancellables)

        adapter.$displayIsUserInteractionEnabledState
            .sink { [weak self] state in
                guard let state, let isEnabled = state.isUserInteractionEnabled else { return }
                self?.isUserInteractionEnabled = isEnabled
            }
            .store(in: &cancellables)

        adapter.$displayIsGradientBorderEnabledState
            .sink { [weak self] state in
                guard let state else { return }
                self?.applyGradientBorder(isEnabled: state.isGradientBorderEnabled)
            }
            .store(in: &cancellables)

        syncAdapters()
    }

    private func apply(model: CardViewPresentableModel?) {
        isHidden = model == nil
        accessibilityIdentifier = model?.accessibilityIdentifier
        accessibilityLabel = model?.accessibility?.label
        accessibilityHint = model?.accessibility?.hint
        guard let model else { return }

        if let style = model.style {
            self.style = style
        }

        setBackgroundImage(model.backgroundImage)
        setTitle(model.title)
        setLeadingTitles(model.leadingTitles)
        setTrailingTitles(model.trailingTitles)
        setLeadingImage(model.leadingImage)
        setSecondaryLeadingImage(model.secondaryLeadingImage)
        setTrailingImage(model.trailingImage)
        setSecondaryTrailingImage(model.secondaryTrailingImage)
        setSubTitle(model.subTitle)
        setValueTitle(model.valueTitle)
        bottomSeparator = model.bottomSeparator
        setSwitchControl(model.switchControl)
        onPress = model.onPress
        onLongPress = model.onLongPress
        if let isUserInteractionEnabled = model.isUserInteractionEnabled {
            self.isUserInteractionEnabled = isUserInteractionEnabled
        }
        applyGradientBorder(isEnabled: model.isGradientBorderEnabled)
    }

    private func setBackgroundImage(_ model: ImageViewPresentableModel?) {
        guard let model else {
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
    }

    private func setSwitchControl(_ model: SwitchControlPresentableModel?) {
        switchControl = model
        switchControlAdapter.display(model: model)
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

    private func normalizeIconImageModel(_ model: ImageViewPresentableModel?) -> ImageViewPresentableModel? {
        guard let model else { return nil }

        let resolvedSize: CGSize? = {
            if let size = model.size {
                return size
            }
            if case .asset(let image) = model.image {
                return image?.size
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
            alpha: model.alpha,
            systemSymbolName: model.systemSymbolName
        )
    }

    private func syncAdapters() {
        setBackgroundImage(backgroundImage)
        setLeadingTitles(leadingTitles)
        setTrailingTitles(trailingTitles)
        setLeadingImage(leadingImage)
        setSecondaryLeadingImage(secondaryLeadingImage)
        setTrailingImage(trailingImage)
        setSecondaryTrailingImage(secondaryTrailingImage)
        setSubTitle(subTitle)
        setValueTitle(valueTitle)
        setSwitchControl(switchControl)
    }
}

#endif
