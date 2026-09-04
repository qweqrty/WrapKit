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

    let uiKitLabel: WrapKit.Label
    let adapter: TextOutputSwiftUIAdapter

    private let uiKitContainer: UIView
    private let swiftUIStateModel: SUILabelStateModel
    private var swiftUIView: AnyView
    private var labelBackgroundColor: UIColor?
    private var labelCornerStyle: CornerStyle?
    private var snapshotTextInsets = UIEdgeInsets.zero
    private var swiftUIFont = SwiftUILabelSnapshotSUT.defaultFont
    private var swiftUITextColor = SwiftUILabelSnapshotSUT.defaultTextColor
    private var swiftUITextAlignment = SwiftUILabelSnapshotSUT.defaultTextAlignment

    init(
        uiKitContainer: UIView,
        adapter: TextOutputSwiftUIAdapter = TextOutputSwiftUIAdapter()
    ) {
        let stateModel = SUILabelStateModel(adapter: adapter)
        self.uiKitContainer = uiKitContainer
        self.adapter = adapter
        self.swiftUIStateModel = stateModel
        self.uiKitLabel = WrapKit.Label(
            font: Self.defaultFont,
            textColor: Self.defaultTextColor,
            textAlignment: Self.defaultTextAlignment
        )
        self.swiftUIView = AnyView(SUILabel(stateModel: stateModel))
    }

    var backgroundColor: UIColor? {
        get { labelBackgroundColor }
        set {
            uiKitLabel.backgroundColor = newValue
            labelBackgroundColor = newValue
        }
    }

    var textInsets: UIEdgeInsets {
        get { snapshotTextInsets }
        set {
            uiKitLabel.textInsets = newValue
            snapshotTextInsets = newValue
        }
    }

    var cornerStyle: CornerStyle? {
        get { labelCornerStyle }
        set {
            uiKitLabel.cornerStyle = newValue
            labelCornerStyle = newValue
        }
    }

    var textColor: UIColor! {
        get { swiftUITextColor }
        set {
            uiKitLabel.textColor = newValue
            guard let newValue else { return }
            swiftUITextColor = newValue
            rebuildSwiftUIView()
        }
    }

    var font: UIFont! {
        get { swiftUIFont }
        set {
            uiKitLabel.font = newValue
            guard let newValue else { return }
            swiftUIFont = newValue
            rebuildSwiftUIView()
        }
    }

    var textAlignment: NSTextAlignment {
        get { swiftUITextAlignment }
        set {
            uiKitLabel.textAlignment = newValue
            swiftUITextAlignment = newValue
            rebuildSwiftUIView()
        }
    }

    func display(model: TextOutputPresentableModel?) {
        uiKitLabel.display(model: model)
        adapter.display(model: model)
    }

    func display(textModel: TextOutputPresentableModel.TextModel?) {
        uiKitLabel.display(textModel: textModel)
        adapter.display(textModel: textModel)
    }

    func display(text: String?) {
        uiKitLabel.display(text: text)
        adapter.display(text: text)
    }

    func display(attributes: [TextAttributes]) {
        uiKitLabel.display(attributes: attributes)
        adapter.display(attributes: attributes)
    }

    func display(htmlString: String?, config: HTMLAttributedStringConfig?) {
        uiKitLabel.display(htmlString: htmlString, config: config)
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
        let pairedCompletion = makeSwiftUICompletion(completion)

        uiKitLabel.display(
            id: id,
            from: startAmount,
            to: endAmount,
            mapToString: mapToString,
            animationStyle: animationStyle,
            duration: duration,
            completion: pairedCompletion
        )
        adapter.display(
            id: id,
            from: startAmount,
            to: endAmount,
            mapToString: mapToString,
            animationStyle: animationStyle,
            duration: duration,
            completion: pairedCompletion
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
        uiKitLabel.display(isHidden: isHidden)
        adapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage {
        let rootView = SnapshotMirroredLabelContainer(
            content: swiftUIView,
            textInsets: snapshotTextInsets,
            backgroundColor: labelBackgroundColor,
            cornerStyle: labelCornerStyle
        )
        .environment(\.colorScheme, appearance.colorScheme)
        .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        hostingController.view.backgroundColor = .clear

        prepareForRendering(hostingController)
        return hostingController.snapshot(for: appearance.uiKitConfiguration)
    }

    private func rebuildSwiftUIView() {
        swiftUIView = AnyView(
            SUILabel(
                stateModel: swiftUIStateModel,
                font: swiftUIFont,
                textColor: swiftUITextColor,
                textAlignment: swiftUITextAlignment
            )
        )
    }

    private func makeSwiftUICompletion(_ completion: (() -> Void)?) -> (() -> Void)? {
        guard let completion else { return nil }
        let consumerCount = if #available(iOS 17.0, *) { 2 } else { 1 }
        let barrier = CompletionBarrier(consumerCount: consumerCount, completion: completion)
        return { barrier.call() }
    }

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
    }
}

private final class CompletionBarrier {
    private var remainingConsumerCount: Int
    private var completion: (() -> Void)?

    init(consumerCount: Int, completion: @escaping () -> Void) {
        remainingConsumerCount = consumerCount
        self.completion = completion
    }

    func call() {
        guard remainingConsumerCount > 0 else { return }
        remainingConsumerCount -= 1
        guard remainingConsumerCount == 0 else { return }

        let completion = completion
        self.completion = nil
        completion?()
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredLabelContainer: View {
    let content: AnyView
    let textInsets: UIEdgeInsets
    let backgroundColor: UIColor?
    let cornerStyle: CornerStyle?

    var body: some View {
        VStack(spacing: 0) {
            label
                .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .topLeading)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(SwiftUIColor.clear)
    }

    @ViewBuilder
    private var label: some View {
        let content = content
            .padding(EdgeInsets(
                top: textInsets.top,
                leading: textInsets.left,
                bottom: textInsets.bottom,
                trailing: textInsets.right
            ))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(backgroundColor.map { SwiftUIColor($0) } ?? .clear)

        switch cornerStyle {
        case .automatic:
            content.clipShape(Capsule(style: .continuous))
        case .fixed(let radius):
            content.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        case .corners(let corners):
            content.clipShape(RoundedRectangle(cornerRadius: corners.maximum, style: .continuous))
        case .some(.none), .none:
            content
        }
    }
}
