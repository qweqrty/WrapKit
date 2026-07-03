import WrapKit
import WrapKitTestUtils
import UIKit

#if canImport(SwiftUI)
import SwiftUI

final class PairedNavigationBarSnapshotSUT: NSObject, HeaderOutput {
    let uiKitView: NavigationBar
    private let swiftUIAdapter: HeaderOutputSwiftUIAdapter

    private var lastModel: HeaderPresentableModel?
    private var standaloneBackgroundColor: WrapKit.Color?
    private var lastStyle: HeaderPresentableModel.Style?
    private var lastCenterView: HeaderPresentableModel.CenterView?
    private var lastLeadingCard: CardViewPresentableModel?
    private var lastPrimeTrailingImage: ButtonPresentableModel?
    private var lastSecondaryTrailingImage: ButtonPresentableModel?
    private var lastTertiaryTrailingImage: ButtonPresentableModel?
    private var lastIsHidden: Bool?

    init(
        uiKitView: NavigationBar = NavigationBar(),
        swiftUIAdapter: HeaderOutputSwiftUIAdapter = HeaderOutputSwiftUIAdapter()
    ) {
        self.uiKitView = uiKitView
        self.swiftUIAdapter = swiftUIAdapter
    }

    var backgroundColor: WrapKit.Color? {
        get { uiKitView.backgroundColor }
        set {
            uiKitView.backgroundColor = newValue
            standaloneBackgroundColor = newValue
            if var style = lastStyle, let newValue {
                style = .init(
                    backgroundColor: newValue,
                    horizontalSpacing: style.horizontalSpacing,
                    primeFont: style.primeFont,
                    primeColor: style.primeColor,
                    secondaryFont: style.secondaryFont,
                    secondaryColor: style.secondaryColor,
                    numberOfLines: style.numberOfLines
                )
                lastStyle = style
                swiftUIAdapter.display(style: style)
            }
        }
    }

    var leadingCardView: CardView { uiKitView.leadingCardView }
    var secondaryTrailingImageWrapperView: WrapperView<WrapKit.Button> { uiKitView.secondaryTrailingImageWrapperView }
    var tertiaryTrailingImageWrapperView: WrapperView<WrapKit.Button> { uiKitView.tertiaryTrailingImageWrapperView }

    func display(model: HeaderPresentableModel?) {
        uiKitView.display(model: model)
        lastModel = model
        swiftUIAdapter.display(model: model)
    }

    func display(style: HeaderPresentableModel.Style?) {
        uiKitView.display(style: style)
        lastStyle = style
        swiftUIAdapter.display(style: style)
    }

    func display(centerView: HeaderPresentableModel.CenterView?) {
        uiKitView.display(centerView: centerView)
        lastCenterView = centerView
        swiftUIAdapter.display(centerView: centerView)
    }

    func display(leadingCard: CardViewPresentableModel?) {
        uiKitView.display(leadingCard: leadingCard)
        lastLeadingCard = leadingCard
        swiftUIAdapter.display(leadingCard: leadingCard)
    }

    func display(primeTrailingImage: ButtonPresentableModel?) {
        uiKitView.display(primeTrailingImage: primeTrailingImage)
        lastPrimeTrailingImage = primeTrailingImage
        swiftUIAdapter.display(primeTrailingImage: primeTrailingImage)
    }

    func display(secondaryTrailingImage: ButtonPresentableModel?) {
        uiKitView.display(secondaryTrailingImage: secondaryTrailingImage)
        lastSecondaryTrailingImage = secondaryTrailingImage
        swiftUIAdapter.display(secondaryTrailingImage: secondaryTrailingImage)
    }

    func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        uiKitView.display(tertiaryTrailingImage: tertiaryTrailingImage)
        lastTertiaryTrailingImage = tertiaryTrailingImage
        swiftUIAdapter.display(tertiaryTrailingImage: tertiaryTrailingImage)
    }

    func display(isHidden: Bool) {
        uiKitView.display(isHidden: isHidden)
        lastIsHidden = isHidden
        swiftUIAdapter.display(isHidden: isHidden)
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let snapshotBackgroundColor = lastStyle?.backgroundColor ?? standaloneBackgroundColor
        let rootView = SnapshotMirroredNavigationBarContainer(
            adapter: swiftUIAdapter,
            backgroundColor: snapshotBackgroundColor
        )

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 300))
        container.backgroundColor = .clear
        container.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: container.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        replaySwiftUIState()
        let warmup: TimeInterval = 0.5
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return container.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }

    private func replaySwiftUIState() {
        let applyState = { [self] in
            swiftUIAdapter.display(model: lastModel)
            swiftUIAdapter.display(style: lastStyle)
            swiftUIAdapter.display(centerView: lastCenterView)
            swiftUIAdapter.display(leadingCard: lastLeadingCard)
            swiftUIAdapter.display(primeTrailingImage: lastPrimeTrailingImage)
            swiftUIAdapter.display(secondaryTrailingImage: lastSecondaryTrailingImage)
            swiftUIAdapter.display(tertiaryTrailingImage: lastTertiaryTrailingImage)
            swiftUIAdapter.display(isHidden: lastIsHidden ?? false)
        }

        if Thread.isMainThread {
            applyState()
        } else {
            DispatchQueue.main.sync {
                applyState()
            }
        }
    }
}

@available(iOS 17.0, *)
private struct SnapshotMirroredNavigationBarContainer: View {
    let adapter: HeaderOutputSwiftUIAdapter
    let backgroundColor: WrapKit.Color?

    var body: some View {
        VStack(spacing: 0) {
            SUINavigationBar(adapter: adapter)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(SwiftUIColor(backgroundColor ?? .clear))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
    }
}
#endif
