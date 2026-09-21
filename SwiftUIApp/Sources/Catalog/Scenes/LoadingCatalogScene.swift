import SwiftUI
import WrapKit

enum LoadingCatalogSceneFactory {
    static func make(onBack: @escaping () -> Void) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let adapters = LoadingCatalogAdapters()
        let presenter = LoadingCatalogPresenter(
            onBack: onBack,
            switchStyle: ControlsCatalogViewConfiguration.appleDefault.switchStyle
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.loadingButtonOutput = adapters.loadingButton.weakReferenced.mainQueueDispatched
        presenter.buttonLoadingOutput = adapters.buttonLoading.weakReferenced.mainQueueDispatched
        presenter.switchOutput = adapters.switchControl.weakReferenced.mainQueueDispatched
        presenter.switchLoadingOutput = adapters.switchControl.weakReferenced.mainQueueDispatched
        presenter.pageLoadingOutput = adapters.pageLoading.weakReferenced.mainQueueDispatched
        presenter.loadingActionOutput = adapters.loadingAction.weakReferenced.mainQueueDispatched

        return AnyView(LoadingCatalogView(
            presenter: presenter,
            chrome: chrome,
            adapters: adapters
        ))
    }
}

private final class LoadingCatalogAdapters {
    let status = TextOutputSwiftUIAdapter()
    let loadingButton = ButtonOutputSwiftUIAdapter()
    let buttonLoading = LoadingOutputSwiftUIAdapter()
    let switchControl = SwitchCotrolOutputSwiftUIAdapter()
    let pageLoading = LoadingOutputSwiftUIAdapter()
    let loadingAction = ButtonOutputSwiftUIAdapter()
}

private final class LoadingCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var statusOutput: TextOutput?
    var loadingButtonOutput: ButtonOutput?
    var buttonLoadingOutput: LoadingOutput?
    var switchOutput: SwitchCotrolOutput?
    var switchLoadingOutput: LoadingOutput?
    var pageLoadingOutput: LoadingOutput?
    var loadingActionOutput: ButtonOutput?

    private let onBack: () -> Void
    private let switchStyle: SwitchControlPresentableModel.Style
    private var didLoad = false
    private var isSwitchOn = true
    private var isLoadingPreview = true

    init(
        onBack: @escaping () -> Void,
        switchStyle: SwitchControlPresentableModel.Style
    ) {
        self.onBack = onBack
        self.switchStyle = switchStyle
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(title: "LoadingOutput", onBack: onBack))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureLoadingVariants()
        displayLoadingVariants(isLoading: true)
        configureLoadingAction(isLoading: true)
        showStatus("Ready")
    }

    func viewWillDisappear() {
        displayLoadingVariants(isLoading: false)
    }
}

private extension LoadingCatalogPresenter {
    func configureLoadingVariants() {
        loadingButtonOutput?.display(model: .init(
            accessibilityIdentifier: "catalog.controls.loading.button",
            accessibility: .init(
                label: "Button with a loading indicator",
                hint: "Toggles the loading state"
            ),
            title: "Refresh data",
            image: ImageFactory.systemImage(named: "arrow.triangle.2.circlepath"),
            spacing: 8,
            height: 50,
            style: .init(
                backgroundColor: .systemIndigo,
                titleColor: .white,
                pressedColor: .systemIndigo.withAlphaComponent(0.72),
                pressedTintColor: .white,
                font: .systemFont(ofSize: 17, weight: .semibold),
                glassConfiguration: .prominentGlass,
                loadingIndicatorColor: .white
            ),
            enabled: true,
            onPress: { [weak self] in self?.toggleLoadingPreview() }
        ))
        switchOutput?.display(model: .init(
            accessibilityIdentifier: "catalog.controls.loading.switch",
            onPress: { [weak self] output in self?.toggleLoadingSwitch(using: output) },
            isOn: isSwitchOn,
            isEnabled: true,
            style: switchStyle
        ))
    }

    func configureLoadingAction(isLoading: Bool) {
        loadingActionOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.controls.loading.show",
            title: isLoading ? "Stop loading" : "Show loading",
            style: CatalogAppearance.primaryButton,
            onPress: { [weak self] in self?.toggleLoadingPreview() }
        ))
    }

    func toggleLoadingSwitch(using output: SwitchCotrolOutput & LoadingOutput) {
        isSwitchOn.toggle()
        output.display(isOn: isSwitchOn)
        showStatus(isSwitchOn ? "Switch is on" : "Switch is off")
    }

    func toggleLoadingPreview() {
        isLoadingPreview.toggle()
        displayLoadingVariants(isLoading: isLoadingPreview)
        configureLoadingAction(isLoading: isLoadingPreview)
        showStatus(isLoadingPreview ? "Loading…" : "Loading stopped")
    }

    func displayLoadingVariants(isLoading: Bool) {
        // Exercise the public property contract on the standalone loader while
        // button and switch variants keep covering display(isLoading:).
        pageLoadingOutput?.isLoading = isLoading
        buttonLoadingOutput?.display(isLoading: isLoading)
        switchLoadingOutput?.display(isLoading: isLoading)
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: ControlsCatalogAppearance.status(text))
    }
}

private struct LoadingCatalogView: View {
    let presenter: LoadingCatalogPresenter
    let chrome: CatalogChromeAdapters
    let adapters: LoadingCatalogAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(axis: .vertical, spacing: 12) {
                    ControlsCatalogSectionTitle(title: "Loading variants")
                    SUILabelView(
                        model: .text("Standalone indicator"),
                        font: .systemFont(ofSize: 14, weight: .medium),
                        textColor: .secondaryLabel
                    )
                    SUILoadingView.circleStrokeLoader(
                        adapter: adapters.pageLoading,
                        loadingViewColor: .accentColor,
                        wrapperViewColor: SwiftUIColor(.secondarySystemGroupedBackground),
                        size: .init(width: 84, height: 84)
                    )
                    .frame(maxWidth: .infinity)
                    SUILabelView(
                        model: .text("Button indicator"),
                        font: .systemFont(ofSize: 14, weight: .medium),
                        textColor: .secondaryLabel
                    )
                    SUIButton(
                        adapter: adapters.loadingButton,
                        loadingAdapter: adapters.buttonLoading,
                        pressAnimations: [.shrink]
                    )
                    .accentColor(.white)
                    .frame(maxWidth: .infinity)
                    SUILabelView(
                        model: .text("Switch indicator"),
                        font: .systemFont(ofSize: 14, weight: .medium),
                        textColor: .secondaryLabel
                    )
                    SUISwitchControl(adapter: adapters.switchControl)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                ControlsCatalogSectionTitle(title: "Loading controls")
                SUIButton(adapter: adapters.loadingAction, pressAnimations: [.shrink])
                    .accentColor(.white)
                    .frame(maxWidth: .infinity)
                ControlsCatalogStatusView(adapter: adapters.status)
            }
        }
    }
}
