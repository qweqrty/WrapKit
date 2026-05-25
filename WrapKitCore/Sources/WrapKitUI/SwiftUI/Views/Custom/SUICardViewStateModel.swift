import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine

final class SUICardViewStateModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var accessibilityIdentifier: String?
    @Published var style: CardViewPresentableModel.Style = .init(
        backgroundColor: .clear,
        vStacklayoutMargins: .zero,
        hStacklayoutMargins: .zero,
        hStackViewDistribution: .fill,
        leadingTitleKeyTextColor: .label,
        titleKeyTextColor: .label,
        trailingTitleKeyTextColor: .label,
        titleValueTextColor: .label,
        subTitleTextColor: .secondaryLabel,
        leadingTitleKeyLabelFont: .systemFont(ofSize: 16),
        titleKeyLabelFont: .systemFont(ofSize: 16),
        trailingTitleKeyLabelFont: .systemFont(ofSize: 16),
        titleValueLabelFont: .systemFont(ofSize: 16),
        subTitleLabelFont: .systemFont(ofSize: 16),
        cornerRadius: 0,
        stackSpace: 0,
        hStackViewSpacing: 0,
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

    let backgroundImageAdapter = ImageViewOutputSwiftUIAdapter()
    let leadingImageAdapter = ImageViewOutputSwiftUIAdapter()
    let secondaryLeadingImageAdapter = ImageViewOutputSwiftUIAdapter()
    let trailingImageAdapter = ImageViewOutputSwiftUIAdapter()
    let secondaryTrailingImageAdapter = ImageViewOutputSwiftUIAdapter()

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
                self?.switchControl = state.switchControl
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
                guard let state else { return }
                self?.isUserInteractionEnabled = state.isUserInteractionEnabled ?? true
            }
            .store(in: &cancellables)

        syncAdapters()
    }

    private func apply(model: CardViewPresentableModel?) {
        isHidden = model == nil
        guard let model else {
            clearContent()
            return
        }

        accessibilityIdentifier = model.accessibilityIdentifier

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
        switchControl = model.switchControl
        onPress = model.onPress
        onLongPress = model.onLongPress
        isUserInteractionEnabled = model.isUserInteractionEnabled ?? true
    }

    private func setBackgroundImage(_ model: ImageViewPresentableModel?) {
        backgroundImage = normalizeBackgroundImageModel(model)
        backgroundImageAdapter.display(model: backgroundImage)
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
    }

    private func setSecondaryTrailingImage(_ model: ImageViewPresentableModel?) {
        secondaryTrailingImage = normalizeIconImageModel(model)
        secondaryTrailingImageAdapter.display(model: secondaryTrailingImage)
    }

    private func setTitle(_ model: TextOutputPresentableModel?) {
        title = model
    }

    private func setValueTitle(_ model: TextOutputPresentableModel?) {
        valueTitle = model
    }

    private func setSubTitle(_ model: TextOutputPresentableModel?) {
        subTitle = model
    }

    private func setLeadingTitles(_ model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        leadingTitles = model
    }

    private func setTrailingTitles(_ model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        trailingTitles = model
    }

    private func clearContent() {
        setBackgroundImage(nil)
        setTitle(nil)
        setLeadingTitles(nil)
        setTrailingTitles(nil)
        setLeadingImage(nil)
        setSecondaryLeadingImage(nil)
        setTrailingImage(nil)
        setSecondaryTrailingImage(nil)
        setSubTitle(nil)
        setValueTitle(nil)
        bottomSeparator = nil
        switchControl = nil
        onPress = nil
        onLongPress = nil
    }

    private func normalizeBackgroundImageModel(_ model: ImageViewPresentableModel?) -> ImageViewPresentableModel? {
        guard let model else { return nil }

        return .init(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            size: nil,
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
            alpha: model.alpha
        )
    }

    private func syncAdapters() {
        setBackgroundImage(backgroundImage)
        setTitle(title)
        setLeadingTitles(leadingTitles)
        setTrailingTitles(trailingTitles)
        setLeadingImage(leadingImage)
        setSecondaryLeadingImage(secondaryLeadingImage)
        setTrailingImage(trailingImage)
        setSecondaryTrailingImage(secondaryTrailingImage)
        setSubTitle(subTitle)
        setValueTitle(valueTitle)
    }
}

#endif
