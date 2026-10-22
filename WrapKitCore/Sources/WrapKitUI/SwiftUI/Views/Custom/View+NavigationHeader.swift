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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(adapter: HeaderOutputSwiftUIAdapter) {
        _state = StateObject(wrappedValue: SUINavigationBarStateModel(adapter: adapter))
    }

    private var style: HeaderPresentableModel.Style {
        state.model.style ?? SUINavigationBarStateModel.defaultStyle
    }

    private var toolbarLayoutID: String {
        let leading = state.model.leadingCard
        let flags = [
            horizontalSizeClass == .regular,
            leading != nil,
            leading?.isNativeHeaderAction == true,
            leading?.title?.model?.text?.isEmpty == false,
            state.model.primeTrailingImage != nil && !state.primeTrailingButtonStateModel.isHidden,
            state.model.secondaryTrailingImage != nil && !state.secondaryTrailingButtonStateModel.isHidden,
            state.model.tertiaryTrailingImage != nil && !state.tertiaryTrailingButtonStateModel.isHidden
        ]
        return flags.map { $0 ? "1" : "0" }.joined()
    }

    private var centerLayoutID: String {
        switch state.model.centerView {
        case .keyValue(let pair):
            return "key-value-\(pair.first?.model?.hasNavigationHeaderContent == true)-\(pair.second?.model?.hasNavigationHeaderContent == true)"
        case .titledImage(let pair):
            return "titled-image-\(pair.first != nil)-\(pair.second?.model?.hasNavigationHeaderContent == true)"
        case nil:
            return "empty"
        }
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
            // Axis changes must replace toolbar actions, not the screen or presenter state.
            // Side changes also reset the principal host's previously compressed width.
            .toolbar {
                if !state.isHidden {
                    if state.model.leadingCard != nil {
                        ToolbarItem(id: "header-leading-\(toolbarLayoutID)", placement: .navigationBarLeading) {
                            NativeNavigationHeaderLeading(state: state, style: style)
                        }
                        .headerAxisBehavior(vertical: horizontalSizeClass != .regular && state.model.leadingCard?.isNativeHeaderAction == true)
                    }
                    // An initially empty principal host otherwise keeps its zero height
                    // when a presenter supplies the center after loading completes.
                    ToolbarItem(id: "header-title-\(toolbarLayoutID)-\(centerLayoutID)", placement: .principal) {
                        NativeNavigationHeaderTitle(state: state, style: style)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if state.model.primeTrailingImage != nil && !state.primeTrailingButtonStateModel.isHidden {
                        ToolbarItem(id: "header-primary-\(toolbarLayoutID)", placement: .navigationBarTrailing) {
                            NativeNavigationHeaderButton(state: state.primeTrailingButtonStateModel, tint: style.primeColor)
                        }
                        .headerAxisBehavior(vertical: horizontalSizeClass != .regular && state.primeTrailingButtonStateModel.presentable.isVerticalHeaderAction)
                    }
                    if state.model.secondaryTrailingImage != nil && !state.secondaryTrailingButtonStateModel.isHidden {
                        if #available(iOS 26.0, *), state.model.primeTrailingImage != nil && !state.primeTrailingButtonStateModel.isHidden {
                            ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
                        }
                        ToolbarItem(id: "header-secondary-\(toolbarLayoutID)", placement: .navigationBarTrailing) {
                            NativeNavigationHeaderButton(state: state.secondaryTrailingButtonStateModel, tint: style.primeColor)
                        }
                        .headerAxisBehavior(vertical: horizontalSizeClass != .regular && state.secondaryTrailingButtonStateModel.presentable.isVerticalHeaderAction)
                    }
                    if state.model.tertiaryTrailingImage != nil && !state.tertiaryTrailingButtonStateModel.isHidden {
                        if #available(iOS 26.0, *),
                           (state.model.primeTrailingImage != nil && !state.primeTrailingButtonStateModel.isHidden)
                            || (state.model.secondaryTrailingImage != nil && !state.secondaryTrailingButtonStateModel.isHidden) {
                            ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
                        }
                        ToolbarItem(id: "header-tertiary-\(toolbarLayoutID)", placement: .navigationBarTrailing) {
                            NativeNavigationHeaderButton(state: state.tertiaryTrailingButtonStateModel, tint: style.primeColor)
                        }
                        .headerAxisBehavior(vertical: horizontalSizeClass != .regular && state.tertiaryTrailingButtonStateModel.presentable.isVerticalHeaderAction)
                    }
                }
            }
    }
}

private extension TextOutputPresentableModel.TextModel {
    var hasNavigationHeaderContent: Bool {
        switch self {
        case .text(let text):
            return text?.isEmpty == false
        case .attributes(let attributes):
            return attributes.contains { !$0.text.isEmpty || $0.leadingImage != nil || $0.trailingImage != nil }
        case .attributedString(let text, _):
            return text?.isEmpty == false
        case .textStyled(let text, _, let insets, let height, let backgroundColor):
            return text.hasNavigationHeaderContent || !insets.isZero || (height ?? 0) > 0 || backgroundColor != nil
        case .animatedDecimal, .animated:
            return true
        }
    }
}

// Match the UIKit header: compact actions participate in the vertical bar;
// rich controls and regular-width screens stay in the horizontal bar.
@available(iOS 16.0, *)
private extension ToolbarContent {
    @ToolbarContentBuilder
    func headerAxisBehavior(vertical: Bool) -> some ToolbarContent {
        #if compiler(>=6.4)
        if #available(iOS 27.1, *) {
            axisBehavior(vertical ? .verticalPreferred : .horizontalOnly)
        } else {
            self
        }
        #else
        self
        #endif
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
            #if compiler(>=6.4)
            if #available(iOS 27.1, *) {
                AdaptiveNativeNavigationHeaderAction(state: state, style: style)
            } else {
                NativeNavigationHeaderAction(state: state, style: style, showsTitle: true)
            }
            #else
            NativeNavigationHeaderAction(state: state, style: style, showsTitle: true)
            #endif
        } else {
            SUICardView(adapter: state.leadingCardAdapter, leadingImageTint: state.leadingCardImageTint, fitsNavigationBar: true)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

}

#if compiler(>=6.4)
@available(iOS 27.1, *)
private struct AdaptiveNativeNavigationHeaderAction: View {
    @Environment(\.toolbarVerticalEdge) private var verticalEdge
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var state: SUINavigationBarStateModel
    let style: HeaderPresentableModel.Style

    var body: some View {
        NativeNavigationHeaderAction(state: state, style: style, showsTitle: verticalEdge == nil || horizontalSizeClass == .regular)
    }
}
#endif

@available(iOS 16.0, *)
private struct NativeNavigationHeaderAction: View {
    @ObservedObject var state: SUINavigationBarStateModel
    let style: HeaderPresentableModel.Style
    let showsTitle: Bool

    var body: some View {
        if let card = state.model.leadingCard {
            SwiftUI.Button {
                let currentCard = state.model.leadingCard
                (currentCard?.onPress ?? currentCard?.leadingImage?.onPress)?()
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
                    // A toolbar can retain its rendered action across push/pop.
                    // Resolve the current Output callback instead of a revoked model snapshot.
                    state.presentable.onPress?()
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
                    onPress: model.onPress.map { _ in { state.presentable.onPress?() } },
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
