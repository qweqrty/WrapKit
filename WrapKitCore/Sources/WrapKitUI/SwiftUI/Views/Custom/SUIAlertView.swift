import Foundation

#if canImport(SwiftUI)
import SwiftUI

public extension View {
    /// Presents `AlertOutput` events with the native SwiftUI alert and confirmation dialog,
    /// mirroring `UIViewController: AlertOutput`.
    func alertView(adapter: AlertOutputSwiftUIAdapter) -> some View {
        modifier(SUIAlertModifier(adapter: adapter))
    }
}

private struct SUIAlertModifier: ViewModifier {
    @ObservedObject var adapter: AlertOutputSwiftUIAdapter

    @State private var alert: AlertPresentableModel?
    @State private var actionSheet: AlertPresentableModel?
    @State private var textFieldAlert: AlertPresentableModel?
    @State private var inputText = ""

    func body(content: Content) -> some View {
        content
            .alert(
                Text(alert?.title ?? ""),
                isPresented: isPresented($alert),
                presenting: alert,
                actions: { model in buttons(for: model) },
                message: { model in message(for: model) }
            )
            .confirmationDialog(
                Text(actionSheet?.title ?? ""),
                isPresented: isPresented($actionSheet),
                titleVisibility: actionSheet?.title == nil ? .hidden : .visible,
                presenting: actionSheet,
                actions: { model in buttons(for: model) },
                message: { model in message(for: model) }
            )
            .modifier(SUITextFieldAlertModifier(
                model: $textFieldAlert,
                inputText: $inputText,
                buttons: { model in buttons(for: model, inputText: inputText) },
                message: { model in message(for: model) }
            ))
            // Events are consumed so a re-created view doesn't present them again.
            .onReceive(adapter.$showAlertModelState.compactMap { $0 }) { state in
                adapter.showAlertModelState = nil
                alert = state.model
            }
            .onReceive(adapter.$showActionSheetModelState.compactMap { $0 }) { state in
                adapter.showActionSheetModelState = nil
                actionSheet = state.model
            }
            .onReceive(adapter.$showTextFieldAlertModelState.compactMap { $0 }) { state in
                adapter.showTextFieldAlertModelState = nil
                inputText = ""
                textFieldAlert = state.model
            }
    }

    private func isPresented(_ model: Binding<AlertPresentableModel?>) -> Binding<Bool> {
        Binding(
            get: { model.wrappedValue != nil },
            set: { if !$0 { model.wrappedValue = nil } }
        )
    }

    @ViewBuilder
    private func buttons(for model: AlertPresentableModel, inputText: String? = nil) -> some View {
        ForEach(Array(model.actions.enumerated()), id: \.offset) { _, action in
            SwiftUI.Button(role: action.style.buttonRole) {
                if let inputText {
                    action.inputHandler?(action.style == .cancel ? "" : inputText)
                }
                action.handler?()
            } label: {
                Text(action.title)
            }
            .ifLet(action.accessibilityIdentifier) { view, identifier in
                view.accessibilityIdentifier(identifier)
            }
        }
        if let cancelText = model.cancelText {
            SwiftUI.Button(cancelText, role: .cancel) {}
        }
    }

    @ViewBuilder
    private func message(for model: AlertPresentableModel) -> some View {
        if let text = model.text {
            Text(text)
        }
    }
}

private struct SUITextFieldAlertModifier<Buttons: View, Message: View>: ViewModifier {
    @Binding var model: AlertPresentableModel?
    @Binding var inputText: String
    let buttons: (AlertPresentableModel) -> Buttons
    let message: (AlertPresentableModel) -> Message

    func body(content: Content) -> some View {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            content.alert(
                Text(model?.title ?? ""),
                isPresented: Binding(
                    get: { model != nil },
                    set: { if !$0 { model = nil } }
                ),
                presenting: model,
                actions: { model in
                    TextField(model.placeholder ?? "", text: $inputText)
                    buttons(model)
                },
                message: { model in message(model) }
            )
        } else {
            content
        }
    }
}

private extension AlertAction.Style {
    var buttonRole: SwiftUI.ButtonRole? {
        switch self {
        case .default: return nil
        case .cancel: return .cancel
        case .destructive: return .destructive
        }
    }
}
#endif
