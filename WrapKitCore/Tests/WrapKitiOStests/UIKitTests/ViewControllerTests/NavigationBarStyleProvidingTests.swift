#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
import WrapKit
import XCTest

@MainActor
final class NavigationBarStyleProvidingTests: XCTestCase {
    func test_contentStyleIsAppliedBeforePresenterViewDidLoad() {
        let style = makeStyle(background: .yellow, title: .red, fontSize: 24)
        let output = LoadObserver()
        let sut = ViewController(contentView: StyledContentView(style: style), lifeCycleViewOutput: output)
        var observedBackground: UIColor?
        var observedTitleColor: UIColor?
        var observedTitleFont: UIFont?
        output.onLoad = { [weak sut] in
            observedBackground = sut?.navigationItem.standardAppearance?.backgroundColor
            observedTitleColor = sut?.headerOutput.headerTitleLabel.textColor
            observedTitleFont = sut?.headerOutput.headerTitleLabel.font
        }

        sut.loadViewIfNeeded()

        XCTAssertEqual(output.loadCount, 1)
        XCTAssertEqual(observedBackground, style.backgroundColor)
        XCTAssertEqual(observedTitleColor, style.primeColor)
        XCTAssertEqual(observedTitleFont, style.primeFont)
    }

    func test_presenterCanOverrideContentStyleWithoutItBeingReappliedOnAppearance() {
        let contentStyle = makeStyle(background: .yellow, title: .red, fontSize: 24)
        let presenterStyle = makeStyle(background: .green, title: .blue, fontSize: 19)
        let output = LoadObserver()
        let sut = ViewController(contentView: StyledContentView(style: contentStyle), lifeCycleViewOutput: output)
        output.onLoad = { [weak sut] in
            sut?.headerOutput.display(style: presenterStyle)
        }

        sut.loadViewIfNeeded()
        sut.viewWillAppear(false)

        XCTAssertEqual(sut.navigationItem.standardAppearance?.backgroundColor, presenterStyle.backgroundColor)
        XCTAssertEqual(sut.headerOutput.headerTitleLabel.textColor, presenterStyle.primeColor)
        XCTAssertEqual(sut.headerOutput.headerTitleLabel.font, presenterStyle.primeFont)
    }

    func test_plainContentDoesNotCreateAnUnrequestedHeader() {
        let sut = ViewController(contentView: UIView())

        sut.loadViewIfNeeded()

        XCTAssertNil(sut.navigationItem.standardAppearance)
        XCTAssertNil(sut.navigationItem.titleView)
        XCTAssertFalse(sut.navigationItem.hidesBackButton)
    }

    private func makeStyle(background: UIColor, title: UIColor, fontSize: CGFloat) -> HeaderPresentableModel.Style {
        .init(
            backgroundColor: background,
            horizontalSpacing: 8,
            primeFont: .systemFont(ofSize: fontSize, weight: .semibold),
            primeColor: title,
            secondaryFont: .systemFont(ofSize: 12),
            secondaryColor: .gray
        )
    }
}

private final class StyledContentView: UIView, NavigationBarStyleProviding {
    let navigationBarStyle: HeaderPresentableModel.Style

    init(style: HeaderPresentableModel.Style) {
        navigationBarStyle = style
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class LoadObserver: LifeCycleViewOutput {
    var onLoad: (() -> Void)?
    private(set) var loadCount = 0

    func viewDidLoad() {
        loadCount += 1
        onLoad?()
    }
}
#endif
