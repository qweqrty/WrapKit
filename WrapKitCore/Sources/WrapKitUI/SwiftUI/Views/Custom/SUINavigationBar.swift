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
        if #available(iOS 26, *), isLiquidGlassEnabled {
            return 16
        }
        return 8
    }

    @ViewBuilder
    private func leadingSection(model: HeaderPresentableModel) -> some View {
        if let leadingCard = model.leadingCard {
            if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *),
               isLiquidGlassEnabled,
               leadingCard.onPress != nil || leadingCard.onLongPress != nil {
                SUICardView(adapter: stateModel.leadingCardAdapter)
                    .frame(maxHeight: 44, alignment: .leading)
                    .glassEffect(
                        .regular.interactive(),
                        in: SUICornerShape(style: .automatic)
                    )
            } else {
                SUICardView(adapter: stateModel.leadingCardAdapter)
                    .frame(maxHeight: 44, alignment: .leading)
            }
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
                    SUIImageViewView(model: imageModel)
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

    @ViewBuilder
    var body: some View {
        if let model {
            if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *), isLiquidGlassEnabled {
                button(model)
                    .wrapKitGlassButtonStyle(
                        model.style?.glassConfiguration ?? .glass,
                        tint: model.style?.backgroundColor.map(SwiftUIColor.init),
                        cornerStyle: .automatic
                    )
                    .overlay(buttonBorder(model.style, cornerStyle: .automatic))
            } else {
                button(model)
                    .buttonStyle(.plain)
                    .background(SwiftUIColor(model.style?.backgroundColor ?? .clear))
                    .cornerStyle(model.style?.cornerStyle ?? .none)
                    .overlay(buttonBorder(model.style, cornerStyle: model.style?.cornerStyle ?? .none))
            }
        }
    }

    private func button(_ model: ButtonPresentableModel) -> some View {
        SwiftUI.Button {
            model.onPress?()
        } label: {
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
            .frame(width: model.width, height: model.height)
        }
        .disabled(!(model.enabled ?? true))
        .opacity((model.enabled ?? true) ? 1 : 0.5)
        .accessibilityIdentifier(model.accessibilityIdentifier ?? "")
    }

    @ViewBuilder
    private func buttonBorder(_ style: ButtonStyle?, cornerStyle: CornerStyle) -> some View {
        if let borderColor = style?.borderColor,
           (style?.borderWidth ?? 0) > 0 {
            SUICornerShape(style: cornerStyle)
                .stroke(
                    SwiftUIColor(borderColor),
                    lineWidth: style?.borderWidth ?? 0
                )
        }
    }
}
#endif
