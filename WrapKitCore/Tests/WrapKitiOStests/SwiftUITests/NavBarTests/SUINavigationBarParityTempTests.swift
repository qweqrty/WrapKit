#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
@testable import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUINavigationBarParityTempTests: XCTestCase {
    func test_default_state_matchesUIKit() {
        let model = HeaderPresentableModel(style: makeStyle())
        assertMatchesUIKit(model: model)
    }

    func test_center_keyvalue_matchesUIKit() {
        let model = HeaderPresentableModel(
            style: makeStyle(),
            centerView: .keyValue(.init(.text("First"), .text("Second")))
        )
        assertMatchesUIKit(model: model)
    }

    func test_secondary_trailing_matchesUIKit() {
        let model = HeaderPresentableModel(
            style: makeStyle(),
            secondaryTrailingImage: .init(
                title: "Image",
                image: ImageFactory.systemImage(named: "star.fill"),
                height: 24
            )
        )
        assertMatchesUIKit(model: model)
    }
}

@available(iOS 17.0, *)
private extension SUINavigationBarParityTempTests {
    func assertMatchesUIKit(
        model: HeaderPresentableModel,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let configuration = SnapshotConfiguration.iPhone(style: .light)
        let uiKitImage = makeUIKitContainer(model: model).snapshot(for: configuration)
        let swiftUIImage = makeSwiftUIView(model: model).snapshot(for: configuration)

        let diff = Diffing.image(precision: precision).diff(uiKitImage, swiftUIImage)
        XCTAssertNil(diff, diff?.message ?? "", file: file, line: line)
    }

    func makeStyle() -> HeaderPresentableModel.Style {
        .init(
            backgroundColor: .red,
            horizontalSpacing: 1,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green
        )
    }

    func makeUIKitContainer(model: HeaderPresentableModel) -> UIView {
        let navigationBar = NavigationBar()
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear

        container.addSubview(navigationBar)
        navigationBar.anchor(
            .top(container.topAnchor),
            .leading(container.leadingAnchor),
            .trailing(container.trailingAnchor)
        )

        navigationBar.display(model: model)
        container.layoutIfNeeded()
        return container
    }

    func makeSwiftUIView(model: HeaderPresentableModel) -> UIViewController {
        let adapter = HeaderOutputSwiftUIAdapter()
        adapter.display(model: model)

        let host = UIHostingController(rootView: SUINavigationBar(adapter: adapter))
        let container = UIViewController()
        container.view.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.view.backgroundColor = .clear

        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        container.addChild(host)
        container.view.addSubview(host.view)
        host.view.anchor(
            .top(container.view.topAnchor),
            .leading(container.view.leadingAnchor),
            .trailing(container.view.trailingAnchor)
        )
        host.didMove(toParent: container)

        container.view.layoutIfNeeded()
        return container
    }
}
#endif
