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
            HStack(alignment: .top, spacing: stateModel.spacing) {
                buttonView(stateModel.leftView)
                if !stateModel.isTextFieldHidden {
                    textFieldView
                }
                buttonView(stateModel.rightView)
            }
            .background(SwiftUIColor(stateModel.backgroundColor ?? .clear))
        }
    }

    private var textFieldView: some View {
        ZStack(alignment: .leading) {
            if let text = stateModel.textField?.text, !text.isEmpty {
                Text(text.removingPercentEncoding ?? text)
                    .font(SwiftUIFont(stateModel.appearance.font))
                    .foregroundColor(SwiftUIColor(stateModel.appearance.colors.textColor))
                    .lineLimit(1)
            } else {
                placeholderView
            }
        }
        .padding(stateModel.padding)
        .frame(
            maxWidth: .infinity,
            minHeight: stateModel.textFieldHeight,
            alignment: .leading
        )
        .background(SwiftUIColor(stateModel.appearance.colors.deselectedBackgroundColor))
        .cornerRadius(stateModel.cornerRadius)
        .overlay(textFieldBorder)
    }

    @ViewBuilder
    private var placeholderView: some View {
        let placeholder = stateModel.appearance.placeholder?.text ?? stateModel.textField?.placeholder ?? stateModel.placeholder
        if let placeholder, !placeholder.isEmpty {
            Text(placeholder.removingPercentEncoding ?? placeholder)
                .font(SwiftUIFont(stateModel.appearance.placeholder?.font ?? stateModel.appearance.font))
                .foregroundColor(SwiftUIColor(stateModel.appearance.placeholder?.color ?? stateModel.appearance.colors.textColor))
                .lineLimit(1)
        }
    }

    private var textFieldBorder: some View {
        RoundedRectangle(cornerRadius: stateModel.cornerRadius)
            .stroke(
                SwiftUIColor(stateModel.appearance.colors.deselectedBorderColor),
                lineWidth: stateModel.appearance.border?.idleBorderWidth ?? 0
            )
    }

    @ViewBuilder
    private func buttonView(_ model: ButtonPresentableModel?) -> some View {
        if let model {
            let title = model.title?.removingPercentEncoding ?? model.title ?? ""
            let font = model.style?.font ?? Font.systemFont(ofSize: Font.buttonFontSize)
            Text(title)
                .font(SwiftUIFont(font))
                .foregroundColor(SwiftUIColor(model.style?.titleColor ?? .systemBlue))
                .lineLimit(1)
                .frame(
                    width: model.width,
                    height: model.height ?? stateModel.textFieldHeight,
                    alignment: .center
                )
                .background(SwiftUIColor(model.style?.backgroundColor ?? .clear))
                .cornerRadius(model.style?.cornerRadius ?? 0)
                .overlay(buttonBorder(model.style))
                .opacity(model.enabled == false ? 0.5 : 1)
        }
    }

    private func buttonBorder(_ style: ButtonStyle?) -> some View {
        RoundedRectangle(cornerRadius: style?.cornerRadius ?? 0)
            .stroke(
                SwiftUIColor(style?.borderColor ?? .clear),
                lineWidth: style?.borderWidth ?? 0
            )
    }
}
#endif
