import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUISearchBar: View {
    @StateObject private var stateModel: SUISearchBarStateModel
    private let contentInsets: EdgeInsets

    /// `padding` controls the text field's internal padding, while `contentInsets`
    /// inset the complete row of side controls and text field.
    public init(
        adapter: SearchBarOutputSwiftUIAdapter,
        textFieldAppearance: TextfieldAppearance,
        spacing: CGFloat = 8,
        cornerRadius: CGFloat = 10,
        padding: SwiftUI.EdgeInsets = .init(top: 10, leading: 12, bottom: 10, trailing: 12),
        contentInsets: EdgeInsets = .zero
    ) {
        _stateModel = .init(wrappedValue: .init(
            adapter: adapter,
            appearance: textFieldAppearance,
            spacing: spacing,
            cornerRadius: cornerRadius,
            padding: padding
        ))
        self.contentInsets = contentInsets
    }

    init(
        stateModel: SUISearchBarStateModel,
        contentInsets: EdgeInsets = .zero
    ) {
        _stateModel = .init(wrappedValue: stateModel)
        self.contentInsets = contentInsets
    }

    public var body: some View {
        if !stateModel.isHidden {
            styledContent
        }
    }

    private var content: some View {
        HStack(alignment: .top, spacing: stateModel.spacing) {
            buttonView(
                stateModel.leftButtonStateModel,
                isPresented: stateModel.leftView != nil
            )
            if !stateModel.isTextFieldHidden {
                SUITextField(
                    adapter: stateModel.textFieldAdapter,
                    appearance: stateModel.appearance,
                    contentInsets: stateModel.padding,
                    cornerStyle: .fixed(stateModel.cornerRadius)
                )
            }
            buttonView(
                stateModel.rightButtonStateModel,
                isPresented: stateModel.rightView != nil
            )
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var styledContent: some View {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *), isLiquidGlassEnabled {
            content
                .padding(contentInsets.asSUIEdgeInsets)
                .glassEffect(
                    .clear.tint(stateModel.backgroundColor.map(SwiftUIColor.init)),
                    in: SUICornerShape(style: .automatic)
                )
        } else {
            content
                .padding(contentInsets.asSUIEdgeInsets)
                .background(SwiftUIColor(stateModel.backgroundColor ?? .clear))
        }
    }

    @ViewBuilder
    private func buttonView(
        _ buttonStateModel: SUIButtonStateModel,
        isPresented: Bool
    ) -> some View {
        if isPresented {
            SUISearchBarButton(stateModel: buttonStateModel)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

private struct SUISearchBarButton: View {
    @ObservedObject var stateModel: SUIButtonStateModel

    var body: some View {
        roundedIntrinsicWidthButton
            .frame(height: stateModel.presentable.height)
            .frame(maxHeight: stateModel.presentable.height == nil ? .infinity : nil)
    }

    @ViewBuilder
    private var roundedIntrinsicWidthButton: some View {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            WholePointRoundedWidthLayout {
                button(fillsAvailableWidth: true)
            }
        } else {
            button(fillsAvailableWidth: false)
        }
    }

    private func button(fillsAvailableWidth: Bool) -> some View {
        SUIButtonView(
            model: stateModel.presentable,
            onPress: stateModel.presentable.onPress,
            isEnabled: stateModel.isEnabled,
            fillsAvailableWidth: fillsAvailableWidth
        )
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
private struct WholePointRoundedWidthLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else { return .zero }
        let size = subview.sizeThatFits(.init(width: nil, height: nil))
        let proposedHeight = proposal.height.flatMap { $0.isFinite ? $0 : nil }
        return .init(width: ceil(size.width), height: proposedHeight ?? size.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal _: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        subviews.first?.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: .init(width: bounds.width, height: bounds.height)
        )
    }
}
#endif
