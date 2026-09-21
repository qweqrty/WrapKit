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
            SUINavigationBar(adapter: chrome.header)

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
        .background(SwiftUI.Color(uiColor: .systemGroupedBackground))
        .navigationBarHidden(true)
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
