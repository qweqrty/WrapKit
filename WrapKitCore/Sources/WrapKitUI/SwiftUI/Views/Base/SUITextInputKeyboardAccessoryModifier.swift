import SwiftUI

struct SUITextInputKeyboardAccessoryModifier: ViewModifier {
    let model: TextInputPresentableModel.AccessoryViewPresentableModel?
    let isFocused: Bool
    let onPress: (ButtonPresentableModel) -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
#if os(iOS)
        if #available(iOS 16.0, *) {
            content.toolbar {
                if isFocused, let model {
                    if #available(iOS 26.0, *) {
                        accessory(model: model)
                            .sharedBackgroundVisibility(.hidden)
                    } else {
                        accessory(model: model)
                    }
                }
            }
        } else if let model {
            content.toolbar {
                accessory(model: model)
            }
        } else {
            content
        }
#else
        content
#endif
    }

#if os(iOS)
    private func accessory(
        model: TextInputPresentableModel.AccessoryViewPresentableModel
    ) -> some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            if let buttonModel = model.trailingButton {
                VStack(spacing: 0) {
                    button(buttonModel)
                        .frame(width: buttonModel.width ?? 80, height: buttonModel.height ?? 36)
                }
                .frame(height: model.style.height)
                .background(SwiftUIColor(model.style.backgroundColor))
            }
        }
    }

    @ViewBuilder
    private func button(_ model: ButtonPresentableModel) -> some View {
        if model.style != nil {
            SUIButtonView(
                model: model,
                onPress: { onPress(model) },
                isEnabled: model.enabled ?? true,
                allowsGlassEffect: false
            )
        } else {
            SwiftUI.Button {
                onPress(model)
            } label: {
                HStack(spacing: model.spacing ?? 0) {
                    if let image = model.image {
                        SwiftUIImage(image: image)
                            .renderingMode(image.swiftUIRenderingMode)
                    }
                    if let title = model.title {
                        Text(title.removingPercentEncoding ?? title)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            .disabled(model.enabled == false)
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
    }
#endif
}
