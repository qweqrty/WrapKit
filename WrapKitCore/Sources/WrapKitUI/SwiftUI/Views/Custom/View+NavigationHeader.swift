#if os(iOS)
import SwiftUI

@available(iOS 16.0, *)
public extension View {
    /// Attach to each screen INSIDE a NavigationStack, using one retained adapter
    /// per screen. Presenters can send HeaderOutput.display before the view mounts.
    /// This modifier does not own the stack or its path.
    func navigationHeader(adapter: HeaderOutputSwiftUIAdapter) -> some View {
        modifier(NativeNavigationHeaderModifier(adapter: adapter))
    }
}

@available(iOS 16.0, *)
private struct NativeNavigationHeaderModifier: ViewModifier {
    @StateObject private var state: SUINavigationBarStateModel

    init(adapter: HeaderOutputSwiftUIAdapter) {
        _state = StateObject(wrappedValue: SUINavigationBarStateModel(adapter: adapter))
    }

    private var style: HeaderPresentableModel.Style {
        state.model.style ?? SUINavigationBarStateModel.defaultStyle
    }

    func body(content: Content) -> some View {
        content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            // The presenter owns the back action, just as with UINavigationBar.
            .navigationBarBackButtonHidden(true)
            .toolbar(state.isHidden ? .hidden : .visible, for: .navigationBar)
            .toolbarBackground(SwiftUIColor(style.backgroundColor), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if !state.isHidden {
                    if state.model.leadingCard != nil {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NativeNavigationHeaderLeading(state: state, style: style)
                        }
                        .headerAxisBehavior(vertical: state.model.leadingCard?.isNativeHeaderAction == true)
                    }
                    ToolbarItem(placement: .principal) {
                        NativeNavigationHeaderTitle(state: state, style: style)
                    }
                    if state.model.primeTrailingImage != nil && !state.primeTrailingButtonStateModel.isHidden {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NativeNavigationHeaderButton(state: state.primeTrailingButtonStateModel, tint: style.primeColor)
                        }
                        .headerAxisBehavior(vertical: state.primeTrailingButtonStateModel.presentable.isVerticalHeaderAction)
                    }
                    if state.model.secondaryTrailingImage != nil && !state.secondaryTrailingButtonStateModel.isHidden {
                        if #available(iOS 26.0, *), state.model.primeTrailingImage != nil && !state.primeTrailingButtonStateModel.isHidden {
                            ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NativeNavigationHeaderButton(state: state.secondaryTrailingButtonStateModel, tint: style.primeColor)
                        }
                        .headerAxisBehavior(vertical: state.secondaryTrailingButtonStateModel.presentable.isVerticalHeaderAction)
                    }
                    if state.model.tertiaryTrailingImage != nil && !state.tertiaryTrailingButtonStateModel.isHidden {
                        if #available(iOS 26.0, *),
                           (state.model.primeTrailingImage != nil && !state.primeTrailingButtonStateModel.isHidden)
                            || (state.model.secondaryTrailingImage != nil && !state.secondaryTrailingButtonStateModel.isHidden) {
                            ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NativeNavigationHeaderButton(state: state.tertiaryTrailingButtonStateModel, tint: style.primeColor)
                        }
                        .headerAxisBehavior(vertical: state.tertiaryTrailingButtonStateModel.presentable.isVerticalHeaderAction)
                    }
                }
            }
    }
}

// Match the UIKit header: compact actions participate in the vertical bar;
// rich controls stay horizontal. Let the system choose the actual edge.
@available(iOS 16.0, *)
private extension ToolbarContent {
    @ToolbarContentBuilder
    func headerAxisBehavior(vertical: Bool) -> some ToolbarContent {
        if #available(iOS 27.1, *) {
            axisBehavior(vertical ? .verticalPreferred : .horizontalOnly)
        } else {
            self
        }
    }
}

private extension ButtonPresentableModel {
    var isVerticalHeaderAction: Bool {
        if style == nil && width == nil && height == nil && spacing == nil { return true }
        return title == nil && (width ?? 44) <= 44 && (height ?? 44) <= 44
    }
}

private extension CardViewPresentableModel {
    var isNativeHeaderAction: Bool {
        guard case let .asset(image)? = leadingImage?.image, image != nil else { return false }
        if let text = title?.model {
            switch text {
            case .text: break
            default: return false
            }
        }
        return style == nil && leadingTitles == nil && trailingTitles == nil
            && subTitle == nil && valueTitle == nil && backgroundImage == nil
            && secondaryLeadingImage == nil && trailingImage == nil && secondaryTrailingImage == nil
            && bottomImage == nil && bottomSeparator == nil && switchControl == nil
            && !isGradientBorderEnabled && onLongPress == nil && leadingImage?.onLongPress == nil
    }
}

@available(iOS 16.0, *)
private struct NativeNavigationHeaderLeading: View {
    @ObservedObject var state: SUINavigationBarStateModel
    let style: HeaderPresentableModel.Style

    var body: some View {
        if let card = state.model.leadingCard, card.isNativeHeaderAction {
            if #available(iOS 27.1, *) {
                AdaptiveNativeNavigationHeaderAction(card: card, style: style)
            } else {
                NativeNavigationHeaderAction(card: card, style: style, showsTitle: true)
            }
        } else {
            SUICardView(adapter: state.leadingCardAdapter, leadingImageTint: state.leadingCardImageTint)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

}

@available(iOS 27.1, *)
private struct AdaptiveNativeNavigationHeaderAction: View {
    @Environment(\.toolbarVerticalEdge) private var verticalEdge
    let card: CardViewPresentableModel
    let style: HeaderPresentableModel.Style

    var body: some View {
        NativeNavigationHeaderAction(card: card, style: style, showsTitle: verticalEdge == nil)
    }
}

@available(iOS 16.0, *)
private struct NativeNavigationHeaderAction: View {
    let card: CardViewPresentableModel
    let style: HeaderPresentableModel.Style
    let showsTitle: Bool

    var body: some View {
        SwiftUI.Button {
            (card.onPress ?? card.leadingImage?.onPress)?()
        } label: {
            HStack(spacing: style.horizontalSpacing) {
                if case let .asset(image)? = card.leadingImage?.image, let image {
                    SwiftUIImage(image: image).renderingMode(.template)
                }
                if showsTitle, let title = card.title {
                    SUILabelView(model: title, font: style.primeFont, textColor: style.primeColor)
                }
            }
        }
        .tint(SwiftUIColor(style.primeColor))
        .disabled(card.isUserInteractionEnabled == false)
        .ifLet(card.accessibilityIdentifier) { $0.accessibilityIdentifier($1) }
        .ifLet(card.accessibility?.label ?? card.leadingImage?.accessibility?.label ?? card.title?.model?.text) {
            $0.accessibilityLabel(Text($1))
        }
        .ifLet(card.accessibility?.hint) { $0.accessibilityHint(Text($1)) }
    }
}

@available(iOS 16.0, *)
private struct NativeNavigationHeaderTitle: View {
    @ObservedObject var state: SUINavigationBarStateModel
    let style: HeaderPresentableModel.Style

    var body: some View {
        VStack(spacing: SUINavigationBarCenterLayoutMetrics.spacing) {
            switch state.model.centerView {
            case .keyValue(let pair):
                if pair.first != nil {
                    SUIOutputLabel(
                        stateModel: state.centerKeyStateModel,
                        font: style.primeFont,
                        textColor: style.primeColor,
                        textAlignment: .center
                    )
                }
                if pair.second != nil {
                    SUIOutputLabel(
                        stateModel: state.centerValueStateModel,
                        font: style.secondaryFont,
                        textColor: style.secondaryColor,
                        textAlignment: .center
                    )
                }
            case .titledImage(let pair):
                if let image = pair.first {
                    let size = SUINavigationBarCenterLayoutMetrics.resolvedImageSize(for: image)
                    SUIImageView(adapter: state.centerTitledImageAdapter)
                        .frame(width: size.width, height: size.height)
                }
                if pair.second != nil {
                    SUIOutputLabel(
                        stateModel: state.centerTitledImageTitleStateModel,
                        font: style.secondaryFont,
                        textColor: style.secondaryColor,
                        textAlignment: .center
                    )
                }
            case nil:
                SwiftUI.EmptyView()
            }
        }
        .lineLimit(style.numberOfLines == 0 ? nil : style.numberOfLines)
    }
}

@available(iOS 16.0, *)
private struct NativeNavigationHeaderButton: View {
    @ObservedObject var state: SUIButtonStateModel
    let tint: Color

    var body: some View {
        if !state.isHidden {
            let model = state.presentable
            if model.style == nil && model.width == nil && model.height == nil && model.spacing == nil {
                SwiftUI.Button {
                    model.onPress?()
                } label: {
                    if let image = model.image {
                        SwiftUIImage(image: image)
                            .renderingMode(.template)
                    } else {
                        Text(model.title?.removingPercentEncoding ?? model.title ?? "")
                    }
                }
                .tint(SwiftUIColor(tint))
                .disabled(!state.isEnabled || model.onPress == nil)
                .ifLet(model.accessibilityIdentifier) { view, identifier in
                    view.accessibilityIdentifier(identifier)
                }
                .ifLet(model.accessibility?.label ?? model.title) { view, label in
                    view.accessibilityLabel(Text(label))
                }
                .ifLet(model.accessibility?.hint) { view, hint in
                    view.accessibilityHint(Text(hint))
                }
            } else {
                SUIButtonView(
                    model: model,
                    onPress: model.onPress,
                    isEnabled: state.isEnabled,
                    fillsAvailableWidth: false,
                    fillsAvailableHeight: false
                )
                .tint(SwiftUIColor(tint))
            }
        }
    }
}
#endif
