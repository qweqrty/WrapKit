import SwiftUI
import SwiftUIIntrospect

public struct SUISwitchControl: View {
    @ObservedObject var stateModel: SUISwitchControlStateModel
    
    public init(adapter: SwitchCotrolOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }
    
    public var body: some View {
        if !stateModel.isHidden {
            SUISwitchControlView(
                isOn: stateModel.isOn,
                isEnabled: stateModel.isEnabled,
                isLoading: stateModel.isLoading,
                style: stateModel.style,
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
    
    public init(
        isOn: Bool,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        style: SwitchControlPresentableModel.Style? = nil,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self.isOn = isOn
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.style = style
        self.onToggle = onToggle
    }
    
    @State private var internalIsOn: Bool = false
    @State private var toggleSize: CGSize = CGSize(width: 51, height: 31)
    
    public var body: some View {
        ZStack {
            Toggle("", isOn: Binding(
                get: { internalIsOn },
                set: { newValue in
                    internalIsOn = newValue
                    onToggle?(newValue)
                }
            ))
            .labelsHidden()
            .if(true, modifier: { view in
                if #available(iOS 16.0, *) {
                    view.tint(style.map { SwiftUIColor($0.tintColor) })
                } else {
                    view.accentColor(style.map { SwiftUIColor($0.tintColor) })
                }
            })
            .toggleStyle(.switch)
            .introspect(.toggle, on: .iOS(.v15, .v26)) { view in
                view.thumbTintColor = style?.thumbTintColor
                view.backgroundColor = style?.backgroundColor
                view.layer.cornerRadius = style?.cornerRadius ?? 16
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.5)
            .onAppear { internalIsOn = isOn }
            .onChange(of: isOn) { newValue in
                internalIsOn = newValue
            }
            .overlay(
                GeometryReader { geo in
                    SwiftUI.Color.clear
                        .onAppear { toggleSize = geo.size }
                        .onChange(of: geo.size) { newSize in
                            toggleSize = newSize
                        }
                }
            )
            
            if isLoading {
                SUIShimmerView(style: style?.shimmerStyle)
                    .frame(width: toggleSize.width * 1.1, height: toggleSize.height)
                    .cornerRadius(style?.cornerRadius ?? 16)
            }
        }
    }
    
}

#Preview {
    SUISwitchControlView(isOn: true, isEnabled: true, isLoading: false, style: .init(tintColor: .red, thumbTintColor: .cyan, backgroundColor: .green, cornerRadius: 26), onToggle: nil)
}
