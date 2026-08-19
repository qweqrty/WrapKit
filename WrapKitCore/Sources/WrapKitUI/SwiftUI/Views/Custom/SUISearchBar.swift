import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUISearchBar: View {
    @StateObject private var stateModel: SUISearchBarStateModel

    public init(
        adapter: SearchBarOutputSwiftUIAdapter,
        textFieldAppearance: TextfieldAppearance,
        spacing: CGFloat = 8,
        cornerRadius: CGFloat = 10,
        padding: SwiftUI.EdgeInsets = .init(top: 10, leading: 12, bottom: 10, trailing: 12)
    ) {
        _stateModel = .init(wrappedValue: .init(
            adapter: adapter,
            appearance: textFieldAppearance,
            spacing: spacing,
            cornerRadius: cornerRadius,
            padding: padding
        ))
    }

    public var body: some View {
        if !stateModel.isHidden {
            styledContent
        }
    }

    private var content: some View {
        HStack(alignment: .top, spacing: stateModel.spacing) {
            buttonView(stateModel.leftView)
            if !stateModel.isTextFieldHidden {
                SUITextField(
                    adapter: stateModel.textFieldAdapter,
                    appearance: stateModel.appearance,
                    contentInsets: stateModel.padding,
                    cornerStyle: .fixed(stateModel.cornerRadius)
                )
            }
            buttonView(stateModel.rightView)
        }
    }

    @ViewBuilder
    private var styledContent: some View {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *), isLiquidGlassEnabled {
            content
                .glassEffect(
                    .clear.tint(stateModel.backgroundColor.map(SwiftUIColor.init)),
                    in: SUICornerShape(style: .automatic)
                )
        } else {
            content
                .background(SwiftUIColor(stateModel.backgroundColor ?? .clear))
        }
    }

    @ViewBuilder
    private func buttonView(_ model: ButtonPresentableModel?) -> some View {
        if let model {
            SUIButtonView(
                model: model,
                onPress: model.onPress,
                isEnabled: model.enabled ?? true,
                fillsAvailableWidth: false
            )
            .frame(height: model.height ?? stateModel.textFieldHeight)
        }
    }
}
#endif
