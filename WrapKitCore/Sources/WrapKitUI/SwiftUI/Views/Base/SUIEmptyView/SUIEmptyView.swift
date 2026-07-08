import SwiftUI

private final class SUIEmptyViewContentAdapters: ObservableObject {
    let image = ImageViewOutputSwiftUIAdapter()
    let title = TextOutputSwiftUIAdapter()
    let subtitle = TextOutputSwiftUIAdapter()
    let button = ButtonOutputSwiftUIAdapter()
}

public struct SUIEmptyView: View {
    @ObservedObject var stateModel: SUIEmptyViewStateModel

    public init(adapter: EmptyViewOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }

    public var body: some View {
        SUIEmptyViewContent(
            title: stateModel.title,
            subtitle: stateModel.subtitle,
            buttonModel: stateModel.buttonModel,
            image: stateModel.image
        )
        .opacity(stateModel.isHidden ? 0 : 1)
        .animation(
            stateModel.animationConfig.isAnimated
                ? .easeInOut(duration: stateModel.animationConfig.duration)
                : .none,
            value: stateModel.isHidden
        )
    }
}

public struct SUIEmptyViewContent: View {
    let title: TextOutputPresentableModel?
    let subtitle: TextOutputPresentableModel?
    let buttonModel: ButtonPresentableModel?
    let image: ImageViewPresentableModel?

    public init(
        title: TextOutputPresentableModel? = nil,
        subtitle: TextOutputPresentableModel? = nil,
        buttonModel: ButtonPresentableModel? = nil,
        image: ImageViewPresentableModel? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonModel = buttonModel
        self.image = image
    }

    public var body: some View {
        VStack(spacing: 16) {
            if let image {
                // SUIImageView требует adapter — пропустим пока или используем placeholder
                // TODO: сделать SUIImageViewContent который принимает модель напрямую
            }
            if let title {
                SUILabelView(model: title)
            }
            if let subtitle {
                SUILabelView(model: subtitle)
            }
            if let buttonModel {
                SUIButtonView(
                    model: buttonModel,
                    onPress: buttonModel.onPress,
                    isEnabled: true
                )
            }
        }
        .padding(12)
    }
}
