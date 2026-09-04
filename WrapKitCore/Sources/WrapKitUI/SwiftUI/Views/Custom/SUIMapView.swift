import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIMapView: View {
    @ObservedObject private var stateModel: SUIMapViewStateModel

    public init(stateModel: SUIMapViewStateModel) {
        self.stateModel = stateModel
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            contentView

            VStack(spacing: 10) {
                if !stateModel.locationButton.isHidden {
                    controlButton(stateModel.locationButton, cornerRadius: 8)
                }

                if !stateModel.isActionsHidden {
                    actionsView
                }
            }
            .padding(.trailing, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    @ViewBuilder
    private var contentView: some View {
        switch stateModel.content {
        case .color(let color):
            SwiftUIColor(color)
        case .gradient(let colors):
            LinearGradient(
                colors: colors.map(SwiftUIColor.init),
                startPoint: .top,
                endPoint: .bottom
            )
        case .image(let image):
            SwiftUIImage(image: image)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .pins(let backgroundColor, let alpha):
            ZStack(alignment: .topLeading) {
                SwiftUIColor(backgroundColor)
                    .opacity(alpha)

                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(SwiftUIColor(.systemRed))
                        .frame(width: 20, height: 20)
                        .offset(
                            x: CGFloat(50 + index * 60),
                            y: CGFloat(30 + index * 40)
                        )
                }
            }
        }
    }

    private var actionsView: some View {
        VStack(spacing: 0) {
            controlButton(stateModel.plusButton, cornerRadius: 0)

            if !stateModel.isSeparatorHidden {
                SwiftUIColor(stateModel.separatorColor)
                    .frame(height: 2)
            }

            controlButton(stateModel.minusButton, cornerRadius: 0)
        }
        .background(SwiftUIColor(stateModel.actionsBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(width: 36)
    }

    private func controlButton(_ state: SUIMapViewButtonState, cornerRadius: CGFloat) -> some View {
        SwiftUIColor(state.backgroundColor)
            .frame(width: 36, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        SwiftUIColor(state.borderColor ?? .clear),
                        lineWidth: state.borderWidth
                    )
            )
    }
}
#endif
