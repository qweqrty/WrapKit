import SwiftUI
import WrapKit

enum TextOutputCatalogSceneFactory {
    static func make(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) -> AnyView {
        let adapters = TextOutputCatalogAdapters()
        let chrome = CatalogChromeAdapters()
        let presenter = TextOutputCatalogPresenter(
            onBack: onBack,
            selectionFlow: selectionFlow
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.output = adapters.output.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.modeOutput = adapters.mode.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }
        presenter.actionOutputs = adapters.actions.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(
            TextOutputCatalogView(
                presenter: presenter,
                adapters: adapters,
                chrome: chrome
            )
        )
    }
}

private final class TextOutputCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var output: TextOutput?
    var statusOutput: TextOutput?
    var modeOutput: CardViewOutput?
    var settingOutputs: [TextCatalogSetting: CardViewOutput] = [:]
    var actionOutputs: [TextOutputCatalogAction: ButtonOutput] = [:]

    private let onBack: () -> Void
    private let selectionFlow: any SelectionFlow
    private var didLoad = false
    private var mode: LabelCatalogMode = .attributes
    private var attributes: [TextAttributes] = []
    private var nextFragmentIndex = 0
    private var isModelVisible = true
    private var isHidden = false

    init(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) {
        self.onBack = onBack
        self.selectionFlow = selectionFlow
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(
            model: CatalogAppearance.header(title: "TextOutput", onBack: onBack)
        )
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureActions()
        showRichLabel()
        statusOutput?.display(text: "TextOutput is ready")
        configureSettingRows()
    }

    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
    func viewDidLayoutSubviews() {}

    private func configureActions() {
        TextOutputCatalogAction.allCases.forEach { action in
            actionOutputs[action]?.display(
                model: CatalogAppearance.actionButton(
                    id: "catalog.content.text.\(action.rawValue)",
                    title: action.title,
                    onPress: { [weak self] in self?.perform(action) }
                )
            )
        }
    }

    private func perform(_ action: TextOutputCatalogAction) {
        switch action {
        case .addLabelFragment: addLabelFragment()
        case .replayCountingAnimation: replayCountingAnimation()
        }
    }

    private func configureModeRow() {
        modeOutput?.display(model: CatalogAppearance.selectionSettingCard(
            id: "text.display-mode",
            title: "Display mode",
            value: mode.title,
            onPress: { [weak self] in self?.showModeSelection() }
        ))
        if isHidden {
            output?.display(isHidden: true)
        }
    }

    private func showModeSelection() {
        selectionFlow.showSelection(model: .init(
            title: "TextOutput display mode",
            isMultipleSelectionEnabled: false,
            items: LabelCatalogMode.allCases.map { mode in
                .init(
                    id: mode.rawValue,
                    title: mode.title,
                    isSelected: mode == self.mode,
                    configuration: CatalogSelectionAppearance.cell
                )
            },
            callback: { [weak self] result in
                guard case let .singleSelection(item) = result,
                      let mode = LabelCatalogMode(rawValue: item.id)
                else { return }
                self?.display(mode)
            },
            emptyViewPresentableModel: .init(
                title: .text("No display modes"),
                subTitle: .text("TextOutput has no available examples.")
            )
        ))
    }

    private func display(_ mode: LabelCatalogMode) {
        switch mode {
        case .model: showLabelModel()
        case .textModel: showLabelTextModel()
        case .plain: showPlainLabel()
        case .attributes: showRichLabel()
        case .html: showHTMLLabel()
        case .animatedDecimal: replayCountingAnimation()
        }
    }

    private func showLabelModel() {
        mode = .model
        guard isModelVisible else {
            output?.display(model: nil)
            configureModeRow()
            return
        }
        output?.display(
            model: .init(
                model: .textStyled(
                    text: .text("TextOutputPresentableModel.textStyled"),
                    cornerStyle: .fixed(10),
                    insets: .init(horizontal: 12, vertical: 10),
                    height: 72,
                    backgroundColor: .systemBlue.withAlphaComponent(0.12)
                )
            )
        )
        configureModeRow()
    }

    private func showLabelTextModel() {
        mode = .textModel
        guard isModelVisible else {
            output?.display(model: nil)
            configureModeRow()
            return
        }
        output?.display(
            textModel: .attributes([
                .init(
                    text: "Balance: ",
                    color: .secondaryLabel,
                    font: .systemFont(ofSize: 16)
                ),
                .init(
                    text: "$2,490",
                    color: .systemGreen,
                    font: .systemFont(ofSize: 18, weight: .semibold)
                )
            ])
        )
        configureModeRow()
    }

    private func showPlainLabel() {
        mode = .plain
        if isModelVisible {
            output?.display(text: "Plain text without additional attributes")
        } else {
            output?.display(model: nil)
        }
        configureModeRow()
    }

    private func showRichLabel() {
        mode = .attributes
        attributes = makeInitialAttributes()
        nextFragmentIndex = 0
        if isModelVisible {
            output?.display(attributes: attributes)
        } else {
            output?.display(model: nil)
        }
        configureModeRow()
    }

    private func showHTMLLabel() {
        mode = .html
        guard isModelVisible else {
            output?.display(model: nil)
            configureModeRow()
            return
        }
        output?.display(
            htmlString: """
            <p><b>Attributed HTML</b> can combine <span style="color:#007AFF">color</span>, emphasis, and inline links.</p>
            <p>This sample uses semantic colors, spacing, and a readable line height.</p>
            """,
            config: .init(
                size: 16,
                weight: .regular,
                color: .label,
                lineSpacing: 4,
                paragraphSpacing: 8,
                textAlignment: .left
            )
        )
        configureModeRow()
    }

    private func addLabelFragment() {
        if mode != .attributes {
            attributes = makeInitialAttributes()
            nextFragmentIndex = 0
        } else if nextFragmentIndex == 4 {
            // Keep the live renderer content-sized inside its preview canvas.
            // After every available fragment has been shown, start the set again.
            attributes = makeInitialAttributes()
            nextFragmentIndex = 0
        }
        mode = .attributes
        attributes.append(makeNextFragment())
        nextFragmentIndex += 1
        if isModelVisible {
            output?.display(attributes: attributes)
        } else {
            output?.display(model: nil)
        }
        configureModeRow()
    }

    private func replayCountingAnimation() {
        mode = .animatedDecimal
        guard isModelVisible else {
            output?.display(model: nil)
            statusOutput?.display(text: "Animation is ready; show the full model to run it")
            configureModeRow()
            return
        }
        statusOutput?.display(text: "Number animation is running")
        output?.display(
            id: "content.text-output.animated-decimal",
            from: 1_250,
            to: 2_490,
            mapToString: { value in
                .text("$\(value.asString(withDecimalPlaces: 0))")
            },
            animationStyle: .circle(lineColor: .systemBlue),
            duration: 0.8,
            completion: { [weak self] in
                self?.statusOutput?.display(text: "Number animation completed at $2,490")
            }
        )
        configureModeRow()
    }

    private func configureSettingRows() {
        TextCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(
                model: CatalogAppearance.toggleSettingCard(
                    id: "text.\(setting.rawValue)",
                    title: setting.title,
                    value: setting.subtitle,
                    isOn: setting == .model ? isModelVisible : isHidden,
                    onToggle: { [weak self] switchOutput in
                        self?.toggle(setting, switchOutput: switchOutput)
                    }
                )
            )
        }
    }

    private func toggle(
        _ setting: TextCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        switch setting {
        case .model:
            isModelVisible.toggle()
            switchOutput.display(isOn: isModelVisible)
            if isModelVisible {
                statusOutput?.display(text: "Full TextOutput model restored")
                display(mode)
            } else {
                output?.display(model: nil)
                statusOutput?.display(text: "display(model: nil) sent")
            }
        case .hidden:
            isHidden.toggle()
            switchOutput.display(isOn: isHidden)
            if isModelVisible {
                output?.display(isHidden: isHidden)
            } else {
                output?.display(model: nil)
            }
        }
    }

    private func makeInitialAttributes() -> [TextAttributes] {
        [
            .init(
                text: "WrapKit ",
                color: .systemBlue,
                font: .boldSystemFont(ofSize: 22),
                lineSpacing: 6,
                leadingImage: ImageFactory.systemImage(named: "sparkles"),
                leadingImageBounds: .init(x: 0, y: -2, width: 20, height: 20)
            ),
            .init(
                text: "combines ",
                color: .secondaryLabel,
                font: .systemFont(ofSize: 16)
            ),
            .init(
                text: "multiple TextAttributes",
                color: .systemPurple,
                font: .systemFont(ofSize: 17, weight: .semibold),
                underlineStyle: [.single, .byWord],
                onTap: { [weak self] in self?.addLabelFragment() }
            ),
            .init(
                text: "\nwith different fonts, colors, spacing, and actions.",
                color: .label,
                font: .systemFont(ofSize: 16),
                lineSpacing: 8,
                trailingImage: ImageFactory.systemImage(named: "hand.tap.fill"),
                trailingImageBounds: .init(x: 4, y: -2, width: 18, height: 18)
            )
        ]
    }

    private func makeNextFragment() -> TextAttributes {
        let fragments: [TextAttributes] = [
            .init(
                text: "\nNew color",
                color: .systemGreen,
                font: .boldSystemFont(ofSize: 18)
            ),
            .init(
                text: " · italic",
                color: .systemOrange,
                font: FontFactory.italic(size: 17)
            ),
            .init(
                text: " · double underline",
                color: .systemRed,
                font: .systemFont(ofSize: 16),
                underlineStyle: .double
            ),
            .init(
                text: " · another tappable fragment",
                color: .systemIndigo,
                font: .systemFont(ofSize: 16, weight: .semibold),
                underlineStyle: .single,
                onTap: { [weak self] in self?.addLabelFragment() }
            )
        ]
        return fragments[nextFragmentIndex % fragments.count]
    }
}

private struct TextOutputCatalogView: View {
    let presenter: TextOutputCatalogPresenter
    let adapters: TextOutputCatalogAdapters
    let chrome: CatalogChromeAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIWrapperView(
                    backgroundColor: SwiftUI.Color(uiColor: .secondarySystemGroupedBackground),
                    cornerRadius: 12,
                    padding: .init(all: 12)
                ) {
                    SUILabel(
                        adapter: adapters.output,
                        font: .systemFont(ofSize: 16),
                        textColor: .label,
                        textAlignment: .left
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)

                SUICardView(adapter: adapters.mode)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(TextOutputCatalogAction.allCases, id: \.rawValue) { action in
                        if let adapter = adapters.actions[action] {
                            SUIButton(adapter: adapter, pressAnimations: [.shrink])
                        }
                    }
                }

                SUILabel(
                    adapter: adapters.status,
                    font: .systemFont(ofSize: 13),
                    textColor: .secondaryLabel
                )
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

                SUIStackView(axis: .vertical, spacing: 8) {
                    ForEach(TextCatalogSetting.allCases, id: \.rawValue) { setting in
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
