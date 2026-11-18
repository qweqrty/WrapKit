import SwiftUI
import WrapKit

final class CatalogChromeAdapters {
    let header = HeaderOutputSwiftUIAdapter()
    let stack = StackViewOutputSwiftUIAdapter()
}

struct CatalogDetailScreen<Content: View>: View {
    let chrome: CatalogChromeAdapters
    let content: Content

    init(
        chrome: CatalogChromeAdapters,
        @ViewBuilder content: () -> Content
    ) {
        self.chrome = chrome
        self.content = content()
    }

    var body: some View {
        SUIStackView(axis: .vertical, spacing: 0) {
            #if !os(tvOS)
            SUINavigationBar(adapter: chrome.header)
            #endif

            SUIScrollableContentView(
                contentInset: .init(top: 12, leading: 12, bottom: 12, trailing: 12),
                showsVerticalScrollIndicator: true,
                backgroundColor: .systemGroupedBackground
            ) {
                SUIStackView(
                    adapter: chrome.stack,
                    axis: .vertical,
                    spacing: 16
                ) {
                    content
                }
            }
        }
        .background(SwiftUIColor(.systemGroupedBackground))
        #if !os(macOS)
        .navigationBarHidden(true)
        #endif
    }
}

enum CatalogUnsupportedSceneFactory {
    static func make(title: String, onBack: @escaping () -> Void) -> AnyView {
        let chrome = CatalogChromeAdapters()
        let presenter = CatalogUnsupportedPresenter(title: title, onBack: onBack)

        presenter.headerOutput = chrome.header.weakReferenced.mainQueueDispatched
        presenter.stackOutput = chrome.stack.weakReferenced.mainQueueDispatched

        return AnyView(
            LifeCycleView(lifeCycleOutput: presenter) {
                CatalogDetailScreen(chrome: chrome) {
                    Text("\(title) is not available on this platform")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        )
    }
}

private final class CatalogUnsupportedPresenter: LifeCycleViewOutput {
    var headerOutput: HeaderOutput?
    var stackOutput: StackViewOutput?

    private let title: String
    private let onBack: () -> Void

    init(title: String, onBack: @escaping () -> Void) {
        self.title = title
        self.onBack = onBack
    }

    func viewDidLoad() {
        headerOutput?.display(model: CatalogAppearance.header(title: title, onBack: onBack))
        stackOutput?.display(model: CatalogAppearance.verticalStack)
    }
}

enum CatalogAppearance {
    static let primaryButton = WrapKit.ButtonStyle(
        backgroundColor: .systemBlue,
        titleColor: .white,
        pressedColor: .systemBlue.withAlphaComponent(0.72),
        pressedTintColor: .white,
        font: .systemFont(ofSize: 17, weight: .semibold),
        cornerRadius: 12,
        loadingIndicatorColor: .white
    )

    static let secondaryButton = WrapKit.ButtonStyle(
        backgroundColor: .secondarySystemBackground,
        titleColor: .systemBlue,
        borderWidth: 1,
        borderColor: .separator,
        pressedColor: .systemGray5,
        pressedTintColor: .systemBlue,
        font: .systemFont(ofSize: 16, weight: .semibold),
        cornerRadius: 12,
        loadingIndicatorColor: .systemBlue
    )

    static let destructiveButton = WrapKit.ButtonStyle(
        backgroundColor: .secondarySystemBackground,
        titleColor: .systemRed,
        borderWidth: 1,
        borderColor: .separator,
        pressedColor: .systemRed.withAlphaComponent(0.1),
        pressedTintColor: .systemRed,
        font: .systemFont(ofSize: 16, weight: .semibold),
        cornerRadius: 12,
        loadingIndicatorColor: .systemRed
    )

    static let settingCard = CardViewPresentableModel.Style(
        backgroundColor: .secondarySystemGroupedBackground,
        vStacklayoutMargins: .zero,
        hStacklayoutMargins: .init(horizontal: 12, vertical: 8),
        hStackViewDistribution: .fill,
        leadingTitleKeyTextColor: .label,
        titleKeyTextColor: .label,
        trailingTitleKeyTextColor: .label,
        titleValueTextColor: .secondaryLabel,
        subTitleTextColor: .secondaryLabel,
        leadingTitleKeyLabelFont: .systemFont(ofSize: 15),
        titleKeyLabelFont: .systemFont(ofSize: 15),
        trailingTitleKeyLabelFont: .systemFont(ofSize: 15),
        titleValueLabelFont: .systemFont(ofSize: 12),
        subTitleLabelFont: .systemFont(ofSize: 12),
        subtitleNumberOfLines: 2,
        cornerRadius: 12,
        stackSpace: 2,
        hStackViewSpacing: 8,
        titleKeyNumberOfLines: 2,
        titleValueNumberOfLines: 2,
        borderColor: .separator,
        borderWidth: 0.5,
        trailingImageLeadingSpacing: 6
    )

    static let settingSwitch = SwitchControlPresentableModel.Style(
        tintColor: .systemBlue,
        thumbTintColor: .white,
        backgroundColor: .systemGray5,
        cornerRadius: 16
    )

    static func toggleSettingCard(
        id: String,
        title: String,
        value: String? = nil,
        isOn: Bool,
        onToggle: @escaping (SwitchCotrolOutput & LoadingOutput) -> Void
    ) -> CardViewPresentableModel {
        .init(
            id: id,
            accessibilityIdentifier: id,
            accessibility: .init(label: [title, value].compactMap { $0 }.joined(separator: ", ")),
            style: settingCard,
            title: .text(title),
            valueTitle: value.map { .text($0) },
            switchControl: .init(
                accessibilityIdentifier: "\(id).switch",
                onPress: onToggle,
                isOn: isOn,
                isEnabled: true,
                style: settingSwitch
            ),
            isUserInteractionEnabled: true
        )
    }

    static func selectionSettingCard(
        id: String,
        title: String,
        value: String,
        onPress: @escaping () -> Void
    ) -> CardViewPresentableModel {
        .init(
            id: id,
            accessibilityIdentifier: id,
            accessibility: .init(label: "\(title), \(value)"),
            style: settingCard,
            title: .text(title),
            trailingImage: .systemSymbol(
                "chevron.right",
                size: .init(width: 14, height: 14),
                contentModeIsFit: true
            ),
            valueTitle: .text(value),
            onPress: onPress,
            isUserInteractionEnabled: true
        )
    }

    static func header(title: String, onBack: (() -> Void)? = nil) -> HeaderPresentableModel {
        .init(
            style: .init(
                backgroundColor: .systemGroupedBackground,
                horizontalSpacing: 12,
                primeFont: .systemFont(ofSize: 17, weight: .semibold),
                primeColor: .label,
                secondaryFont: .systemFont(ofSize: 13),
                secondaryColor: .secondaryLabel,
                numberOfLines: 1
            ),
            centerView: .keyValue(.init(.text(title), nil)),
            leadingCard: onBack.map { action in
                .init(
                    accessibilityIdentifier: "catalog.navigation.back",
                    accessibility: .init(label: "Back"),
                    leadingImage: .systemSymbol(
                        "chevron.left",
                        accessibility: .init(label: "Back"),
                        size: .init(width: 24, height: 24),
                        contentModeIsFit: true
                    ),
                    onPress: action,
                    isUserInteractionEnabled: true
                )
            }
        )
    }

    static var verticalStack: StackViewPresentableModel {
        .init(
            axis: .vertical,
            distribution: .fill,
            alignment: .fill,
            spacing: 16,
            layoutMargins: .zero
        )
    }

    static func actionButton(
        id: String,
        title: String,
        style: WrapKit.ButtonStyle = secondaryButton,
        onPress: @escaping () -> Void
    ) -> ButtonPresentableModel {
        .init(
            accessibilityIdentifier: id,
            accessibility: .init(label: title),
            title: title,
            height: 48,
            style: style,
            enabled: true,
            onPress: onPress
        )
    }
}

#if os(tvOS) || os(watchOS)
extension UIColor {
    static var systemBackground: UIColor { .dynamicColor(light: .white, dark: .black) }
    static var secondarySystemBackground: UIColor { .dynamicColor(light: UIColor(white: 0.95, alpha: 1), dark: UIColor(white: 0.11, alpha: 1)) }
    static var systemGroupedBackground: UIColor { .dynamicColor(light: UIColor(white: 0.95, alpha: 1), dark: .black) }
    static var secondarySystemGroupedBackground: UIColor { .dynamicColor(light: .white, dark: UIColor(white: 0.11, alpha: 1)) }
    static var tertiarySystemGroupedBackground: UIColor { .dynamicColor(light: UIColor(white: 0.95, alpha: 1), dark: UIColor(white: 0.17, alpha: 1)) }
    static var systemGray3: UIColor { .dynamicColor(light: UIColor(white: 0.78, alpha: 1), dark: UIColor(white: 0.28, alpha: 1)) }
    static var systemGray5: UIColor { .dynamicColor(light: UIColor(white: 0.9, alpha: 1), dark: UIColor(white: 0.17, alpha: 1)) }
    static var systemGray6: UIColor { .dynamicColor(light: UIColor(white: 0.95, alpha: 1), dark: UIColor(white: 0.11, alpha: 1)) }
    static var tertiarySystemFill: UIColor { .gray.withAlphaComponent(0.2) }
}
#endif

#if os(watchOS)
extension UIColor {
    static var systemBlue: UIColor { UIColor(red: 0.04, green: 0.52, blue: 1, alpha: 1) }
    static var systemRed: UIColor { UIColor(red: 1, green: 0.27, blue: 0.23, alpha: 1) }
    static var systemGreen: UIColor { UIColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1) }
    static var systemOrange: UIColor { UIColor(red: 1, green: 0.62, blue: 0.04, alpha: 1) }
    static var systemYellow: UIColor { UIColor(red: 1, green: 0.84, blue: 0.04, alpha: 1) }
    static var systemPurple: UIColor { UIColor(red: 0.75, green: 0.35, blue: 0.95, alpha: 1) }
    static var systemPink: UIColor { UIColor(red: 1, green: 0.22, blue: 0.37, alpha: 1) }
    static var systemTeal: UIColor { UIColor(red: 0.25, green: 0.78, blue: 0.88, alpha: 1) }
    static var systemIndigo: UIColor { UIColor(red: 0.37, green: 0.36, blue: 0.9, alpha: 1) }
    static var label: UIColor { .defaultLabel }
    static var secondaryLabel: UIColor { .defaultSecondaryLabel }
    static var tertiaryLabel: UIColor { .gray }
    static var placeholderText: UIColor { .gray }
    static var separator: UIColor { .darkGray }
}
#endif

#if os(macOS)
extension NSColor {
    static var label: NSColor { .labelColor }
    static var secondaryLabel: NSColor { .secondaryLabelColor }
    static var tertiaryLabel: NSColor { .tertiaryLabelColor }
    static var placeholderText: NSColor { .placeholderTextColor }
    static var separator: NSColor { .separatorColor }
    static var systemBackground: NSColor { .windowBackgroundColor }
    static var secondarySystemBackground: NSColor { .controlBackgroundColor }
    static var systemGroupedBackground: NSColor { .windowBackgroundColor }
    static var secondarySystemGroupedBackground: NSColor { .controlBackgroundColor }
    static var tertiarySystemGroupedBackground: NSColor { .underPageBackgroundColor }
    static var systemGray3: NSColor { .systemGray.withAlphaComponent(0.6) }
    static var systemGray5: NSColor { .systemGray.withAlphaComponent(0.3) }
    static var systemGray6: NSColor { .systemGray.withAlphaComponent(0.15) }
    static var tertiarySystemFill: NSColor { .quaternaryLabelColor }
}
#endif
