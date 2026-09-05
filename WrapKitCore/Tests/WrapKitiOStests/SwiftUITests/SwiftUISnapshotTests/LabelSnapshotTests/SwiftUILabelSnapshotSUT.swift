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

    private let swiftUIStateModel: SUILabelStateModel
    private var swiftUIView: AnyView
    private var labelBackgroundColor: UIColor?
    private var labelCornerStyle: CornerStyle?
    private var snapshotTextInsets = UIEdgeInsets.zero
    private var swiftUIFont = SwiftUILabelSnapshotSUT.defaultFont
    private var swiftUITextColor = SwiftUILabelSnapshotSUT.defaultTextColor
    private var swiftUITextAlignment = SwiftUILabelSnapshotSUT.defaultTextAlignment

    init(adapter: TextOutputSwiftUIAdapter = TextOutputSwiftUIAdapter()) {
        let stateModel = SUILabelStateModel(adapter: adapter)
        self.adapter = adapter
        self.swiftUIStateModel = stateModel
        self.swiftUIView = AnyView(SUILabel(stateModel: stateModel))
    }

    var backgroundColor: UIColor? {
        get { labelBackgroundColor }
        set {
            labelBackgroundColor = newValue
        }
    }

    var textInsets: UIEdgeInsets {
        get { snapshotTextInsets }
        set {
            snapshotTextInsets = newValue
        }
    }

    var cornerStyle: CornerStyle? {
        get { labelCornerStyle }
        set {
            labelCornerStyle = newValue
        }
    }

    var textColor: UIColor! {
        get { swiftUITextColor }
        set {
            guard let newValue else { return }
            swiftUITextColor = newValue
            rebuildSwiftUIView()
        }
    }

    var font: UIFont! {
        get { swiftUIFont }
        set {
            guard let newValue else { return }
            swiftUIFont = newValue
            rebuildSwiftUIView()
        }
    }

    var textAlignment: NSTextAlignment {
        get { swiftUITextAlignment }
        set {
            swiftUITextAlignment = newValue
            rebuildSwiftUIView()
        }
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
        let rootView = SnapshotMirroredLabelContainer(
            content: swiftUIView,
            textInsets: snapshotTextInsets,
            backgroundColor: labelBackgroundColor,
            cornerStyle: labelCornerStyle
        )
        .snapshotEnvironment(configuration: .iPhone(style: appearance.colorScheme))
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

    private func prepareForRendering(_ hostingController: UIViewController) {
        hostingController.loadViewIfNeeded()
        hostingController.view.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
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
        case .some(CornerStyle.none), nil:
            content
        }
    }
}
