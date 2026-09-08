#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit
import XCTest

@available(iOS 17.0, *)
@MainActor
final class SwiftUIAccessibilityTestHostTests: XCTestCase {
    func test_nativeSwiftUIControlsExposeTextAndActivateRenderedActions() throws {
        let originalVoiceOverState = UIAccessibility.isVoiceOverRunning
        defer { XCTAssertEqual(UIAccessibility.isVoiceOverRunning, originalVoiceOverState) }
        var actions: [String] = []
        let host = SwiftUIAccessibilityTestHost(
            rootView: NativeControlsFixture(onAction: { actions.append($0) }),
            size: CGSize(width: 240, height: 180)
        )

        let initialText = try XCTUnwrap(host.element(withLabel: "Count 0"), host.diagnosticDescription)
        XCTAssertFalse(initialText.accessibilityFrame.isEmpty)
        let increment = try XCTUnwrap(host.element(withIdentifier: "native.increment"), host.diagnosticDescription)
        XCTAssertEqual(increment.accessibilityLabel, "Increase")
        XCTAssertEqual(increment.accessibilityHint, "Increases the displayed count")
        XCTAssertTrue(increment.accessibilityActivate())
        host.settle()

        XCTAssertEqual(actions, ["increase"])
        XCTAssertNotNil(host.element(withLabel: "Count 1"), host.diagnosticDescription)
        XCTAssertNil(host.element(withLabel: "Count 0"))

        let hide = try XCTUnwrap(host.element(withLabel: "Hide count"), host.diagnosticDescription)
        XCTAssertTrue(hide.accessibilityActivate())
        host.settle()

        XCTAssertEqual(actions, ["increase", "hide"])
        XCTAssertNotNil(host.element(withLabel: "Hide count"), host.diagnosticDescription)
        XCTAssertNil(host.element(withLabel: "Count 1"))
    }

    func test_overlappingHostsRestoreOriginalAutomationStateAfterLastHostIsReleased() throws {
        let originalAutomationState = SwiftUIAccessibilityTestHost.isAccessibilityAutomationEnabled
        var first: SwiftUIAccessibilityTestHost? = SwiftUIAccessibilityTestHost(rootView: Text("First host"))
        var second: SwiftUIAccessibilityTestHost? = SwiftUIAccessibilityTestHost(rootView: Text("Second host"))

        XCTAssertNotNil(try XCTUnwrap(first).element(withLabel: "First host"))
        XCTAssertNotNil(try XCTUnwrap(second).element(withLabel: "Second host"))
        XCTAssertTrue(SwiftUIAccessibilityTestHost.isAccessibilityAutomationEnabled)

        first = nil
        XCTAssertTrue(SwiftUIAccessibilityTestHost.isAccessibilityAutomationEnabled)
        XCTAssertNotNil(try XCTUnwrap(second).element(withLabel: "Second host"))

        second = nil
        XCTAssertEqual(SwiftUIAccessibilityTestHost.isAccessibilityAutomationEnabled, originalAutomationState)
    }
}

private struct NativeControlsFixture: View {
    let onAction: (String) -> Void
    @State private var count = 0
    @State private var isCountVisible = true

    var body: some View {
        VStack {
            if isCountVisible {
                Text("Count \(count)")
            }
            Button("Increase") {
                count += 1
                onAction("increase")
            }
            .accessibilityIdentifier("native.increment")
            .accessibilityHint("Increases the displayed count")

            Button("Hide count") {
                isCountVisible = false
                onAction("hide")
            }
        }
    }
}
#endif
