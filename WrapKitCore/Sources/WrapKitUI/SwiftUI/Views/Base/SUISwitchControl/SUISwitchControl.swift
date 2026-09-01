import SwiftUI
#if os(iOS)
import UIKit
#endif

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
        styledToggle
            .opacity(isEnabled ? 1 : 0.5)
            .onAppear { internalIsOn = isOn }
            .onChange(of: isOn) { newValue in
                internalIsOn = newValue
            }
            .overlay(alignment: .leading) {
                if isLoading {
                    GeometryReader { geometry in
                        SUIShimmerView(style: style?.shimmerStyle)
                            .frame(
                                width: geometry.size.width * 1.1,
                                height: geometry.size.height
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: style?.cornerRadius ?? geometry.size.height / 2,
                                    style: .circular
                                )
                            )
                    }
                    .allowsHitTesting(false)
                }
            }
    }

    @ViewBuilder
    private var styledToggle: some View {
#if os(iOS)
        if #available(iOS 26.0, *) {
            SUINativeSwitchView(
                isOn: $internalIsOn,
                isEnabled: isEnabled && !isLoading,
                style: style,
                accessibilityIdentifier: accessibilityIdentifier,
                onToggle: onToggle
            )
        } else if let style {
            toggle
                .toggleStyle(LegacySwitchToggleStyle(style: style))
                .accessibilityIdentifier(accessibilityIdentifier ?? "")
                .disabled(!isEnabled || isLoading)
        } else {
            toggle
                .toggleStyle(.switch)
                .accessibilityIdentifier(accessibilityIdentifier ?? "")
                .disabled(!isEnabled || isLoading)
        }
#else
        if let style {
            toggle
                .toggleStyle(.switch)
                .tint(SwiftUIColor(style.tintColor))
                .accessibilityIdentifier(accessibilityIdentifier ?? "")
                .disabled(!isEnabled || isLoading)
        } else {
            toggle
                .toggleStyle(.switch)
                .accessibilityIdentifier(accessibilityIdentifier ?? "")
                .disabled(!isEnabled || isLoading)
        }
#endif
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

}

#if os(iOS)
@available(iOS 26.0, *)
private struct SUINativeSwitchView: UIViewRepresentable {
    @Binding var isOn: Bool

    let isEnabled: Bool
    let style: SwitchControlPresentableModel.Style?
    let accessibilityIdentifier: String?
    let onToggle: ((Bool) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> SUINativeSwitchContainer {
        let container = SUINativeSwitchContainer()
        container.nativeSwitch.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        applyState(to: container.nativeSwitch)
        return container
    }

    func updateUIView(_ container: SUINativeSwitchContainer, context: Context) {
        context.coordinator.parent = self
        applyState(to: container.nativeSwitch)
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: SUINativeSwitchContainer,
        context: Context
    ) -> CGSize? {
        uiView.nativeSwitch.intrinsicContentSize
    }

    private func applyState(to nativeSwitch: UISwitch) {
        if !nativeSwitch.isTracking, nativeSwitch.isOn != isOn {
            nativeSwitch.setOn(isOn, animated: false)
        }
        nativeSwitch.isEnabled = isEnabled
        nativeSwitch.accessibilityIdentifier = accessibilityIdentifier
        nativeSwitch.onTintColor = style?.tintColor
        nativeSwitch.thumbTintColor = style?.thumbTintColor
        nativeSwitch.backgroundColor = style?.backgroundColor
        nativeSwitch.applyCornerStyle(.fixed(style?.cornerRadius ?? 0))
    }

    final class Coordinator: NSObject {
        var parent: SUINativeSwitchView

        init(parent: SUINativeSwitchView) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: UISwitch) {
            parent.isOn = sender.isOn
            parent.onToggle?(sender.isOn)
        }
    }
}

@available(iOS 26.0, *)
private final class SUINativeSwitchContainer: UIView {
    let nativeSwitch = UISwitch(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = false
        addSubview(nativeSwitch)
        accessibilityElements = [nativeSwitch]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        nativeSwitch.intrinsicContentSize
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        nativeSwitch.intrinsicContentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let alignmentSize = nativeSwitch.intrinsicContentSize
        let alignmentRect = CGRect(
            x: bounds.midX - alignmentSize.width / 2,
            y: bounds.midY - alignmentSize.height / 2,
            width: alignmentSize.width,
            height: alignmentSize.height
        )
        nativeSwitch.frame = nativeSwitch.frame(forAlignmentRect: alignmentRect)
    }
}
#endif

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
