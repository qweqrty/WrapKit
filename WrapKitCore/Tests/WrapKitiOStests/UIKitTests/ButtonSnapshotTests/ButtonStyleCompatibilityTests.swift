#if canImport(UIKit)
import UIKit
import XCTest
@testable import WrapKit

final class ButtonStyleCompatibilityTests: XCTestCase {
    func test_legacyBackgroundColorInitializer_preservesColorAPI() {
        let color = UIColor.systemRed

        let style = ButtonStyle(backgroundColor: color)

        XCTAssertEqual(style.backgroundColor, color)
        XCTAssertEqual(style.backgroundStyle, .solid(color))
    }

    func test_colorStyleInitializer_preservesGradientAPI() {
        let gradient = ColorStyle.gradient(.init(colors: [.systemPink, .systemBlue]))

        let style = ButtonStyle(backgroundColor: gradient)

        XCTAssertNil(style.backgroundColor)
        XCTAssertEqual(style.backgroundStyle, gradient)
    }

    func test_legacyButtonOutputConformer_usesDefaultContentInsetImplementation() {
        let output: any ButtonOutput = LegacyButtonOutput()

        output.display(contentInset: .init(top: 1, leading: 2, bottom: 3, trailing: 4))
    }
}

private final class LegacyButtonOutput: ButtonOutput {
    func display(model: ButtonPresentableModel?) {}
    func display(enabled: Bool) {}
    func display(image: Image?) {}
    func display(style: ButtonStyle?) {}
    func display(title: String?) {}
    func display(spacing: CGFloat) {}
    func display(onPress: (() -> Void)?) {}
    func display(height: CGFloat) {}
    func display(isHidden: Bool) {}
}
#endif
