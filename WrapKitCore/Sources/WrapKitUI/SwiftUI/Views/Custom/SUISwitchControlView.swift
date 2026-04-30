import Foundation

#if canImport(SwiftUI)
import SwiftUI

struct SUISwitchControlView: View {
    let model: SwitchControlPresentableModel

    var body: some View {
        let tintColor = SwiftUIColor(model.style?.tintColor ?? .systemGreen)
        Toggle(isOn: .constant(model.isOn ?? false)) {
            SwiftUI.EmptyView()
        }
        .labelsHidden()
        .toggleStyle(SwitchToggleStyle(tint: tintColor))
        .disabled(true)
        .opacity((model.isEnabled ?? true) ? 1 : 0.5)
        .allowsHitTesting(false)
    }
}

#endif
