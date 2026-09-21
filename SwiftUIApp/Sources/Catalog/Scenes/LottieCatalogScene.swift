import Foundation
import Lottie
import SwiftUI
import WrapKit

private enum LottieCatalogSetting: String, CaseIterable, Hashable {
    case fastPlayback

    var title: String {
        switch self {
        case .fastPlayback: return "Use fast playback"
        }
    }
}

private enum LottieLoopPreset: String, CaseIterable, Hashable {
    case playOnce
    case loop
    case autoReverse
    case repeatTwice
    case repeatBackwardsTwice

    var title: String {
        switch self {
        case .playOnce: return "Play once"
        case .loop: return "Loop"
        case .autoReverse: return "Auto reverse"
        case .repeatTwice: return "Repeat twice"
        case .repeatBackwardsTwice: return "Repeat backwards twice"
        }
    }
}

enum LottieCatalogSceneFactory {
    static func make(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow
    ) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let adapters = LottieCatalogAdapters()
        let presenter = LottieCatalogPresenter(
            onBack: onBack,
            selectionFlow: selectionFlow,
            animationBundle: .main
        )

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched
        presenter.lottieOutput = adapters.lottie.weakReferenced.mainQueueDispatched
        presenter.replayButtonOutput = adapters.replayButton.weakReferenced.mainQueueDispatched
        presenter.animationNameButtonOutput = adapters.animationNameButton.weakReferenced.mainQueueDispatched
        presenter.statusOutput = adapters.status.weakReferenced.mainQueueDispatched
        presenter.loopSelectionOutput = adapters.loopSelection.weakReferenced.mainQueueDispatched
        presenter.settingOutputs = adapters.settings.mapValues {
            $0.weakReferenced.mainQueueDispatched
        }

        return AnyView(LottieCatalogView(
            presenter: presenter,
            chrome: chrome,
            adapters: adapters
        ))
    }
}

private final class LottieCatalogAdapters {
    let lottie = LottieViewOutputSwiftUIAdapter()
    let replayButton = ButtonOutputSwiftUIAdapter()
    let animationNameButton = ButtonOutputSwiftUIAdapter()
    let status = TextOutputSwiftUIAdapter()
    let loopSelection = CardViewOutputSwiftUIAdapter()
    let settings = Dictionary(
        uniqueKeysWithValues: LottieCatalogSetting.allCases.map {
            ($0, CardViewOutputSwiftUIAdapter())
        }
    )
}

private final class LottieCatalogPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?
    var lottieOutput: LottieViewOutput?
    var replayButtonOutput: ButtonOutput?
    var animationNameButtonOutput: ButtonOutput?
    var statusOutput: TextOutput?
    var loopSelectionOutput: CardViewOutput?
    var settingOutputs: [LottieCatalogSetting: CardViewOutput] = [:]

    private let onBack: () -> Void
    private let selectionFlow: any SelectionFlow
    private let animationBundle: Bundle
    private var didLoad = false
    private var isFastPlaybackEnabled = false
    private var loopPreset: LottieLoopPreset = .loop

    init(
        onBack: @escaping () -> Void,
        selectionFlow: any SelectionFlow,
        animationBundle: Bundle
    ) {
        self.onBack = onBack
        self.selectionFlow = selectionFlow
        self.animationBundle = animationBundle
    }

    func viewDidLoad() {
        guard !didLoad else { return }
        didLoad = true

        headerOutput?.display(model: CatalogAppearance.header(
            title: "LottieViewOutput",
            onBack: onBack
        ))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
        configureReplayButton()
        configureAnimationNameButton()
        configureLoopSelection()
        configureSettingCards()
        displayAnimation()
        showStatus("Animation started")
    }
}

private extension LottieCatalogPresenter {
    func configureReplayButton() {
        replayButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.controls.lottie.replay",
            title: "Replay animation",
            style: CatalogAppearance.primaryButton,
            onPress: { [weak self] in self?.replayAnimation() }
        ))
    }

    func configureAnimationNameButton() {
        animationNameButtonOutput?.display(model: CatalogAppearance.actionButton(
            id: "catalog.controls.lottie.animation-name",
            title: "Read current animation name",
            onPress: { [weak self] in self?.showCurrentAnimationName() }
        ))
    }

    func configureSettingCards() {
        LottieCatalogSetting.allCases.forEach { setting in
            settingOutputs[setting]?.display(model: CatalogAppearance.toggleSettingCard(
                id: "catalog.controls.lottie.setting.\(setting.rawValue)",
                title: setting.title,
                value: settingValue(for: setting),
                isOn: settingIsOn(setting),
                onToggle: { [weak self] output in
                    self?.toggleSetting(setting, switchOutput: output)
                }
            ))
        }
    }

    func configureLoopSelection() {
        loopSelectionOutput?.display(model: CatalogAppearance.selectionSettingCard(
            id: "catalog.controls.lottie.loop-mode",
            title: "Loop mode",
            value: loopPreset.title,
            onPress: { [weak self] in self?.showLoopSelection() }
        ))
    }

    func showLoopSelection() {
        selectionFlow.showSelection(model: .init(
            title: "Choose a loop mode",
            isMultipleSelectionEnabled: false,
            items: LottieLoopPreset.allCases.map { preset in
                .init(
                    id: preset.rawValue,
                    title: preset.title,
                    isSelected: preset == loopPreset,
                    configuration: CatalogSelectionAppearance.cell
                )
            },
            callback: { [weak self] result in
                guard case let .singleSelection(item)? = result,
                      let preset = LottieLoopPreset(rawValue: item.id) else { return }
                self?.loopPreset = preset
                self?.configureLoopSelection()
                self?.displayAnimation()
                self?.showStatus("Loop mode: \(preset.title)")
            }
        ))
    }

    func settingValue(for setting: LottieCatalogSetting) -> String {
        switch setting {
        case .fastPlayback:
            return isFastPlaybackEnabled ? "2×" : "1×"
        }
    }

    func settingIsOn(_ setting: LottieCatalogSetting) -> Bool {
        switch setting {
        case .fastPlayback:
            return isFastPlaybackEnabled
        }
    }

    func toggleSetting(
        _ setting: LottieCatalogSetting,
        switchOutput: SwitchCotrolOutput & LoadingOutput
    ) {
        switch setting {
        case .fastPlayback:
            isFastPlaybackEnabled.toggle()
            switchOutput.display(isOn: isFastPlaybackEnabled)
        }

        configureSettingCards()
        displayAnimation()
        showStatus("\(setting.title): \(settingValue(for: setting))")
    }

    func replayAnimation() {
        displayAnimation()
        showStatus("Animation restarted")
    }

    func showCurrentAnimationName() {
        let name = lottieOutput?.currentAnimationName ?? "No animation loaded"
        showStatus("Current animation: \(name)")
    }

    func displayAnimation() {
        let model: LottieViewPresentableModel
        switch loopPreset {
        case .playOnce:
            model = makeAnimationModel(loopMode: .playOnce)
        case .loop:
            model = makeAnimationModel(loopMode: .loop)
        case .autoReverse:
            model = makeAnimationModel(loopMode: .autoReverse)
        case .repeatTwice:
            model = makeAnimationModel(loopMode: .repeat(2))
        case .repeatBackwardsTwice:
            model = makeAnimationModel(loopMode: .repeatBackwards(2))
        }
        lottieOutput?.display(model: model)
    }

    func makeAnimationModel(loopMode: LottieLoopMode) -> LottieViewPresentableModel {
        .init(
            fileName: "Lottie/ComingSoon",
            animationSpeed: isFastPlaybackEnabled ? 2 : 1,
            loopMode: loopMode,
            bundle: animationBundle
        )
    }

    func showStatus(_ text: String) {
        statusOutput?.display(model: ControlsCatalogAppearance.status(text))
    }
}

private struct LottieCatalogView: View {
    let presenter: LottieCatalogPresenter
    let chrome: CatalogChromeAdapters
    let adapters: LottieCatalogAdapters

    var body: some View {
        LifeCycleView(lifeCycleOutput: presenter) {
            CatalogDetailScreen(chrome: chrome) {
                SUIStackView(axis: .vertical, spacing: 12) {
                    ControlsCatalogSectionTitle(title: "Animation")
                    SUILottieView(adapter: adapters.lottie)
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                    SUIButton(adapter: adapters.replayButton, pressAnimations: [.shrink])
                        .accentColor(.white)
                        .frame(maxWidth: .infinity)
                    SUIButton(adapter: adapters.animationNameButton, pressAnimations: [.shrink])
                        .frame(maxWidth: .infinity)
                }

                SUIStackView(axis: .vertical, spacing: 8) {
                    ControlsCatalogSectionTitle(title: "Settings")
                    SUICardView(adapter: adapters.loopSelection)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                    ForEach(LottieCatalogSetting.allCases, id: \.rawValue) { setting in
                        if let adapter = adapters.settings[setting] {
                            SUICardView(adapter: adapter)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                ControlsCatalogStatusView(adapter: adapters.status)
            }
        }
    }
}
