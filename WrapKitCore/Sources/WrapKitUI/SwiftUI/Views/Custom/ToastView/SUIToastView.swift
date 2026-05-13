import Foundation

#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct SUIToastView: View {
    @StateObject private var stateModel: SUIToastViewStateModel

    public init(adapter: CommonToastOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let item = stateModel.currentItem {
                    positionedToast(item, proxy: proxy)
                        .transition(transition(for: item.position))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(stateModel.currentItem != nil)
        }
    }

    @ViewBuilder
    private func positionedToast(_ item: SUIToastViewStateModel.ToastItem, proxy: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            if item.position == .top {
                toastContent(item)
                    .padding(.top, proxy.safeAreaInsets.top + 20)
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 0)
                toastContent(item)
                    .padding(.bottom, bottomPadding(for: item.position, proxy: proxy))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toastContent(_ item: SUIToastViewStateModel.ToastItem) -> some View {
        toastCardView
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .background(SwiftUIColor.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(
                color: shadowColor(item.shadowColor),
                radius: item.shadowColor == nil ? 0 : 4,
                x: -0.5,
                y: -0.5
            )
            .padding(.horizontal, 8)
            .offset(stateModel.dragOffset)
            .scaleEffect(stateModel.scale)
            .opacity(stateModel.opacity)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .zIndex(100)
            .simultaneousGesture(dragGesture)
            .onLongPressGesture(
                minimumDuration: 0.5,
                pressing: { isPressing in
                    isPressing ? stateModel.beginLongPress() : stateModel.endLongPress()
                },
                perform: {}
            )
            .onAppear {
                stateModel.displayCurrentCardModel()
            }
    }

    @ViewBuilder
    private var toastCardView: some View {
        #if canImport(UIKit)
        SUIToastCardRepresentable(model: stateModel.currentCardModel)
        #else
        SUICardView(adapter: stateModel.cardAdapter)
        #endif
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                stateModel.pauseTimer()
                stateModel.updateDrag(value.translation)
            }
            .onEnded { value in
                stateModel.finishDrag(
                    value.translation,
                    velocity: .init(width: value.predictedEndTranslation.width, height: value.predictedEndTranslation.height)
                )
            }
    }

    private func bottomPadding(for position: CommonToast.Position, proxy: GeometryProxy) -> CGFloat {
        switch position {
        case .top:
            return 0
        case .bottom(let additionalBottomPadding):
            return proxy.safeAreaInsets.bottom + stateModel.keyboardHeight + additionalBottomPadding + 24
        }
    }

    private func transition(for position: CommonToast.Position) -> AnyTransition {
        switch position {
        case .top:
            return .move(edge: .top).combined(with: .opacity)
        case .bottom:
            return .move(edge: .bottom).combined(with: .opacity)
        }
    }

    private func shadowColor(_ color: Color?) -> SwiftUIColor {
        guard let color else { return .clear }
        return SwiftUIColor(color).opacity(0.07)
    }
}

public extension View {
    func toastView(adapter: CommonToastOutputSwiftUIAdapter) -> some View {
        overlay(SUIToastView(adapter: adapter))
    }
}

#if canImport(UIKit)
private struct SUIToastCardRepresentable: UIViewRepresentable {
    let model: CardViewPresentableModel?

    func makeUIView(context: Context) -> CardView {
        let view = CardView()
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: CardView, context: Context) {
        uiView.display(model: model)
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
    }

    @available(iOS 16.0, tvOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: CardView, context: Context) -> CGSize? {
        guard model != nil else { return .zero }

        uiView.display(model: model)
        let fittingWidth = max(proposal.width ?? UIScreen.main.bounds.width - 16, 1)
        let targetSize = CGSize(width: fittingWidth, height: UIView.layoutFittingCompressedSize.height)
        let size = uiView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: fittingWidth, height: max(52, ceil(size.height)))
    }
}
#endif

#endif
