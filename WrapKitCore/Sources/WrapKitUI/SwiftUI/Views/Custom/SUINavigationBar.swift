import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUINavigationBar: View {
    @StateObject private var stateModel: SUINavigationBarStateModel
    @State private var leadingWidth: CGFloat = 0
    @State private var trailingWidth: CGFloat = 0

    public init(adapter: HeaderOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        if !stateModel.isHidden {
            let model = stateModel.model
            let style = model.style ?? SUINavigationBarStateModel.defaultStyle
            let sideWidth = max(leadingWidth, trailingWidth)
            HStack(spacing: 8) {
                leadingSection(model: model)
                    .measureWidth(LeadingWidthPreferenceKey.self)
                    .frame(width: sideWidth, alignment: .leading)

                centerSection(model: model, style: style)
                    .frame(maxWidth: .infinity, alignment: .center)

                trailingSection(model: model, style: style)
                    .measureWidth(TrailingWidthPreferenceKey.self)
                    .frame(width: sideWidth, alignment: .trailing)
            }
            .frame(height: 44)
            .padding(.top, 4)
            .padding(.bottom, 8)
            .padding(.horizontal, horizontalPadding)
            .background(SwiftUIColor(style.backgroundColor))
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
    private func leadingSection(model: HeaderPresentableModel) -> some View {
        if model.leadingCard != nil {
            SUICardView(adapter: stateModel.leadingCardAdapter)
                .frame(maxHeight: 44, alignment: .leading)
        }
    }

    @ViewBuilder
    private func centerSection(model: HeaderPresentableModel, style: HeaderPresentableModel.Style) -> some View {
        switch model.centerView {
        case .keyValue(let pair):
            VStack(spacing: 0) {
                if let keyModel = pair.first {
                    SUILabelView(
                        model: keyModel,
                        font: style.primeFont,
                        textColor: style.primeColor,
                        textAlignment: .center
                    )
                    .lineLimit(lineLimit(from: style))
                }

                if let valueModel = pair.second {
                    SUILabelView(
                        model: valueModel,
                        font: style.secondaryFont,
                        textColor: style.secondaryColor,
                        textAlignment: .center
                    )
                    .lineLimit(lineLimit(from: style))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        case .titledImage(let pair):
            HStack(spacing: 8) {
                if let imageModel = pair.first {
                    SUINavigationBarCenterImageView(model: imageModel)
                        .frame(maxWidth: 24, maxHeight: 24)
                }

                if let titleModel = pair.second {
                    SUILabelView(
                        model: titleModel,
                        font: style.secondaryFont,
                        textColor: style.secondaryColor,
                        textAlignment: .center
                    )
                    .lineLimit(lineLimit(from: style))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        case .none:
            SwiftUICore.EmptyView()
        }
    }

    private func lineLimit(from style: HeaderPresentableModel.Style) -> Int? {
        style.numberOfLines == 0 ? nil : style.numberOfLines
    }

    @ViewBuilder
    private func trailingSection(model: HeaderPresentableModel, style: HeaderPresentableModel.Style) -> some View {
        HStack(spacing: max(style.horizontalSpacing * 1.5, 0)) {
            SUINavigationBarButtonView(model: model.primeTrailingImage, tintColor: style.primeColor)
            SUINavigationBarButtonView(model: model.secondaryTrailingImage, tintColor: style.primeColor)
            SUINavigationBarButtonView(model: model.tertiaryTrailingImage, tintColor: style.primeColor)
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
            .ifLet(model.style?.backgroundColor) { view, color in
                view.background(SwiftUIColor(color))
            }
            .clipShape(RoundedRectangle(cornerRadius: model.style?.cornerRadius ?? 0, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: model.style?.cornerRadius ?? 0, style: .continuous)
                    .stroke(
                        SwiftUIColor(model.style?.borderColor ?? .clear),
                        lineWidth: model.style?.borderWidth ?? 0
                    )
            )
            .opacity((model.enabled ?? true) ? 1 : 0.5)
            .allowsHitTesting(model.enabled ?? true)
            .onTapGesture {
                model.onPress?()
            }
        }
    }
}

private struct SUINavigationBarCenterImageView: View {
    let model: ImageViewPresentableModel

    @ViewBuilder
    var body: some View {
        Group {
            switch model.image {
            case .asset(let image):
                if let image {
                    SwiftUIImage(image: image)
                        .resizable()
                }
            case .data(let data):
                if let data, let image = Image(data: data) {
                    SwiftUIImage(image: image)
                        .resizable()
                }
            case .url, .urlString, .none:
                SwiftUICore.EmptyView()
            }
        }
        .aspectRatio(contentMode: model.contentModeIsFit ?? true ? .fit : .fill)
        .opacity(model.alpha ?? 1)
    }
}
#endif
