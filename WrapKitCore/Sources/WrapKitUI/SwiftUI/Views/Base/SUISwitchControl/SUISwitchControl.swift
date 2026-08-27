import SwiftUI

public struct SUISwitchControl: View {
    @StateObject private var stateModel: SUISwitchControlStateModel
    
    public init(adapter: SwitchCotrolOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }
    
    public var body: some View {
        if !stateModel.isHidden {
            SUISwitchControlView(
                isOn: stateModel.isOn,
                isEnabled: stateModel.isEnabled,
                isLoading: stateModel.isLoading,
                style: stateModel.style,
                accessibilityIdentifier: stateModel.accessibilityIdentifier,
                onToggle: { [weak stateModel] newValue in
                    guard let stateModel else { return }
                    stateModel.isOn = newValue
                    stateModel.onPress?(stateModel.adapter)
                }
            )
        }
    }
}

public struct SUISwitchControlView: View {
    let isOn: Bool
    let isEnabled: Bool
    let isLoading: Bool
    let style: SwitchControlPresentableModel.Style?
    let onToggle: ((Bool) -> Void)?
    let accessibilityIdentifier: String?
    
    public init(
        isOn: Bool,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        style: SwitchControlPresentableModel.Style? = nil,
        accessibilityIdentifier: String? = nil,
        onToggle: ((Bool) -> Void)? = nil,
    ) {
        self.isOn = isOn
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.style = style
        self.accessibilityIdentifier = accessibilityIdentifier
        self.onToggle = onToggle
        _internalIsOn = .init(initialValue: isOn)
    }
    
    @State private var internalIsOn: Bool
    
    public var body: some View {
        ZStack {
            styledToggle
                .accessibilityIdentifier(accessibilityIdentifier ?? "")
                .disabled(!isEnabled || isLoading)
                .opacity(isEnabled ? 1 : 0.5)
                .onAppear { internalIsOn = isOn }
                .onChange(of: isOn) { newValue in
                    internalIsOn = newValue
                }
            
            if isLoading {
                SUIShimmerView(style: style?.shimmerStyle)
                    .frame(
                        width: switchMetrics.width * 1.1,
                        height: switchMetrics.height
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: style?.cornerRadius ?? switchMetrics.height / 2,
                            style: .circular
                        )
                    )
                    .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    private var styledToggle: some View {
        if let style {
#if os(iOS)
            if #available(iOS 26.0, *) {
                toggle
                    .toggleStyle(.switch)
                    .tint(SwiftUIColor(style.tintColor))
                    .background {
                        RoundedRectangle(
                            cornerRadius: style.cornerRadius,
                            style: .continuous
                        )
                        .fill(SwiftUIColor(style.backgroundColor))
                    }
            } else {
                toggle
                    .toggleStyle(LegacySwitchToggleStyle(style: style))
            }
#else
            toggle
                .toggleStyle(.switch)
                .tint(SwiftUIColor(style.tintColor))
#endif
        } else {
            toggle
                .toggleStyle(.switch)
        }
    }

    private var toggle: some View {
        Toggle("", isOn: Binding(
            get: { internalIsOn },
            set: { newValue in
                internalIsOn = newValue
                onToggle?(newValue)
            }
        ))
        .labelsHidden()
    }

    private var switchMetrics: (width: CGFloat, height: CGFloat) {
#if os(iOS)
        if #available(iOS 26.0, *) {
            return (63, 28)
        }
#endif
        return (LegacySwitchToggleStyle.width, LegacySwitchToggleStyle.height)
    }
    
}

private struct LegacySwitchToggleStyle: ToggleStyle {
    static let width: CGFloat = 51
    static let height: CGFloat = 31

    @Environment(\.isEnabled) private var isEnabled

    private let thumbInset: CGFloat = 2
    private let style: SwitchControlPresentableModel.Style

    init(style: SwitchControlPresentableModel.Style) {
        self.style = style
    }

    func makeBody(configuration: Configuration) -> some View {
        let thumbSize = Self.height - thumbInset * 2
        let horizontalTravel = Self.width - thumbSize - thumbInset * 2

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: style.cornerRadius, style: .circular)
                .fill(SwiftUIColor(style.backgroundColor))

            RoundedRectangle(cornerRadius: Self.height / 2, style: .circular)
                .fill(trackColor(isOn: configuration.isOn))

            Circle()
                .fill(thumbColor)
                .frame(width: thumbSize, height: thumbSize)
                .shadow(color: .black.opacity(0.16), radius: 1, y: 1)
                .offset(x: thumbInset + (configuration.isOn ? horizontalTravel : 0))
        }
        .frame(width: Self.width, height: Self.height)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEnabled else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                configuration.isOn.toggle()
            }
        }
        .accessibilityValue(Text(configuration.isOn ? "1" : "0"))
    }

    private var thumbColor: SwiftUIColor {
        SwiftUIColor(style.thumbTintColor)
    }

    private func trackColor(isOn: Bool) -> SwiftUIColor {
        if isOn {
            return SwiftUIColor(style.tintColor)
        }
        return .gray.opacity(0.3)
    }
}

#Preview {
    SUISwitchControlView(isOn: true, isEnabled: true, isLoading: false, style: .init(tintColor: .red, thumbTintColor: .cyan, backgroundColor: .green, cornerRadius: 26), onToggle: nil)
}
