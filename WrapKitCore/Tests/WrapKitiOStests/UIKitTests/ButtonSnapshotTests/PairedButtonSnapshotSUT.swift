import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedButtonSnapshotSUT {
    let uiKitButton: WrapKit.Button
    private let swiftUIAdapter: ButtonOutputSwiftUIAdapter
    private let loadingAdapter: LoadingOutputSwiftUIAdapter
    private var lastStyle: WrapKit.ButtonStyle?

    init(
        uiKitButton: WrapKit.Button = WrapKit.Button(),
        swiftUIAdapter: ButtonOutputSwiftUIAdapter = ButtonOutputSwiftUIAdapter(),
        loadingAdapter: LoadingOutputSwiftUIAdapter = LoadingOutputSwiftUIAdapter()
    ) {
        self.uiKitButton = uiKitButton
        self.swiftUIAdapter = swiftUIAdapter
        self.loadingAdapter = loadingAdapter
    }

    var onPress: (() -> Void)? {
        get { uiKitButton.onPress }
        set {
            uiKitButton.onPress = newValue
            swiftUIAdapter.display(onPress: newValue)
        }
    }

    var backgroundColor: UIColor? {
        get { uiKitButton.backgroundColor }
        set {
            uiKitButton.backgroundColor = newValue
            if let style = lastStyle {
                let updated = WrapKit.ButtonStyle(
                    backgroundColor: newValue,
                    gradientColors: style.gradientColors,
                    titleColor: style.titleColor,
                    borderWidth: style.borderWidth,
                    borderColor: style.borderColor,
                    pressedColor: style.pressedColor,
                    pressedTintColor: style.pressedTintColor,
                    font: style.font,
                    cornerRadius: style.cornerRadius,
                    wrongUrlPlaceholderImage: style.wrongUrlPlaceholderImage,
                    loadingIndicatorColor: style.loadingIndicatorColor
                )
                swiftUIAdapter.display(style: updated)
            }
        }
    }

    var wrongUrlPlaceholderImage: UIImage? {
        get { uiKitButton.wrongUrlPlaceholderImage }
        set { uiKitButton.wrongUrlPlaceholderImage = newValue }
    }

    func display(model: ButtonPresentableModel?) {
        uiKitButton.display(model: model)
        swiftUIAdapter.display(model: model)
    }

    func display(title: String?) {
        uiKitButton.display(title: title)
        swiftUIAdapter.display(title: title)
    }

    func display(image: UIImage?) {
        uiKitButton.display(image: image)
        swiftUIAdapter.display(image: image)
    }

    func display(style: WrapKit.ButtonStyle?) {
        lastStyle = style
        uiKitButton.display(style: style)
        swiftUIAdapter.display(style: style)
    }

    func display(enabled: Bool) {
        uiKitButton.display(enabled: enabled)
        swiftUIAdapter.display(enabled: enabled)
    }

    func display(isHidden: Bool) {
        uiKitButton.display(isHidden: isHidden)
        swiftUIAdapter.display(isHidden: isHidden)
    }

    func display(isLoading: Bool) {
        uiKitButton.display(isLoading: isLoading)
        loadingAdapter.display(isLoading: isLoading)
    }

    func display(_ onPress: (() -> Void)?) {
        uiKitButton.display(onPress: onPress)
        swiftUIAdapter.display(onPress: onPress)
    }

    func setImage(_ imageEnum: ImageEnum, completion: ((WrapKit.Image?) -> Void)?) {
        uiKitButton.setImage(imageEnum, completion: completion)
        switch imageEnum {
        case .asset(let image):
            swiftUIAdapter.display(image: image)
        case .url, .urlString, .data:
            break
        }
    }

    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        uiKitButton.touchesBegan(touches, with: event)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        
        swiftUIAdapter.display(height: 60)
        
        let rootView = SnapshotMirroredButtonContainer(
            adapter: swiftUIAdapter,
            loadingAdapter: loadingAdapter
        )
        .environment(\.colorScheme, colorScheme)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        hostingController.view.backgroundColor = .clear

        let warmup: TimeInterval = 0.3
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return hostingController.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredButtonContainer: View {
    let adapter: ButtonOutputSwiftUIAdapter
    let loadingAdapter: LoadingOutputSwiftUIAdapter

    var body: some View {
        VStack(spacing: 0) {
            SUIButton(adapter: adapter, loadingAdapter: loadingAdapter)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.clear)
        .ignoresSafeArea(.all)
    }
}
#endif
