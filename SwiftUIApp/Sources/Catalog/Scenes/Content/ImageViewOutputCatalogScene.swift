import SwiftUI
import WrapKit

enum ImageViewOutputCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let adapters = ImageViewOutputCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = ImageViewOutputCatalogPresenter(onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.output = adapters.output.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }
        presenter.actionOutputs = adapters.actions.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(
            ImageViewOutputCatalogView(
                presenter: presenter,
                adapters: adapters,
                chrome: chrome
            )
        )
    }
}

private final class ImageViewOutputCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var output: ImageViewOutput?
    var statusOutput: TextOutput?
    var settingOutputs: [ImageCatalogSetting: CardViewOutput] = [:]
    var actionOutputs: [ImageViewOutputCatalogAction: ButtonOutput] = [:]

    private let onBack: () -> Void
    private var didLoad = false
    private var settingStates = Dictionary(
        uniqueKeysWithValues: ImageCatalogSetting.allCases.map { ($0, $0.initialIsOn) }
    )

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(
            model: CatalogAppearance.header(title: "ImageViewOutput", onBack: onBack)
        )
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureActions()
        showSystemImage()
        configureSettingRows()
    }

    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
    func viewDidLayoutSubviews() {}

    private func configureActions() {
        ImageViewOutputCatalogAction.allCases.forEach { action in
            actionOutputs[action]?.display(
                model: CatalogAppearance.actionButton(
                    id: "catalog.content.image.\(action.rawValue)",
                    title: action.title,
                    onPress: { [weak self] in self?.perform(action) }
                )
            )
        }
    }

    private func perform(_ action: ImageViewOutputCatalogAction) {
        switch action {
        case .systemImage: showSystemImage()
        case .dataImage: showDataImage()
        case .invalidDataImage: showInvalidDataImage()
        case .lightOnlyRemoteImage: showRemoteImage(lightURL: Self.lightImageURL, darkURL: nil)
        case .darkOnlyRemoteImage: showRemoteImage(lightURL: nil, darkURL: Self.darkImageURL)
        case .lightDarkRemoteImage:
            showRemoteImage(lightURL: Self.lightImageURL, darkURL: Self.darkImageURL)
        case .clearOptionalValues: clearOptionalValues()
        }
    }

    private func clearOptionalValues() {
        output?.display(image: nil, completion: { [weak self] image in
            self?.statusOutput?.display(
                text: image == nil
                    ? "image:nil and optional nil values were sent"
                    : "Unexpected image returned"
            )
        })
        output?.display(size: nil)
        output?.display(borderWidth: nil)
        output?.display(borderColor: nil)
        output?.display(cornerRadius: nil)
        output?.display(alpha: nil)
        statusOutput?.display(text: "Sending image:nil and optional nil values")
    }

    private func showSystemImage() {
        output?.display(
            model: .systemSymbol(
                "person.crop.square.fill",
                accessibilityIdentifier: "content.image.target",
                size: currentSize,
                onPress: currentOnPress,
                onLongPress: currentOnLongPress,
                contentModeIsFit: settingStates[.contentMode] != true,
                borderWidth: settingStates[.borderWidth] == true ? 6 : 2,
                borderColor: settingStates[.borderColor] == true ? .systemBlue : .separator,
                cornerRadius: settingStates[.cornerRadius] == true ? 52 : 16,
                alpha: settingStates[.alpha] == true ? 0.35 : 1
            ),
            completion: { [weak self] image in
                self?.statusOutput?.display(
                    text: image == nil ? "Model: SF Symbol · failed" : "Model: SF Symbol · ready"
                )
            }
        )
        output?.display(isHidden: settingStates[.hidden] == true)
        statusOutput?.display(text: "SF Symbol is ready")
    }

    private func showDataImage() {
        let data = Data(base64Encoded: Self.gradientPNGData)
        output?.display(image: .data(data), completion: { [weak self] image in
            self?.statusOutput?.display(
                text: image == nil ? "Image: PNG data · failed" : "Image: PNG data · decoded"
            )
        })
        statusOutput?.display(text: "Decoding an in-memory PNG through ImageViewOutput")
    }

    private func showInvalidDataImage() {
        output?.display(image: .data(Data("not an image".utf8)), completion: { [weak self] image in
            self?.statusOutput?.display(
                text: image == nil
                    ? "Invalid data cleared the image without showing remote fallback"
                    : "Unexpected image decoded from invalid data"
            )
        })
        statusOutput?.display(text: "Sending invalid image data")
    }

    private func showRemoteImage(lightURL: String?, darkURL: String?) {
        output?.display(
            image: .urlString(lightURL, darkURL),
            completion: { [weak self] image in
                self?.statusOutput?.display(
                    text: image == nil
                        ? "No URL exists for the current appearance"
                        : "The URL selected for the current appearance loaded"
                )
            }
        )
        statusOutput?.display(text: "Selecting the remote URL from the current appearance")
    }

    private static let lightImageURL = "https://picsum.photos/seed/wrapkit-light/320/200"
    private static let darkImageURL = "https://picsum.photos/seed/wrapkit-dark/320/200"
    private static let gradientPNGData =
        "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAQMAAABIeJ9nAAAAA1BMVEUKhP/YAArO" +
        "AAAADElEQVQI12NgYGAAAAAEAAEnNCcKAAAAAElFTkSuQmCC"

    private var currentSize: CGSize {
        settingStates[.size] == true
            ? .init(width: 160, height: 112)
            : .init(width: 120, height: 80)
    }

    private var currentOnPress: (() -> Void)? {
        guard settingStates[.onPress] == true else { return nil }
        return { [weak self] in
            self?.statusOutput?.display(text: "Tap handled")
        }
    }

    private var currentOnLongPress: (() -> Void)? {
        guard settingStates[.onLongPress] == true else { return nil }
        return { [weak self] in
            self?.statusOutput?.display(text: "Long press handled")
        }
    }

    private func configureSettingRows() {
        ImageCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "image.\(setting.rawValue)",
                    title: setting.title,
                    value: setting.subtitle,
                    isOn: settingStates[setting] ?? false,
                    onToggle: { [weak self] switchOutput in
                        self?.toggle(setting, switchOutput: switchOutput)
                    }
                )
            )
        }
    }

    private func toggle(
        _ setting: ImageCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        let isOn = !(settingStates[setting] ?? false)
        settingStates[setting] = isOn
        switchOutput.display(isOn: isOn)

        switch setting {
        case .model:
            if isOn {
                showSystemImage()
            } else {
                output?.display(model: nil)
                statusOutput?.display(text: "display(model: nil) sent")
            }
        case .size:
            output?.display(size: currentSize)
        case .contentMode:
            output?.display(contentModeIsFit: !isOn)
        case .borderWidth:
            output?.display(borderWidth: isOn ? 6 : 2)
        case .borderColor:
            output?.display(borderColor: isOn ? .systemBlue : .separator)
        case .cornerRadius:
            output?.display(cornerRadius: isOn ? 52 : 16)
        case .alpha:
            output?.display(alpha: isOn ? 0.35 : 1)
        case .onPress:
            output?.display(onPress: currentOnPress)
        case .onLongPress:
            output?.display(onLongPress: currentOnLongPress)
        case .hidden:
            if settingStates[.model] == true {
                output?.display(isHidden: isOn)
            } else {
                output?.display(model: nil)
            }
        }
    }
}

private struct ImageViewOutputCatalogView: View {
    let presenter: ImageViewOutputCatalogPresenter
    let adapters: ImageViewOutputCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIImageView(
                    adapter: adapters.output,
                    viewWhileLoadingView: AnyView(
                        SUIShimmerView(
                            style: .init(
                                backgroundColor: .systemGray5,
                                gradientColorOne: .systemGray5,
                                gradientColorTwo: .systemGray3,
                                cornerRadius: 20
                            )
                        )
                    ),
                    fallbackView: AnyView(
                        SUILabelView(
                            model: .text("Unable to load the image"),
                            font: .systemFont(ofSize: 13),
                            textColor: .secondaryLabel,
                            textAlignment: .center
                        )
                    ),
                    wrongUrlPlaceholderImage: ImageFactory.systemImage(
                        named: "photo.badge.exclamationmark"
                    ),
                    backgroundColor: SwiftUI.Color.secondary.opacity(0.08)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 120)

                SUILabel(
                    adapter: adapters.status,
                    font: .systemFont(ofSize: 13),
                    textColor: .secondaryLabel
                )
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(ImageViewOutputCatalogAction.allCases, id: \.rawValue) { action in
                        if let adapter = adapters.actions[action] {
                            SUIButton(adapter: adapter, pressAnimations: [.shrink])
                        }
                    }
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(ImageCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}
