import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUINavigationBar: View {
    @StateObject private var stateModel: SUINavigationBarStateModel

    public init(adapter: HeaderOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    init(stateModel: SUINavigationBarStateModel) {
        _stateModel = .init(wrappedValue: stateModel)
    }

    public var body: some View {
        if !stateModel.isHidden {
            let model = stateModel.model
            let style = model.style ?? SUINavigationBarStateModel.defaultStyle
            ZStack {
                centerSection(model: model, style: style)
                    .frame(maxWidth: .infinity, alignment: .center)

                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                    SUINavigationBarSidesLayout(mainStackSpacing: 8) {
                        SUINavigationBarSideSlot {
                            leadingSection(model: model)
                        }
                        SUINavigationBarSideSlot {
                            trailingSection(model: model, style: style)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HStack(spacing: 8) {
                        leadingSection(model: model)
                        Spacer(minLength: 0)
                        trailingSection(model: model, style: style)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.top, 4)
            .padding(.bottom, 8)
            .padding(.horizontal, horizontalPadding)
            .background(SwiftUIColor(style.backgroundColor))
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
            let width = leadingCardWidth(for: leadingCard)
            if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *),
               isLiquidGlassEnabled,
               leadingCard.onPress != nil || leadingCard.onLongPress != nil {
                SUINavigationBarIntrinsicCompressingView(usesIntrinsicWidth: width == nil) {
                    SUICardView(
                        adapter: stateModel.leadingCardAdapter,
                        titleFontOverride: nil,
                        titleColorOverride: nil,
                        leadingImageTintOverride: stateModel.leadingCardImageTint
                    )
                }
                    .frame(
                        width: width,
                        height: 44,
                        alignment: .leading
                    )
                    .clipped()
                    .glassEffect(
                        .regular.interactive(),
                        in: SUICornerShape(style: .automatic)
                    )
            } else {
                SUINavigationBarIntrinsicCompressingView(usesIntrinsicWidth: width == nil) {
                    SUICardView(
                        adapter: stateModel.leadingCardAdapter,
                        titleFontOverride: nil,
                        titleColorOverride: nil,
                        leadingImageTintOverride: stateModel.leadingCardImageTint
                    )
                }
                    .frame(
                        width: width,
                        height: 44,
                        alignment: .leading
                    )
                    .clipped()
            }
        }
    }

    private func leadingCardWidth(for model: CardViewPresentableModel) -> CGFloat? {
        guard let background = model.backgroundImage else { return nil }
        if let width = background.size?.width {
            return width
        }
        if case .asset(let image) = background.image {
            return image?.size.width
        }
        return nil
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
            SUINavigationBarButtonView(
                stateModel: stateModel.primeTrailingButtonStateModel,
                isPresented: model.primeTrailingImage != nil,
                tintColor: style.primeColor
            )
            SUINavigationBarButtonView(
                stateModel: stateModel.secondaryTrailingButtonStateModel,
                isPresented: model.secondaryTrailingImage != nil,
                tintColor: style.primeColor
            )
            SUINavigationBarButtonView(
                stateModel: stateModel.tertiaryTrailingButtonStateModel,
                isPresented: model.tertiaryTrailingImage != nil,
                tintColor: style.primeColor
            )
        }
        .frame(maxHeight: .infinity, alignment: .trailing)
    }
}

private struct SUINavigationBarIntrinsicCompressingView<Content: View>: View {
    let usesIntrinsicWidth: Bool
    let content: Content

    init(
        usesIntrinsicWidth: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.usesIntrinsicWidth = usesIntrinsicWidth
        self.content = content()
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            SUINavigationBarIntrinsicCompressingLayout(
                usesIntrinsicWidth: usesIntrinsicWidth
            ) {
                content
            }
        } else {
            content.fixedSize(horizontal: usesIntrinsicWidth, vertical: false)
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct SUINavigationBarIntrinsicCompressingLayout: Layout {
    let usesIntrinsicWidth: Bool

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else { return .zero }
        let ideal = subview.sizeThatFits(.unspecified)
        let compressionBreakpointWidth = usesIntrinsicWidth
            ? subview.sizeThatFits(ProposedViewSize(width: 0, height: nil)).width
            : nil
        return CGSize(
            width: SUINavigationBarIntrinsicWidthResolver.resolvedWidth(
                idealWidth: ideal.width,
                proposedWidth: finite(proposal.width),
                compressionBreakpointWidth: compressionBreakpointWidth
            ),
            height: finite(proposal.height) ?? ideal.height
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        subviews.first?.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(width: bounds.width, height: bounds.height)
        )
    }

    private func finite(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(value, 0)
    }
}

private struct SUINavigationBarSideSlot<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct SUINavigationBarSidesLayout: Layout {
    let mainStackSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let idealSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return CGSize(
            width: finite(proposal.width)
                ?? idealSizes.map(\.width).reduce(0, +) + mainStackSpacing * 2,
            height: finite(proposal.height) ?? idealSizes.map(\.height).max() ?? 0
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard let leading = subviews.first, let trailing = subviews.last else { return }
        let sideProposal = ProposedViewSize(
            width: SUINavigationBarSideWidthResolver.equalSideProposalWidth(
                availableWidth: bounds.width,
                mainStackSpacing: mainStackSpacing
            ),
            height: bounds.height
        )
        leading.place(
            at: CGPoint(x: bounds.minX, y: bounds.minY),
            anchor: .topLeading,
            proposal: sideProposal
        )
        trailing.place(
            at: CGPoint(x: bounds.maxX, y: bounds.minY),
            anchor: .topTrailing,
            proposal: sideProposal
        )
    }

    private func finite(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(value, 0)
    }
}

enum SUINavigationBarSideWidthResolver {
    static func equalSideProposalWidth(
        availableWidth: CGFloat,
        mainStackSpacing: CGFloat
    ) -> CGFloat {
        max((availableWidth - max(mainStackSpacing, 0) * 2) / 2, 0)
    }
}

enum SUINavigationBarIntrinsicWidthResolver {
    static func resolvedWidth(
        idealWidth: CGFloat,
        proposedWidth: CGFloat?,
        compressionBreakpointWidth: CGFloat? = nil
    ) -> CGFloat {
        let idealWidth = max(idealWidth, 0)
        guard let proposedWidth else { return idealWidth }
        let finiteProposedWidth = max(proposedWidth, 0)
        let compressionBreakpointWidth = max(compressionBreakpointWidth ?? 0, 0)
        return min(idealWidth, max(finiteProposedWidth, compressionBreakpointWidth))
    }
}

private struct SUINavigationBarButtonView: View {
    @ObservedObject var stateModel: SUIButtonStateModel

    let isPresented: Bool
    let tintColor: Color

    @ViewBuilder
    var body: some View {
        if isPresented, !stateModel.isHidden {
            let model = stateModel.presentable
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
        .disabled(!stateModel.isEnabled)
        .allowsHitTesting(model.onPress != nil && stateModel.isEnabled)
        .opacity(stateModel.isEnabled ? 1 : 0.5)
        .if(model.onPress == nil) { view in
            view
                .accessibilityRemoveTraits(.isButton)
                .accessibilityAddTraits(.isStaticText)
        }
        .ifLet(model.accessibilityIdentifier) { view, identifier in
            view.accessibilityIdentifier(identifier)
        }
        .ifLet(model.accessibility?.label) { view, label in
            view.accessibilityLabel(Text(label))
        }
        .ifLet(model.accessibility?.hint) { view, hint in
            view.accessibilityHint(Text(hint))
        }
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
