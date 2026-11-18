import SwiftUI
import WrapKit

@available(iOS 16.0, *)
struct KeyboardAccessoryFixture: View {
    enum Mode: String {
        case textField
        case textView
        case textFieldUnstyled

        init?(launchArguments: [String]) {
            let prefix = "--keyboard-accessory="
            guard let argument = launchArguments.first(where: { $0.hasPrefix(prefix) }),
                  let mode = Mode(rawValue: String(argument.dropFirst(prefix.count))) else {
                return nil
            }
            self = mode
        }
    }

    let mode: Mode
    @StateObject private var state: KeyboardAccessoryFixtureState

    init(mode: Mode) {
        self.mode = mode
        _state = .init(wrappedValue: .init(usesStyle: mode != .textFieldUnstyled))
    }

    var body: some View {
        NavigationStack {
            LifeCycleView(lifeCycleOutput: state) {
                VStack(spacing: 24) {
                    Text("Presses: \(state.pressCount)")
                        .accessibilityIdentifier("keyboardAccessory.pressCount")
                    if mode != .textView {
                        SUITextField(adapter: state.input, appearance: state.appearance)
                            .frame(height: 52)
                    } else {
                        SUITextView(adapter: state.input, appearance: state.appearance)
                            .frame(height: 120)
                    }
                    SwiftUI.Button("Disable accessory") {
                        state.displayAccessory(enabled: false)
                    }
                    .accessibilityIdentifier("keyboardAccessory.disable")
                    SwiftUI.Button("Enable accessory") {
                        state.displayAccessory(enabled: true)
                    }
                    .accessibilityIdentifier("keyboardAccessory.enable")
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Keyboard accessory")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

@available(iOS 16.0, *)
private final class KeyboardAccessoryFixtureState: ObservableObject, LifeCycleViewOutput {
    let input = TextInputOutputSwiftUIAdapter()
    @Published var pressCount = 0
    private let usesStyle: Bool

    init(usesStyle: Bool) {
        self.usesStyle = usesStyle
    }

    let appearance = TextfieldAppearance(
        colors: .init(
            textColor: .label,
            selectedBorderColor: .systemBlue,
            selectedBackgroundColor: .secondarySystemGroupedBackground,
            selectedErrorBorderColor: .systemRed,
            errorBorderColor: .systemRed,
            errorBackgroundColor: .secondarySystemGroupedBackground,
            deselectedBorderColor: .systemGray,
            deselectedBackgroundColor: .secondarySystemGroupedBackground,
            disabledTextColor: .systemGray,
            disabledBackgroundColor: .secondarySystemGroupedBackground
        ),
        font: .systemFont(ofSize: 18),
        border: .init(idleBorderWidth: 1, selectedBorderWidth: 1)
    )

    func viewDidLoad() {
        input.display(model: .init(accessibilityIdentifier: "keyboardAccessory.input", text: ""))
        input.display(inputType: .numberPad)
        displayAccessory(enabled: true)
    }

    func displayAccessory(enabled: Bool) {
        input.display(inputAccessoryView: .init(trailingButton: .init(
            accessibilityIdentifier: "keyboardAccessory.done",
            title: "Done",
            style: usesStyle ? .init(
                backgroundColor: .systemBlue,
                titleColor: .white,
                font: .systemFont(ofSize: 18, weight: .semibold),
                cornerStyle: .fixed(10),
                glassConfiguration: .glass
            ) : nil,
            enabled: enabled,
            onPress: { [weak self] in self?.pressCount += 1 }
        )))
    }
}
