import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine

public struct SUINavigationBar: View {
    @StateObject private var stateModel: SUINavigationBarStateModel
    @State private var leadingWidth: CGFloat = 0
    @State private var trailingWidth: CGFloat = 0

    public init(adapter: HeaderOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        if !stateModel.isHidden {
            let sideWidth = max(leadingWidth, trailingWidth)
            HStack(spacing: 8) {
                leadingSection
                    .measureWidth(LeadingWidthPreferenceKey.self)
                    .frame(width: sideWidth, alignment: .leading)

                centerSection
                    .frame(maxWidth: .infinity, alignment: .center)

                trailingSection
                    .measureWidth(TrailingWidthPreferenceKey.self)
                    .frame(width: sideWidth, alignment: .trailing)
            }
            .frame(height: 44)
            .padding(.top, 4)
            .padding(.bottom, 8)
            .padding(.horizontal, horizontalPadding)
            .background(SwiftUIColor(stateModel.style.backgroundColor))
            .onPreferenceChange(LeadingWidthPreferenceKey.self) { leadingWidth = $0 }
            .onPreferenceChange(TrailingWidthPreferenceKey.self) { trailingWidth = $0 }
        }
    }

    private var horizontalPadding: CGFloat {
        if #available(iOS 26, *) {
            return 16
        }
        return 8
    }

    @ViewBuilder
    private var leadingSection: some View {
        if stateModel.leadingCard != nil {
            SUICardView(adapter: stateModel.leadingCardAdapter)
                .frame(maxHeight: 44, alignment: .leading)
        }
    }

    @ViewBuilder
    private var centerSection: some View {
        switch stateModel.centerView {
        case .keyValue(let pair):
            VStack(spacing: 0) {
                if pair.first != nil {
                    SUILabel(
                        adapter: stateModel.centerKeyAdapter,
                        font: stateModel.style.primeFont,
                        textColor: stateModel.style.primeColor,
                        textAlignment: .center
                    )
                    .lineLimit(lineLimit)
                }

                if pair.second != nil {
                    SUILabel(
                        adapter: stateModel.centerValueAdapter,
                        font: stateModel.style.secondaryFont,
                        textColor: stateModel.style.secondaryColor,
                        textAlignment: .center
                    )
                    .lineLimit(lineLimit)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        case .titledImage(let pair):
            HStack(spacing: 8) {
                if pair.first != nil {
                    SUIImageView(adapter: stateModel.centerImageAdapter)
                        .frame(maxWidth: 24, maxHeight: 24)
                }

                if pair.second != nil {
                    SUILabel(
                        adapter: stateModel.centerTitleAdapter,
                        font: stateModel.style.secondaryFont,
                        textColor: stateModel.style.secondaryColor,
                        textAlignment: .center
                    )
                    .lineLimit(lineLimit)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        case .none:
            SwiftUICore.EmptyView()
        }
    }

    private var lineLimit: Int? {
        stateModel.style.numberOfLines == 0 ? nil : stateModel.style.numberOfLines
    }

    @ViewBuilder
    private var trailingSection: some View {
        HStack(spacing: max(stateModel.style.horizontalSpacing * 1.5, 0)) {
            SUINavigationBarButtonView(model: stateModel.primeTrailingImage, tintColor: stateModel.style.primeColor)
            SUINavigationBarButtonView(model: stateModel.secondaryTrailingImage, tintColor: stateModel.style.primeColor)
            SUINavigationBarButtonView(model: stateModel.tertiaryTrailingImage, tintColor: stateModel.style.primeColor)
        }
        .frame(maxHeight: .infinity, alignment: .trailing)
    }
}

private struct LeadingWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct TrailingWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private extension View {
    func measureWidth<Key: PreferenceKey>(_ key: Key.Type) -> some View where Key.Value == CGFloat {
        background(
            GeometryReader { proxy in
                SwiftUICore.Color.clear.preference(key: key, value: proxy.size.width)
            }
        )
    }
}

private struct SUINavigationBarButtonView: View {
    let model: ButtonPresentableModel?
    let tintColor: Color

    var body: some View {
        if let model {
            HStack(spacing: model.spacing ?? 0) {
                if let image = model.image {
                    SwiftUIImage(image: image)
                        .renderingMode(.template)
                }
                if let title = model.title {
                    Text(title.removingPercentEncoding ?? title)
                        .font(model.style?.font.map(SwiftUIFont.init) ?? .body)
                }
            }
            .foregroundColor(SwiftUIColor(model.style?.titleColor ?? tintColor))
            .padding(.horizontal, 0)
            .frame(width: model.width, height: model.height)
            .background(SwiftUIColor(model.style?.backgroundColor ?? .clear))
            .clipShape(RoundedRectangle(cornerRadius: model.style?.cornerRadius ?? 0, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: model.style?.cornerRadius ?? 0, style: .continuous)
                    .stroke(
                        SwiftUIColor(model.style?.borderColor ?? .clear),
                        lineWidth: model.style?.borderWidth ?? 0
                    )
            )
            .contentShape(Rectangle())
            .opacity((model.enabled ?? true) ? 1 : 0.5)
            .allowsHitTesting(model.enabled ?? true)
            .onTapGesture {
                model.onPress?()
            }
        }
    }
}

private final class SUINavigationBarStateModel: ObservableObject {
    @Published var style: HeaderPresentableModel.Style = .init(
        backgroundColor: .clear,
        horizontalSpacing: 12,
        primeFont: .systemFont(ofSize: 18),
        primeColor: .label,
        secondaryFont: .systemFont(ofSize: 14),
        secondaryColor: .secondaryLabel,
        numberOfLines: 1
    )
    @Published var centerView: HeaderPresentableModel.CenterView?
    @Published var leadingCard: CardViewPresentableModel?
    @Published var primeTrailingImage: ButtonPresentableModel?
    @Published var secondaryTrailingImage: ButtonPresentableModel?
    @Published var tertiaryTrailingImage: ButtonPresentableModel?
    @Published var isHidden: Bool = false

    let leadingCardAdapter = CardViewOutputSwiftUIAdapter()
    let centerImageAdapter = ImageViewOutputSwiftUIAdapter()
    let centerTitleAdapter = TextOutputSwiftUIAdapter()
    let centerKeyAdapter = TextOutputSwiftUIAdapter()
    let centerValueAdapter = TextOutputSwiftUIAdapter()

    private var cancellables: Set<AnyCancellable> = []

    init(adapter: HeaderOutputSwiftUIAdapter) {
        adapter.$displayModelState
            .sink { [weak self] state in
                self?.apply(model: state?.model)
            }
            .store(in: &cancellables)

        adapter.$displayStyleState
            .sink { [weak self] state in
                guard let style = state?.style else { return }
                self?.style = style
            }
            .store(in: &cancellables)

        adapter.$displayCenterViewState
            .sink { [weak self] state in
                self?.setCenterView(state?.centerView)
            }
            .store(in: &cancellables)

        adapter.$displayLeadingCardState
            .sink { [weak self] state in
                self?.setLeadingCard(state?.leadingCard)
            }
            .store(in: &cancellables)

        adapter.$displayPrimeTrailingImageState
            .sink { [weak self] state in
                self?.primeTrailingImage = state?.primeTrailingImage
            }
            .store(in: &cancellables)

        adapter.$displaySecondaryTrailingImageState
            .sink { [weak self] state in
                self?.secondaryTrailingImage = state?.secondaryTrailingImage
            }
            .store(in: &cancellables)

        adapter.$displayTertiaryTrailingImageState
            .sink { [weak self] state in
                self?.tertiaryTrailingImage = state?.tertiaryTrailingImage
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .sink { [weak self] state in
                guard let state else { return }
                self?.isHidden = state.isHidden
            }
            .store(in: &cancellables)

        syncAdapters()
    }

    private func apply(model: HeaderPresentableModel?) {
        isHidden = model == nil
        guard let model else {
            style = .init(
                backgroundColor: .clear,
                horizontalSpacing: 12,
                primeFont: .systemFont(ofSize: 18),
                primeColor: .label,
                secondaryFont: .systemFont(ofSize: 14),
                secondaryColor: .secondaryLabel,
                numberOfLines: 1
            )
            setCenterView(nil)
            setLeadingCard(nil)
            primeTrailingImage = nil
            secondaryTrailingImage = nil
            tertiaryTrailingImage = nil
            return
        }

        if let style = model.style {
            self.style = style
        }
        setCenterView(model.centerView)
        setLeadingCard(model.leadingCard)
        primeTrailingImage = model.primeTrailingImage
        secondaryTrailingImage = model.secondaryTrailingImage
        tertiaryTrailingImage = model.tertiaryTrailingImage
    }

    private func setCenterView(_ centerView: HeaderPresentableModel.CenterView?) {
        self.centerView = centerView
        centerImageAdapter.display(model: nil)
        centerTitleAdapter.display(model: nil)
        centerKeyAdapter.display(model: nil)
        centerValueAdapter.display(model: nil)

        switch centerView {
        case .keyValue(let pair):
            centerKeyAdapter.display(model: pair.first)
            centerValueAdapter.display(model: pair.second)
        case .titledImage(let pair):
            centerImageAdapter.display(model: pair.first)
            centerTitleAdapter.display(model: pair.second)
        case .none:
            break
        }
    }

    private func setLeadingCard(_ leadingCard: CardViewPresentableModel?) {
        self.leadingCard = leadingCard
        leadingCardAdapter.display(model: leadingCard)
    }

    private func syncAdapters() {
        setCenterView(centerView)
        setLeadingCard(leadingCard)
    }
}
#endif
