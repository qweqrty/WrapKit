#if canImport(SwiftUI)
import SwiftUI

public struct SUINavigationBar: View {
    @ObservedObject var stateModel: SUINavigationBarStateModel

    private let contentHeight: CGFloat = 44
    private let topSpacing: CGFloat = 4
    private let bottomSpacing: CGFloat = 8

    public init(adapter: HeaderOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }

    @ViewBuilder
    public var body: some View {
        if stateModel.isHidden {
            SwiftUI.EmptyView()
        } else {
            navigationBarChrome
        }
    }

    private var navigationBarChrome: some View {
        chromeContent
            .background(
                SwiftUIColor(stateModel.style?.backgroundColor ?? .clear)
                    .ignoresSafeArea(edges: .top)
            )
    }

    @ViewBuilder
    private var chromeContent: some View {
        let content = ZStack(alignment: .top) {
            HStack(spacing: 0) {
                leadingColumn
                SwiftUI.Spacer(minLength: 0)
                trailingColumn
            }
            .frame(height: contentHeight, alignment: .center)
            .padding(.horizontal, horizontalPadding)

            centerColumn
                .frame(height: contentHeight, alignment: .center)
                .padding(.horizontal, horizontalPadding)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .top
        )
        .frame(height: contentHeight)

        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            content
                .safeAreaPadding(.top, topSpacing)
                .padding(.bottom, bottomSpacing)
        } else {
            content
                .padding(.top, topSpacing)
                .padding(.bottom, bottomSpacing)
        }
    }

    private var horizontalPadding: CGFloat {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
            return 16
        }
        return 8
    }

    private var leadingColumn: some View {
        HStack(spacing: stateModel.style?.horizontalSpacing ?? 12) {
            if let leadingCard = stateModel.leadingCard {
                SUINavigationLeadingCardView(
                    model: leadingCard,
                    primeFont: stateModel.style?.primeFont ?? .systemFont(ofSize: 18),
                    primeColor: stateModel.style?.primeColor ?? .label
                )
            }
        }
    }

    private var centerColumn: some View {
        SwiftUI.Group {
            switch stateModel.centerView {
            case .keyValue(let pair):
                VStack(spacing: 4) {
                    SUINavigationTextView(
                        model: pair.first,
                        font: stateModel.style?.primeFont ?? .systemFont(ofSize: 18),
                        color: stateModel.style?.primeColor ?? .black,
                        numberOfLines: stateModel.style?.numberOfLines ?? 1,
                        alignment: .center
                    )
                    SUINavigationTextView(
                        model: pair.second,
                        font: .systemFont(ofSize: 14),
                        color: .black,
                        numberOfLines: 1,
                        alignment: .center
                    )
                }
            case .titledImage(let pair):
                VStack(spacing: 4) {
                    SUINavigationImageView(
                        model: pair.first,
                        tintColor: stateModel.style?.primeColor
                    )
                    SUINavigationTextView(
                        model: pair.second,
                        font: stateModel.style?.secondaryFont ?? .systemFont(ofSize: 14),
                        color: stateModel.style?.secondaryColor ?? .black,
                        numberOfLines: 1,
                        alignment: .center
                    )
                }
            case .none:
                SwiftUI.EmptyView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var trailingColumn: some View {
        HStack(spacing: (stateModel.style?.horizontalSpacing ?? 12) * 1.5) {
            SUINavigationButtonView(
                model: stateModel.primeTrailingImage,
                tintColor: stateModel.style?.primeColor
            )
            SUINavigationButtonView(
                model: stateModel.secondaryTrailingImage,
                tintColor: stateModel.style?.primeColor
            )
            SUINavigationButtonView(
                model: stateModel.tertiaryTrailingImage,
                tintColor: stateModel.style?.primeColor
            )
        }
    }
}

private struct SUINavigationLeadingCardView: View {
    let model: CardViewPresentableModel
    let primeFont: Font
    let primeColor: Color

    var body: some View {
        SwiftUI.Group {
            if let onPress = model.onPress {
                SwiftUI.Button(action: onPress) {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
    }

    private var content: some View {
        HStack(spacing: 8) {
            if model.leadingImage == nil, let backgroundImage = model.backgroundImage {
                SUINavigationImageView(
                    model: backgroundImage,
                    tintColor: nil
                )
            } else {
                SUINavigationImageView(
                    model: model.leadingImage ?? model.backgroundImage,
                    tintColor: primeColor
                )

                if let title = preferredTitle {
                    SUINavigationTextView(
                        model: title,
                        font: primeFont,
                        color: primeColor,
                        numberOfLines: 1,
                        alignment: .left
                    )
                }
            }
        }
        .padding(.horizontal, model.leadingImage == nil && model.backgroundImage != nil ? 0 : 10)
        .frame(minHeight: model.leadingImage == nil && model.backgroundImage != nil ? 0 : 32)
        .background(SwiftUIColor(model.style?.backgroundColor ?? .clear))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    SwiftUIColor(model.style?.borderColor ?? .clear),
                    lineWidth: model.style?.borderWidth ?? 0
                )
        )
    }

    private var preferredTitle: TextOutputPresentableModel? {
        model.title ?? model.leadingTitles?.first
    }
}

private struct SUINavigationButtonView: View {
    let model: ButtonPresentableModel?
    let tintColor: Color?

    var body: some View {
        if let model {
            SwiftUI.Button(action: model.onPress ?? {}) {
                HStack(spacing: model.spacing ?? 0) {
                    if let image = model.image {
                        SUINavigationImageView(
                            model: .init(image: .asset(image)),
                            tintColor: tintColor ?? model.style?.titleColor
                        )
                    }

                    if let title = model.title?.removingPercentEncoding ?? model.title, !title.isEmpty {
                        SwiftUI.Text(title)
                            .font((model.style?.font).map(SwiftUIFont.init))
                    }
                }
                .foregroundColor(SwiftUIColor(model.style?.titleColor ?? tintColor ?? .label))
                .frame(width: model.width, height: model.height)
                .background(SwiftUIColor(model.style?.backgroundColor ?? .clear))
                .overlay(
                    RoundedRectangle(cornerRadius: model.style?.cornerRadius ?? 12)
                        .stroke(
                            SwiftUIColor(model.style?.borderColor ?? .clear),
                            lineWidth: model.style?.borderWidth ?? 0
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: model.style?.cornerRadius ?? 12))
                .opacity((model.enabled ?? true) ? 1 : 0.5)
            }
            .buttonStyle(.plain)
            .disabled(!(model.enabled ?? true))
        }
    }
}

private struct SUINavigationImageView: View {
    let model: ImageViewPresentableModel?
    let tintColor: Color?

    init(model: ImageViewPresentableModel?, tintColor: Color? = nil) {
        self.model = model
        self.tintColor = tintColor
    }

    var body: some View {
        SwiftUI.Group {
            if let model {
                imageBody(model)
                    .frame(width: model.size?.width, height: model.size?.height)
                    .opacity(model.alpha ?? 1)
                    .clipShape(RoundedRectangle(cornerRadius: model.cornerRadius ?? 0))
                    .overlay(
                        RoundedRectangle(cornerRadius: model.cornerRadius ?? 0)
                            .stroke(
                                SwiftUIColor(model.borderColor ?? .clear),
                                lineWidth: model.borderWidth ?? 0
                            )
                    )
            }
        }
    }

    @ViewBuilder
    private func imageBody(_ model: ImageViewPresentableModel) -> some View {
        switch model.image {
        case .asset(let image):
            if let image {
                configured(image: SwiftUIImage(image: image), isTemplate: true, model: model)
            }
        case .data(let data):
            if let data, let image = Image(data: data) {
                configured(image: SwiftUIImage(image: image), isTemplate: true, model: model)
            }
        case .url, .urlString:
            SwiftUI.EmptyView()
        case .none:
            SwiftUI.EmptyView()
        }
    }

    private func configured(image: SwiftUIImage, isTemplate: Bool, model: ImageViewPresentableModel) -> some View {
        image
            .renderingMode(isTemplate ? .template : .original)
            .resizable()
            .aspectRatio(contentMode: (model.contentModeIsFit ?? true) ? .fit : .fill)
            .foregroundColor((tintColor ?? model.borderColor).map(SwiftUIColor.init))
    }
}

private struct SUINavigationTextView: View {
    let model: TextOutputPresentableModel?
    let font: Font
    let color: Color
    let numberOfLines: Int
    let alignment: NSTextAlignment
    private let simpleTextYOffset: CGFloat

    init(
        model: TextOutputPresentableModel?,
        font: Font,
        color: Color,
        numberOfLines: Int,
        alignment: NSTextAlignment
    ) {
        self.model = model
        self.font = font
        self.color = color
        self.numberOfLines = numberOfLines
        self.alignment = alignment
#if os(macOS)
        self.simpleTextYOffset = 4 / min(20 + (max(0, font.pointSize - 30) * 0.5), 25)
#else
        self.simpleTextYOffset = font.lineHeight / min(20 + (max(0, font.pointSize - 30) * 0.5), 25)
#endif
    }

    var body: some View {
        SwiftUI.Group {
            if let text = resolvedText, !text.isEmpty {
                SwiftUI.Text(text)
                    .font(SwiftUIFont(font))
                    .offset(y: -simpleTextYOffset)
                    .foregroundColor(SwiftUIColor(color))
                    .lineLimit(numberOfLines == 0 ? nil : numberOfLines)
                    .multilineTextAlignment(alignment.suiTextAlignment)
                    .frame(maxWidth: .infinity, alignment: alignment.suiAlignment)
            }
        }
    }

    private var resolvedText: String? {
        guard let model else { return nil }
        switch model.model {
        case .text(let value):
            return value?.removingPercentEncoding ?? value
        default:
            return nil
        }
    }
}
#endif
