import SwiftUI

public struct SUIEmptyView: View {
    @StateObject var stateModel: SUIEmptyViewStateModel

    public init(adapter: EmptyViewOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        Group {
            if !stateModel.isHidden {
                SUIEmptyViewContent(
                    title: stateModel.title,
                    subtitle: stateModel.subtitle,
                    titleStateModel: stateModel.titleStateModel,
                    subtitleStateModel: stateModel.subtitleStateModel,
                    imageAdapter: stateModel.imageAdapter,
                    buttonModel: stateModel.buttonModel,
                    image: stateModel.image,
                    isTitleHidden: stateModel.isTitleHidden,
                    isSubtitleHidden: stateModel.isSubtitleHidden,
                    isButtonHidden: stateModel.isButtonHidden,
                    isImageHidden: stateModel.isImageHidden
                )
            }
        }
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
    let titleStateModel: SUILabelStateModel?
    let subtitleStateModel: SUILabelStateModel?
    let imageAdapter: ImageViewOutputSwiftUIAdapter?
    let buttonModel: ButtonPresentableModel?
    let image: ImageViewPresentableModel?
    let isTitleHidden: Bool
    let isSubtitleHidden: Bool
    let isButtonHidden: Bool
    let isImageHidden: Bool

    public init(
        title: TextOutputPresentableModel? = nil,
        subtitle: TextOutputPresentableModel? = nil,
        buttonModel: ButtonPresentableModel? = nil,
        image: ImageViewPresentableModel? = nil,
        isTitleHidden: Bool = false,
        isSubtitleHidden: Bool = false,
        isButtonHidden: Bool = false,
        isImageHidden: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        titleStateModel = nil
        subtitleStateModel = nil
        imageAdapter = nil
        self.buttonModel = buttonModel
        self.image = image
        self.isTitleHidden = isTitleHidden
        self.isSubtitleHidden = isSubtitleHidden
        self.isButtonHidden = isButtonHidden
        self.isImageHidden = isImageHidden
    }

    init(
        title: TextOutputPresentableModel?,
        subtitle: TextOutputPresentableModel?,
        titleStateModel: SUILabelStateModel,
        subtitleStateModel: SUILabelStateModel,
        imageAdapter: ImageViewOutputSwiftUIAdapter,
        buttonModel: ButtonPresentableModel?,
        image: ImageViewPresentableModel?,
        isTitleHidden: Bool,
        isSubtitleHidden: Bool,
        isButtonHidden: Bool,
        isImageHidden: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.titleStateModel = titleStateModel
        self.subtitleStateModel = subtitleStateModel
        self.imageAdapter = imageAdapter
        self.buttonModel = buttonModel
        self.image = image
        self.isTitleHidden = isTitleHidden
        self.isSubtitleHidden = isSubtitleHidden
        self.isButtonHidden = isButtonHidden
        self.isImageHidden = isImageHidden
    }

    public var body: some View {
        VStack(spacing: 16) {
            if !isImageHidden {
                if let image {
                    if let imageAdapter {
                        SUIImageView(adapter: imageAdapter)
                    } else {
                        SUIImageViewView(model: image)
                    }
                } else {
                    SwiftUIColor.clear.frame(height: 0)
                }
            }
            if !isTitleHidden {
                if let title {
                    emptyLabel(title, stateModel: titleStateModel)
                } else {
                    SwiftUIColor.clear.frame(height: 0)
                }
            }
            if !isSubtitleHidden {
                if let subtitle {
                    emptyLabel(subtitle, stateModel: subtitleStateModel)
                } else {
                    SwiftUIColor.clear.frame(height: 0)
                }
            }
            if !isButtonHidden {
                let effectiveButtonModel = buttonModel ?? .init()
                SUIButtonView(
                    model: effectiveButtonModel,
                    onPress: effectiveButtonModel.onPress,
                    isEnabled: effectiveButtonModel.enabled ?? true,
                    fillsAvailableHeight: false
                )
                .frame(minHeight: systemButtonMinimumHeight)
            }
        }
        .padding(12)
    }

    private func emptyLabel(
        _ model: TextOutputPresentableModel,
        stateModel: SUILabelStateModel?
    ) -> some View {
        Group {
            if let stateModel {
                SUIOutputLabel(
                    stateModel: stateModel,
                    font: .systemFont(ofSize: 20),
                    textColor: .label,
                    textAlignment: .center
                )
            } else {
                SUILabelView(
                    model: model,
                    font: .systemFont(ofSize: 20),
                    textColor: .label,
                    textAlignment: .center
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var systemButtonMinimumHeight: CGFloat? {
        guard buttonModel?.title != nil else {
            // An empty UIButton keeps its regular control height.
            return 34
        }
        guard isAvailableOS26 else { return nil }
        // UIButton rounds its title label's line height to whole points for intrinsic sizing.
        let font = buttonModel?.style?.font ?? .systemFont(ofSize: 18)
        return ceil(font.lineHeight)
    }
}
