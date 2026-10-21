import SwiftUI
import WrapKit

@available(iOS 26.0, *)
struct GlassButtonScrollFixture: View {
    enum Mode: String {
        case native
        case wrapKit
        case wrapKitShrink

        init?(launchArguments: [String]) {
            guard let argument = launchArguments.first(where: { $0.hasPrefix("--glass-button-scroll=") }),
                  let mode = Mode(rawValue: String(argument.dropFirst("--glass-button-scroll=".count))) else {
                return nil
            }
            self = mode
        }
    }

    let mode: Mode
    @State private var pressCount = 0

    var body: some View {
        VStack(spacing: 0) {
            Text("Presses: \(pressCount)")
                .accessibilityIdentifier("glassScroll.pressCount")
                .padding()
            ScrollView {
                VStack(spacing: 48) {
                    ForEach(0..<12) { index in
                        VStack(spacing: 20) {
                            Text("Row \(index)")
                            scrollButton(index: index)
                                .frame(height: 48)
                        }
                        .padding(.vertical, 36)
                    }
                }
                .padding(.horizontal, 16)
            }
            .accessibilityIdentifier("glassScroll.scrollView")
        }
    }

    @ViewBuilder
    private func scrollButton(index: Int) -> some View {
        switch mode {
        case .native:
            SwiftUI.Button {
                pressCount += 1
            } label: {
                Text("Button \(index)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .tint(.blue)
                .accessibilityIdentifier("glassScroll.button.\(index)")
        case .wrapKit, .wrapKitShrink:
            SUIButtonView(
                model: .init(
                    accessibilityIdentifier: "glassScroll.button.\(index)",
                    title: "Button \(index)",
                    height: 48,
                    style: .init(
                        backgroundColor: .blue,
                        titleColor: .white,
                        pressedColor: .red,
                        pressedTintColor: .white,
                        glassConfiguration: .glass
                    )
                ),
                onPress: { pressCount += 1 },
                isEnabled: true,
                pressAnimations: mode == .wrapKitShrink ? [.shrink] : [],
                fillsAvailableHeight: false
            )
        }
    }
}
