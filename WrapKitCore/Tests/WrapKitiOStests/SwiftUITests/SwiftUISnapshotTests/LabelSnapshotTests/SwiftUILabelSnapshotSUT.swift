//
//  LabelSwiftUISnapshotSUT.swift
//  WrapKitTests
//

import SwiftUI
import UIKit
@testable import WrapKit
import WrapKitTestUtils

final class SwiftUILabelSnapshotSUT: TextOutput, SwiftUISnapshotSource {
    private static let defaultFont = UIFont.systemFont(ofSize: 20)
    private static let defaultTextColor = UIColor.label
    private static let defaultTextAlignment = NSTextAlignment.natural

    let adapter: TextOutputSwiftUIAdapter

    private let configuration: LabelSnapshotConfiguration
    private var hostingController: UIHostingController<AnyView>?

    init(adapter: TextOutputSwiftUIAdapter = TextOutputSwiftUIAdapter()) {
        self.adapter = adapter
        self.configuration = LabelSnapshotConfiguration(
            font: Self.defaultFont,
            textColor: Self.defaultTextColor,
            textAlignment: Self.defaultTextAlignment
        )

        if #available(iOS 17.0, *) {
            hostingController = makeHostingController()
            if let hostingController {
                prepareForRendering(hostingController)
                hostingController._render(seconds: 0)
            }
        }
    }

    var snapshotContainerBackgroundColor: UIColor? {
        get { configuration.snapshotContainerBackgroundColor }
        set { configuration.snapshotContainerBackgroundColor = newValue }
    }

    var textColor: UIColor! {
        get { configuration.textColor }
        set {
            guard let newValue else { return }
            configuration.textColor = newValue
        }
    }

    var font: UIFont! {
        get { configuration.font }
        set {
            guard let newValue else { return }
            configuration.font = newValue
        }
    }

    var textAlignment: NSTextAlignment {
        get { configuration.textAlignment }
        set { configuration.textAlignment = newValue }
    }

    func display(model: TextOutputPresentableModel?) {
        adapter.display(model: model)
    }

    func display(textModel: TextOutputPresentableModel.TextModel?) {
        adapter.display(textModel: textModel)
    }

    func display(text: String?) {
        adapter.display(text: text)
    }

    func display(attributes: [TextAttributes]) {
        adapter.display(attributes: attributes)
    }

    func display(htmlString: String?, config: HTMLAttributedStringConfig?) {
        adapter.display(htmlString: htmlString, config: config)
    }

    func display(
        id: String? = nil,
        from startAmount: Decimal,
        to endAmount: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1,
        completion: (() -> Void)? = nil
    ) {
        adapter.display(
            id: id,
            from: startAmount,
            to: endAmount,
            mapToString: mapToString,
            animationStyle: animationStyle,
            duration: duration,
            completion: completion
        )
    }

    func display(
        from startAmount: Decimal,
        to endAmount: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1,
        completion: (() -> Void)? = nil
    ) {
        display(
            id: nil,
            from: startAmount,
            to: endAmount,
            mapToString: mapToString,
            animationStyle: animationStyle,
            duration: duration,
            completion: completion
        )
    }

    func display(isHidden: Bool) {
        adapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        guard let hostingController else {
            assertionFailure("SwiftUI label host must be prepared before sending Output events.")
            return UIImage()
        }
        configuration.appearance = appearance
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    @available(iOS 17.0, *)
    private func makeHostingController() -> UIHostingController<AnyView> {
        let rootView = SnapshotMirroredLabelContainer(
            adapter: adapter,
            configuration: configuration
        )
        .snapshotEnvironment(configuration: .iPhone(style: .light))
        .ignoresSafeArea(.all)
        let hostingController = UIHostingController(rootView: AnyView(rootView))
        hostingController.overrideUserInterfaceStyle = .light
        hostingController.view.backgroundColor = .clear
        return hostingController
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
    }
}

private final class LabelSnapshotConfiguration: ObservableObject {
    @Published var appearance: SnapshotAppearance = .light
    @Published var font: UIFont
    @Published var textColor: UIColor
    @Published var textAlignment: NSTextAlignment
    @Published var snapshotContainerBackgroundColor: UIColor?

    init(font: UIFont, textColor: UIColor, textAlignment: NSTextAlignment) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredLabelContainer: View {
    let adapter: TextOutputSwiftUIAdapter
    @ObservedObject var configuration: LabelSnapshotConfiguration

    var body: some View {
        VStack(spacing: 0) {
            label
                .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .topLeading)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(SwiftUIColor.clear)
        .environment(\.colorScheme, configuration.appearance.colorScheme)
    }

    private var label: some View {
        SUILabel(
            adapter: adapter,
            font: configuration.font,
            textColor: configuration.textColor,
            textAlignment: configuration.textAlignment
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            configuration.snapshotContainerBackgroundColor.map { SwiftUIColor($0) } ?? .clear
        )
    }
}
