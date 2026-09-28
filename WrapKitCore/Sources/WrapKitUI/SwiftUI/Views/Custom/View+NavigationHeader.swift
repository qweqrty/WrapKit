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
                    ToolbarItem(placement: .navigationBarLeading) {
                        if state.model.leadingCard != nil {
                            SUICardView(
                                adapter: state.leadingCardAdapter,
                                leadingImageTint: state.leadingCardImageTint
                            )
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        NativeNavigationHeaderTitle(state: state, style: style)
                    }
                    // Separate items let SwiftUI manage placement and overflow.
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if state.model.primeTrailingImage != nil {
                            NativeNavigationHeaderButton(state: state.primeTrailingButtonStateModel, tint: style.primeColor)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if state.model.secondaryTrailingImage != nil {
                            NativeNavigationHeaderButton(state: state.secondaryTrailingButtonStateModel, tint: style.primeColor)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if state.model.tertiaryTrailingImage != nil {
                            NativeNavigationHeaderButton(state: state.tertiaryTrailingButtonStateModel, tint: style.primeColor)
                        }
                    }
                }
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
