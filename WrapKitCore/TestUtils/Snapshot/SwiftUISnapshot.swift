#if os(iOS) && canImport(SwiftUI) && canImport(XCTest)
import SwiftUI
import UIKit
import XCTest

public protocol SwiftUISnapshotSource {
    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage
}

public extension XCTestCase {
    func assert<Source: SwiftUISnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifySwiftUISnapshots(
            source,
            named: name,
            appearances: appearances,
            expectation: .matches,
            file: file,
            line: line
        )
    }

    func assertFail<Source: SwiftUISnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifySwiftUISnapshots(
            source,
            named: name,
            appearances: appearances,
            expectation: .differs,
            file: file,
            line: line
        )
    }

}

private enum SwiftUISnapshotExpectation {
    case matches
    case differs
}

private extension XCTestCase {
    func verifySwiftUISnapshots<Source: SwiftUISnapshotSource>(
        _ source: Source,
        named name: String,
        appearances: [SnapshotAppearance],
        expectation: SwiftUISnapshotExpectation,
        file: StaticString,
        line: UInt
    ) {
        guard #available(iOS 17.0, *) else { return }

        let baselineDirectory = uiKitBaselineDirectory(for: file)

        appearances.forEach { appearance in
            let snapshotName = "\(snapshotOSPrefix)_\(name)_\(appearance.nameSuffix)"
            let baselineName = uiKitBaselineName(for: snapshotName)
            let snapshot = source.swiftUISnapshot(for: appearance)

            switch expectation {
            case .matches:
                assert(
                    snapshot: snapshot,
                    named: baselineName,
                    baselineDirectory: baselineDirectory,
                    precision: SwiftUISnapshotPrecision.standard,
                    file: file,
                    line: line
                )
            case .differs:
                assertFail(
                    snapshot: snapshot,
                    named: baselineName,
                    baselineDirectory: baselineDirectory,
                    precision: SwiftUISnapshotPrecision.fail,
                    file: file,
                    line: line
                )
            }
        }
    }

    func uiKitBaselineDirectory(for file: StaticString) -> URL {
        let swiftUITestFile = URL(fileURLWithPath: String(describing: file))
        let componentDirectory = swiftUITestFile.deletingLastPathComponent().lastPathComponent
        let uiKitComponentDirectory: String

        switch componentDirectory {
        case "LabelSnapshotTests":
            uiKitComponentDirectory = "LabelTests"
        case "NavigationBarSnapshotTests":
            uiKitComponentDirectory = "NavBarSnapshotTests"
        default:
            uiKitComponentDirectory = componentDirectory
        }

        return swiftUITestFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("UIKitTests")
            .appendingPathComponent(uiKitComponentDirectory)
            .appendingPathComponent("snapshots")
    }

    func uiKitBaselineName(for snapshotName: String) -> String {
        switch snapshotName {
        case "iOS18.5_LABEL_TITLE_WITH_DOUBLELINE_LIGHT":
            return "iOS18.5_LABEL_TITLE_WITH_DOUBLELINELIGHT"
        case "iOS26_LABEL_TITLE_WITH_TRAILINGIMAGE_LIGHT":
            return "iOS26_LABEL_TITLE_WITH_TRAILINGIMAGELIGHT"
        default:
            return snapshotName
        }
    }

    var snapshotOSPrefix: String {
        if #available(iOS 26.0, *) {
            return "iOS26"
        }
        return "iOS18.5"
    }
}

private extension SnapshotAppearance {
    var nameSuffix: String {
        switch self {
        case .light: "LIGHT"
        case .dark: "DARK"
        }
    }
}
#endif
