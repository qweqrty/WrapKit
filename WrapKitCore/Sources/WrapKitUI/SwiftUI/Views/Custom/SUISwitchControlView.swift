import Foundation

#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SUISwitchControlView: View {
    let model: SwitchControlPresentableModel

    var body: some View {
        #if canImport(UIKit)
        SUISwitchControlRepresentable(model: model)
            .fixedSize()
        #else
        let tintColor = SwiftUIColor(model.style?.tintColor ?? .systemGreen)
        Toggle(isOn: .constant(model.isOn ?? false)) {
            SwiftUI.EmptyView()
        }
        .labelsHidden()
        .toggleStyle(SwitchToggleStyle(tint: tintColor))
        .disabled(!(model.isEnabled ?? true))
        .opacity((model.isEnabled ?? true) ? 1 : 0.5)
        #endif
    }
}

#if canImport(UIKit)
private struct SUISwitchControlRepresentable: UIViewRepresentable {
    let model: SwitchControlPresentableModel

    func makeUIView(context: Context) -> SwitchControl {
        let view = SwitchControl()
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: SwitchControl, context: Context) {
        uiView.display(model: model)
    }
}
#endif

#endif
