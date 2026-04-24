import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine
#if canImport(QuartzCore)
import QuartzCore
#endif

public struct SUICardView: View {
    @StateObject private var stateModel: SUICardViewStateModel

    public init(adapter: CardViewOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        if !stateModel.isHidden {
            content
                .accessibilityIdentifier(stateModel.accessibilityIdentifier ?? "")
        }
    }

    @ViewBuilder
    private var content: some View {
        let style = stateModel.style
        ZStack {
            backgroundImageView
            VStack(spacing: 0) {
                cardContent(style: style)
                bottomSeparator
            }
            .padding(style.vStacklayoutMargins.asSUIEdgeInsets)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(SwiftUIColor(style.backgroundColor))
        .clipShape(CardRoundedRectangle(radius: style.cornerRadius, corners: style.roundedCorners))
        .overlay(CardBorderOverlay(style: style))
        .contentShape(Rectangle())
        .allowsHitTesting(stateModel.isUserInteractionEnabled)
        .onTapGesture {
            stateModel.onPress?()
        }
        .onLongPressGesture(minimumDuration: 1) {
            stateModel.onLongPress?()
        }
    }

    @ViewBuilder
    private var backgroundImageView: some View {
        if let backgroundImage = stateModel.backgroundImage {
            GeometryReader { proxy in
                SUIImageView(adapter: stateModel.backgroundImageAdapter)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                    .opacity(backgroundImage.alpha ?? 1)
                    .clipped()
            }
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func cardContent(style: CardViewPresentableModel.Style) -> some View {
        HStack(spacing: style.hStackViewSpacing) {
            arrangedContainer(style: style) {
                leadingTitlesView(style: style)
            }
            arrangedContainer(style: style) {
                imageView(stateModel.leadingImage, adapter: stateModel.leadingImageAdapter)
            }
            arrangedContainer(style: style) {
                imageView(stateModel.secondaryLeadingImage, adapter: stateModel.secondaryLeadingImageAdapter)
            }
            arrangedContainer(style: style) {
                titleBlockView(style: style)
            }
            arrangedContainer(style: style) {
                subTitleView(style: style)
            }
            arrangedContainer(style: style) {
                imageView(stateModel.secondaryTrailingImage, adapter: stateModel.secondaryTrailingImageAdapter)
            }
            arrangedContainer(style: style, leadingSpacing: style.trailingImageLeadingSpacing) {
                imageView(stateModel.trailingImage, adapter: stateModel.trailingImageAdapter)
            }
            arrangedContainer(style: style, leadingSpacing: style.secondaryTrailingImageLeadingSpacing) {
                switchView
            }
            arrangedContainer(style: style) {
                trailingTitlesView(style: style)
            }
        }
        .padding(style.hStacklayoutMargins.asSUIEdgeInsets)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func arrangedContainer(
        style: CardViewPresentableModel.Style,
        leadingSpacing: CGFloat? = nil,
        @ViewBuilder content: () -> some View
    ) -> some View {
        let inner = content()
        switch style.hStackViewDistribution {
        case .fillEqually:
            inner
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.leading, leadingSpacing ?? 0)
        case .equalSpacing, .equalCentering:
            inner
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.leading, leadingSpacing ?? 0)
                .padding(.horizontal, 2)
        default:
            inner
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.leading, leadingSpacing ?? 0)
        }
    }

    @ViewBuilder
    private func leadingTitlesView(style: CardViewPresentableModel.Style) -> some View {
        if let leadingTitles = stateModel.leadingTitles {
            VStack(spacing: 0) {
                styledLabel(
                    leadingTitles.first,
                    adapter: stateModel.leadingTitleFirstAdapter,
                    font: style.leadingTitleKeyLabelFont,
                    color: style.leadingTitleKeyTextColor,
                    numberOfLines: style.titleKeyNumberOfLines,
                    alignment: .center
                )
                styledLabel(
                    leadingTitles.second,
                    adapter: stateModel.leadingTitleSecondAdapter,
                    font: style.leadingTitleKeyLabelFont,
                    color: style.leadingTitleKeyTextColor,
                    numberOfLines: style.titleValueNumberOfLines,
                    alignment: .center
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func trailingTitlesView(style: CardViewPresentableModel.Style) -> some View {
        if let trailingTitles = stateModel.trailingTitles {
            VStack(spacing: 0) {
                styledLabel(
                    trailingTitles.first,
                    adapter: stateModel.trailingTitleFirstAdapter,
                    font: style.trailingTitleKeyLabelFont,
                    color: style.trailingTitleKeyTextColor,
                    numberOfLines: style.titleKeyNumberOfLines,
                    alignment: .center
                )
                styledLabel(
                    trailingTitles.second,
                    adapter: stateModel.trailingTitleSecondAdapter,
                    font: style.trailingTitleKeyLabelFont,
                    color: style.trailingTitleKeyTextColor,
                    numberOfLines: style.titleValueNumberOfLines,
                    alignment: .center
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func titleBlockView(style: CardViewPresentableModel.Style) -> some View {
        if isVisibleTextModel(stateModel.title) || isVisibleTextModel(stateModel.valueTitle) {
            VStack(alignment: .leading, spacing: style.stackSpace) {
                styledLabel(
                    stateModel.title,
                    adapter: stateModel.titleAdapter,
                    font: style.titleKeyLabelFont,
                    color: style.titleKeyTextColor,
                    numberOfLines: style.titleKeyNumberOfLines,
                    alignment: .leading
                )
                styledLabel(
                    stateModel.valueTitle,
                    adapter: stateModel.valueTitleAdapter,
                    font: style.titleValueLabelFont,
                    color: style.titleValueTextColor,
                    numberOfLines: style.titleValueNumberOfLines,
                    alignment: .leading
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func subTitleView(style: CardViewPresentableModel.Style) -> some View {
        if isVisibleTextModel(stateModel.subTitle) {
            styledLabel(
                stateModel.subTitle,
                adapter: stateModel.subTitleAdapter,
                font: style.subTitleLabelFont,
                color: style.subTitleTextColor,
                numberOfLines: style.subtitleNumberOfLines,
                alignment: .leading
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func styledLabel(
        _ model: TextOutputPresentableModel?,
        adapter: TextOutputSwiftUIAdapter,
        font: Font,
        color: Color,
        numberOfLines: Int,
        alignment: SwiftUI.Alignment
    ) -> some View {
        if model != nil {
            SUILabel(
                adapter: adapter,
                font: font,
                textColor: color,
                textAlignment: textAlignment(from: alignment)
            )
            .lineLimit(numberOfLines == 0 ? nil : numberOfLines)
            .frame(maxWidth: CGFloat.infinity, alignment: alignment)
        }
    }

    private func textAlignment(from alignment: SwiftUI.Alignment) -> TextAlignment {
        switch alignment {
        case .leading:
            return .left
        case .trailing:
            return .right
        default:
            return .center
        }
    }

    @ViewBuilder
    private func imageView(_ model: ImageViewPresentableModel?, adapter: ImageViewOutputSwiftUIAdapter) -> some View {
        if model != nil {
            SUIImageView(adapter: adapter)
                .accentColor(SwiftUIColor.black)
        }
    }

    @ViewBuilder
    private var switchView: some View {
        if let model = stateModel.switchControl {
            SUISwitchControlView(model: model)
        }
    }

    @ViewBuilder
    private var bottomSeparator: some View {
        if let separator = stateModel.bottomSeparator {
            SwiftUIColor(separator.color)
                .frame(height: separator.height)
                .padding(separator.padding.asSUIEdgeInsets)
        }
    }

    private func isVisibleTextModel(_ model: TextOutputPresentableModel?) -> Bool {
        guard let model else { return false }
        return isVisibleTextModel(model.model)
    }

    private func isVisibleTextModel(_ model: TextOutputPresentableModel.TextModel?) -> Bool {
        guard let model else { return false }

        switch model {
        case .text(let text):
            return !(text?.isEmpty ?? true)
        case .attributes(let attrs):
            return !attrs.isEmpty
        case .textStyled(let wrapped, _, _, _, _):
            return isVisibleTextModel(wrapped)
        case .animated, .animatedDecimal:
            return true
        case .attributedString(let html, _):
            return !(html?.isEmpty ?? true)
        }
    }
}

private struct CardBorderOverlay: View {
    let style: CardViewPresentableModel.Style

    var body: some View {
        Group {
            if let borderColor = style.borderColor,
               let borderWidth = style.borderWidth {
                CardRoundedRectangle(radius: style.cornerRadius, corners: style.roundedCorners)
                    .stroke(SwiftUIColor(borderColor), lineWidth: borderWidth)
            } else {
                SwiftUICore.EmptyView()
            }
        }
    }
}

private final class SUICardViewStateModel: ObservableObject {
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

    let titleAdapter = TextOutputSwiftUIAdapter()
    let valueTitleAdapter = TextOutputSwiftUIAdapter()
    let subTitleAdapter = TextOutputSwiftUIAdapter()
    let leadingTitleFirstAdapter = TextOutputSwiftUIAdapter()
    let leadingTitleSecondAdapter = TextOutputSwiftUIAdapter()
    let trailingTitleFirstAdapter = TextOutputSwiftUIAdapter()
    let trailingTitleSecondAdapter = TextOutputSwiftUIAdapter()

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
        titleAdapter.display(model: model)
    }

    private func setValueTitle(_ model: TextOutputPresentableModel?) {
        valueTitle = model
        valueTitleAdapter.display(model: model)
    }

    private func setSubTitle(_ model: TextOutputPresentableModel?) {
        subTitle = model
        subTitleAdapter.display(model: model)
    }

    private func setLeadingTitles(_ model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        leadingTitles = model
        leadingTitleFirstAdapter.display(model: model?.first)
        leadingTitleSecondAdapter.display(model: model?.second)
    }

    private func setTrailingTitles(_ model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        trailingTitles = model
        trailingTitleFirstAdapter.display(model: model?.first)
        trailingTitleSecondAdapter.display(model: model?.second)
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

    private func normalizeImageModel(_ model: ImageViewPresentableModel?) -> ImageViewPresentableModel? {
        guard let model else { return nil }
        guard model.contentModeIsFit == nil else { return model }

        return .init(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            size: model.size,
            image: model.image,
            onPress: model.onPress,
            onLongPress: model.onLongPress,
            contentModeIsFit: true,
            borderWidth: model.borderWidth,
            borderColor: model.borderColor,
            cornerRadius: model.cornerRadius,
            alpha: model.alpha
        )
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

private struct SUISwitchControlView: View {
    let model: SwitchControlPresentableModel

    var body: some View {
        let style = model.style
        let isOn = model.isOn ?? false
        let trackColor = isOn ? SwiftUIColor(style?.tintColor ?? .systemGreen) : SwiftUIColor(style?.backgroundColor ?? .systemGray4)
        let thumbColor = SwiftUIColor(style?.thumbTintColor ?? .white)
        let height: CGFloat = 31
        let width: CGFloat = 51
        let knobSize: CGFloat = 27

        ZStack(alignment: isOn ? .trailing : .leading) {
            RoundedRectangle(cornerRadius: style?.cornerRadius ?? (height / 2), style: .continuous)
                .fill(trackColor)
            Circle()
                .fill(thumbColor)
                .frame(width: knobSize, height: knobSize)
                .padding(2)
        }
        .frame(width: width, height: height)
        .opacity((model.isEnabled ?? true) ? 1 : 0.5)
    }
}

private struct CardRoundedRectangle: Shape {
    let radius: CGFloat
    let corners: CACornerMask

    func path(in rect: CGRect) -> Path {
        guard radius > 0 else {
            return Path(CGRect(origin: .zero, size: rect.size))
        }

        let topLeft = corners.contains(.layerMinXMinYCorner)
        let topRight = corners.contains(.layerMaxXMinYCorner)
        let bottomLeft = corners.contains(.layerMinXMaxYCorner)
        let bottomRight = corners.contains(.layerMaxXMaxYCorner)

        let tl = topLeft ? radius : 0
        let tr = topRight ? radius : 0
        let bl = bottomLeft ? radius : 0
        let br = bottomRight ? radius : 0

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))

        if tr > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                radius: tr,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))

        if br > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                radius: br,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
        }

        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))

        if bl > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                radius: bl,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
        }

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))

        if tl > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                radius: tl,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
        }

        path.closeSubpath()
        return path
    }
}

#endif
