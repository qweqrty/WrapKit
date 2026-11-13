import SwiftUI
import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUIWrapperViewSnapshotTests: XCTestCase {

    // WRAPPERVIEW_WITH_BORDER has no SwiftUI component-state equivalent: SUIWrapperView
    // exposes no border input. Adding an overlay in this fixture would only test the caller.

    func test_wrapperView_default_state() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red
        )

        assertSnapshots(sut, named: "WRAPPERVIEW_DEFAULT_STATE")
    }

    func test_fail_wrapperView_default_state() {
        let sut = makeColorSUT(
            contentColor: .systemYellow,
            wrapperBackgroundColor: .red
        )

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_DEFAULT_STATE")
    }

    func test_wrapperView_with_content() {
        let sut = makeTextSUT(text: "Content to show!")

        assertSnapshots(sut, named: "WRAPPERVIEW_WITH_CONTENT")
    }

    func test_fail_wrapperView_with_content() {
        let sut = makeTextSUT(text: "Content to show!.")

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_WITH_CONTENT")
    }

    func test_wrapperView_with_multiline_text() {
        let sut = makeMultilineTextSUT(
            text: "This is a longer text that should wrap to multiple lines in the wrapper view"
        )

        assertSnapshots(sut, named: "WRAPPERVIEW_MULTILINE_TEXT")
    }

    func test_fail_wrapperView_with_multiline_text() {
        let sut = makeMultilineTextSUT(
            text: "This is a longer text that should wrap to multiple lines in the wrapper view."
        )

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_MULTILINE_TEXT")
    }

    func test_wrapperView_hidden_state() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red,
            isHidden: true
        )

        assertSnapshots(sut, named: "WRAPPERVIEW_HIDDEN_STATE")
    }

    func test_fail_wrapperView_hidden_state() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red,
            isHidden: false
        )

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_HIDDEN_STATE")
    }

    func test_wrapperView_with_button() {
        let sut = makeButtonSUT(backgroundColor: .cyan)

        assertSnapshots(sut, named: "WRAPPERVIEW_WITH_BUTTON")
    }

    func test_fail_wrapperView_with_button() {
        let sut = makeButtonSUT(backgroundColor: .blue)

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_WITH_BUTTON")
    }

    func test_wrapperView_no_padding() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red,
            padding: .zero
        )

        assertSnapshots(sut, named: "WRAPPERVIEW_NO_PADDING")
    }

    func test_fail_wrapperView_no_padding() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red,
            padding: .init(top: 1, leading: 0, bottom: 0, trailing: 0)
        )

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_NO_PADDING")
    }

    func test_wrapperView_large_padding() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red,
            padding: .init(all: 60)
        )

        assertSnapshots(sut, named: "WRAPPERVIEW_LARGE_PADDING")
    }

    func test_fail_wrapperView_large_padding() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red,
            padding: .init(top: 59, leading: 60, bottom: 60, trailing: 60)
        )

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_LARGE_PADDING")
    }

    func test_wrapperView_asymmetric_padding() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red,
            padding: .init(top: 0, leading: 20, bottom: 45, trailing: 85)
        )

        assertSnapshots(sut, named: "WRAPPERVIEW_ASYMMETRIC_PADDING")
    }

    func test_fail_wrapperView_asymmetric_padding() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            wrapperBackgroundColor: .red,
            padding: .init(top: 1, leading: 20, bottom: 45, trailing: 85)
        )

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_ASYMMETRIC_PADDING")
    }

    func test_wrapperView_with_rounded_corners() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            contentCornerRadius: 16,
            wrapperBackgroundColor: .red,
            wrapperCornerRadius: 16
        )

        assertSnapshots(sut, named: "WRAPPERVIEW_ROUNDED_CORNERS")
    }

    func test_fail_wrapperView_with_rounded_corners() {
        let sut = makeColorSUT(
            contentColor: .yellow,
            contentCornerRadius: 15,
            wrapperBackgroundColor: .red,
            wrapperCornerRadius: 16
        )

        assertSnapshotsFail(sut, named: "WRAPPERVIEW_ROUNDED_CORNERS")
    }
}

@available(iOS 17.0, *)
private extension SUIWrapperViewSnapshotTests {
    func makeColorSUT(
        contentColor: UIColor,
        contentCornerRadius: CGFloat = 0,
        wrapperBackgroundColor: UIColor,
        wrapperCornerRadius: CGFloat = 0,
        isHidden: Bool = false,
        padding: WrapKit.EdgeInsets = .init(all: 20),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SwiftUIWrapperViewSnapshotSUT {
        let content = AnyView(
            SwiftUIColor(contentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(contentCornerRadius)
        )
        return makeSUT(
            content: content,
            wrapperBackgroundColor: wrapperBackgroundColor,
            wrapperCornerRadius: wrapperCornerRadius,
            isHidden: isHidden,
            padding: padding,
            file: file,
            line: line
        )
    }

    func makeTextSUT(
        text: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SwiftUIWrapperViewSnapshotSUT {
        let content = AnyView(
            ZStack(alignment: .topLeading) {
                SwiftUIColor(UIColor.yellow)
                Text(text)
                    .font(.system(size: 17))
                    .foregroundStyle(SwiftUIColor(UIColor.black))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        )
        return makeSUT(
            content: content,
            wrapperBackgroundColor: .red,
            file: file,
            line: line
        )
    }

    func makeMultilineTextSUT(
        text: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SwiftUIWrapperViewSnapshotSUT {
        let content = AnyView(
            ZStack {
                SwiftUIColor(UIColor.white)
                Text(text)
                    .font(.system(size: 20))
                    .foregroundStyle(SwiftUIColor(UIColor.black))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        return makeSUT(
            content: content,
            wrapperBackgroundColor: .clear,
            file: file,
            line: line
        )
    }

    func makeButtonSUT(
        backgroundColor: UIColor,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SwiftUIWrapperViewSnapshotSUT {
        let image = UIImage(systemName: "star.fill")
        let model = ButtonPresentableModel(
            title: "Tap Me",
            image: image,
            style: .init(
                backgroundColor: backgroundColor,
                titleColor: .black,
                cornerStyle: .none
            )
        )
        let content = AnyView(
            ZStack {
                SwiftUIColor(UIColor.red)
                SUIButtonView(model: model, isEnabled: true)
                    .frame(width: 120, height: 44)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        return makeSUT(
            content: content,
            wrapperBackgroundColor: .clear,
            file: file,
            line: line
        )
    }

    func makeSUT(
        content: AnyView,
        wrapperBackgroundColor: UIColor,
        wrapperCornerRadius: CGFloat = 0,
        isHidden: Bool = false,
        padding: WrapKit.EdgeInsets = .init(all: 20),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SwiftUIWrapperViewSnapshotSUT {
        let view = SUIWrapperView(
            backgroundColor: SwiftUIColor(wrapperBackgroundColor),
            cornerRadius: wrapperCornerRadius,
            isHidden: isHidden,
            padding: padding
        ) {
            content
        }
        let sut = SwiftUIWrapperViewSnapshotSUT(content: AnyView(view))
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func assertSnapshots(
        _ sut: SwiftUIWrapperViewSnapshotSUT,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertSnapshots(sut, named: snapshotName, mustMatch: true, file: file, line: line)
    }

    func assertSnapshotsFail(
        _ sut: SwiftUIWrapperViewSnapshotSUT,
        named snapshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertSnapshots(sut, named: snapshotName, mustMatch: false, file: file, line: line)
    }

    func assertSnapshots(
        _ sut: SwiftUIWrapperViewSnapshotSUT,
        named snapshotName: String,
        mustMatch: Bool,
        file: StaticString,
        line: UInt
    ) {
        guard let runtime = SnapshotRuntime.currentBaselinePrefix else {
            XCTFail("Unsupported snapshot runtime.", file: file, line: line)
            return
        }

        SnapshotAppearance.allCases.forEach { appearance in
            let suffix = appearance == .light ? "LIGHT" : "DARK"
            let name = "SwiftUI_\(runtime)_\(snapshotName)_\(suffix)"
            let snapshot = sut.swiftUISnapshot(for: appearance)
            if mustMatch {
                assert(
                    snapshot: snapshot,
                    named: name,
                    precision: SwiftUISnapshotPrecision.standard,
                    file: file,
                    line: line
                )
            } else {
                assertFail(
                    snapshot: snapshot,
                    named: name,
                    precision: SwiftUISnapshotPrecision.fail,
                    file: file,
                    line: line
                )
            }
        }
    }
}
