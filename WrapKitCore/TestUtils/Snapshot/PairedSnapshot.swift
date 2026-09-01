#if os(iOS)
import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(XCTest)
import XCTest

public enum SnapshotAppearance: CaseIterable, Hashable {
    case light
    case dark
}

public struct SnapshotBaselineAliases {
    public let iOS18_5: [SnapshotAppearance: String]?
    public let iOS26: [SnapshotAppearance: String]?

    public init(
        iOS18_5: [SnapshotAppearance: String]? = nil,
        iOS26: [SnapshotAppearance: String]? = nil
    ) {
        self.iOS18_5 = iOS18_5
        self.iOS26 = iOS26
    }

    public static let none = SnapshotBaselineAliases()
}

public extension SnapshotAppearance {
    var uiKitConfiguration: SnapshotConfiguration {
        .iPhone(style: userInterfaceStyle)
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }

#if canImport(SwiftUI)
    @available(iOS 17.0, *)
    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }
#endif
}

public protocol UIKitSnapshotSource {
    func uiKitSnapshot(for appearance: SnapshotAppearance) -> UIImage
}

public protocol PairedSnapshotSource: UIKitSnapshotSource {
    @available(iOS 17.0, *)
    func swiftUISnapshot(for appearance: SnapshotAppearance) -> UIImage
}

/// Opt in when the immutable UIKit baseline uses a historical fixture proposal that is not a
/// production-equivalent proposal for SwiftUI parity. The baseline remains strict, while the
/// paired comparison renders both implementations under the same layout contract.
public protocol PairedSnapshotParitySource: PairedSnapshotSource {
    func uiKitParitySnapshot(for appearance: SnapshotAppearance) -> UIImage
}

public extension XCTestCase {
    func assert<Source: PairedSnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifyPairedSnapshot(
            source,
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            expectation: .matches,
            file: file,
            line: line
        )
    }

    func assertFail<Source: PairedSnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifyPairedSnapshot(
            source,
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            expectation: .differs,
            file: file,
            line: line
        )
    }

    /// Compares the current UIKit and SwiftUI renders without requiring a stored UIKit baseline.
    /// Use this only for a newly-added paired scenario that already has exact functional/layout
    /// coverage and therefore cannot record a baseline as part of the current change.
    func assertParity<Source: PairedSnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        reason: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifyParityOnlySnapshot(
            source,
            named: name,
            appearances: appearances,
            reason: reason,
            file: file,
            line: line
        )
    }

    func record<Source: PairedSnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifyPairedSnapshot(
            source,
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            expectation: .record,
            file: file,
            line: line
        )
    }

    func assertUIKitOnlySnapshot<Source: UIKitSnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        reason: String = "The scenario depends on UIKit-only state outside the shared Output contract.",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifyUIKitSnapshots(
            source,
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            expectation: .matches,
            reason: reason,
            file: file,
            line: line
        )
    }

    func assertUIKitOnlySnapshot(
        view: UIView,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        reason: String = "The scenario depends on UIKit-only state outside the shared Output contract.",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertUIKitOnlySnapshot(
            snapshot: UIViewSnapshotSource(view: view),
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            reason: reason,
            file: file,
            line: line
        )
    }

    func assertUIKitOnlySnapshotFail<Source: UIKitSnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        reason: String = "The scenario depends on UIKit-only state outside the shared Output contract.",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifyUIKitSnapshots(
            source,
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            expectation: .differs,
            reason: reason,
            file: file,
            line: line
        )
    }

    func assertUIKitOnlySnapshotFail(
        view: UIView,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        reason: String = "The scenario depends on UIKit-only state outside the shared Output contract.",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertUIKitOnlySnapshotFail(
            snapshot: UIViewSnapshotSource(view: view),
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            reason: reason,
            file: file,
            line: line
        )
    }

    func recordUIKitOnlySnapshot<Source: UIKitSnapshotSource>(
        snapshot source: Source,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        reason: String = "The scenario depends on UIKit-only state outside the shared Output contract.",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verifyUIKitSnapshots(
            source,
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            expectation: .record,
            reason: reason,
            file: file,
            line: line
        )
    }

    func recordUIKitOnlySnapshot(
        view: UIView,
        named name: String,
        appearances: [SnapshotAppearance] = SnapshotAppearance.allCases,
        baselineAliases: SnapshotBaselineAliases = .none,
        reason: String = "The scenario depends on UIKit-only state outside the shared Output contract.",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        recordUIKitOnlySnapshot(
            snapshot: UIViewSnapshotSource(view: view),
            named: name,
            appearances: appearances,
            baselineAliases: baselineAliases,
            reason: reason,
            file: file,
            line: line
        )
    }
}

private struct UIViewSnapshotSource: UIKitSnapshotSource {
    let view: UIView

    func uiKitSnapshot(for appearance: SnapshotAppearance) -> UIImage {
        view.snapshot(for: appearance.uiKitConfiguration)
    }
}

private enum PairedSnapshotExpectation {
    case matches
    case differs
    case record
}

private extension XCTestCase {
    func verifyPairedSnapshot<Source: PairedSnapshotSource>(
        _ source: Source,
        named name: String,
        appearances: [SnapshotAppearance],
        baselineAliases: SnapshotBaselineAliases,
        expectation: PairedSnapshotExpectation,
        file: StaticString,
        line: UInt
    ) {
        appearances.forEach { appearance in
            let baselineName = pairedSnapshotName(
                named: name,
                appearance: appearance,
                aliases: baselineAliases
            )

            XCTContext.runActivity(named: appearance.activityName) { _ in
                let uiKitSnapshot = source.uiKitSnapshot(for: appearance)
                let uiKitParitySnapshot = (
                    source as? any PairedSnapshotParitySource
                )?.uiKitParitySnapshot(for: appearance) ?? uiKitSnapshot
                let swiftUISnapshot: UIImage?
                if #available(iOS 17.0, *) {
                    swiftUISnapshot = source.swiftUISnapshot(for: appearance)
                } else {
                    swiftUISnapshot = nil
                }

                switch expectation {
                case .matches:
                    assert(snapshot: uiKitSnapshot, named: baselineName, file: file, line: line)
                case .differs:
                    assertFail(snapshot: uiKitSnapshot, named: baselineName, file: file, line: line)
                case .record:
                    record(snapshot: uiKitSnapshot, named: baselineName, file: file, line: line)
                }

                if let swiftUISnapshot {
                    assertSwiftUIParity(
                        snapshot: swiftUISnapshot,
                        matchingUIKit: uiKitParitySnapshot,
                        named: baselineName,
                        file: file,
                        line: line
                    )
                }
            }
        }
    }

    func verifyParityOnlySnapshot<Source: PairedSnapshotSource>(
        _ source: Source,
        named name: String,
        appearances: [SnapshotAppearance],
        reason: String,
        file: StaticString,
        line: UInt
    ) {
        guard #available(iOS 17.0, *) else { return }

        appearances.forEach { appearance in
            let snapshotName = pairedSnapshotName(
                named: name,
                appearance: appearance,
                aliases: .none
            )

            XCTContext.runActivity(
                named: "\(appearance.activityName) · parity only: \(reason)"
            ) { _ in
                let uiKitSnapshot = (
                    source as? any PairedSnapshotParitySource
                )?.uiKitParitySnapshot(for: appearance) ?? source.uiKitSnapshot(for: appearance)
                assertSwiftUIParity(
                    snapshot: source.swiftUISnapshot(for: appearance),
                    matchingUIKit: uiKitSnapshot,
                    named: snapshotName,
                    file: file,
                    line: line
                )
            }
        }
    }

    func verifyUIKitSnapshots<Source: UIKitSnapshotSource>(
        _ source: Source,
        named name: String,
        appearances: [SnapshotAppearance],
        baselineAliases: SnapshotBaselineAliases,
        expectation: PairedSnapshotExpectation,
        reason: String,
        file: StaticString,
        line: UInt
    ) {
        appearances.forEach { appearance in
            let baselineName = pairedSnapshotName(
                named: name,
                appearance: appearance,
                aliases: baselineAliases
            )
            let snapshot = source.uiKitSnapshot(for: appearance)

            switch expectation {
            case .matches:
                assertUIKitOnlySnapshot(
                    snapshot: snapshot,
                    named: baselineName,
                    reason: reason,
                    file: file,
                    line: line
                )
            case .differs:
                assertUIKitOnlySnapshotFail(
                    snapshot: snapshot,
                    named: baselineName,
                    reason: reason,
                    file: file,
                    line: line
                )
            case .record:
                record(snapshot: snapshot, named: baselineName, file: file, line: line)
            }
        }
    }

    func pairedSnapshotName(
        named name: String,
        appearance: SnapshotAppearance,
        aliases: SnapshotBaselineAliases
    ) -> String {
        let alias: String?
        if #available(iOS 26.0, *) {
            alias = aliases.iOS26?[appearance]
        } else {
            alias = aliases.iOS18_5?[appearance]
        }

        return alias ?? "\(snapshotOSPrefix)_\(name)_\(appearance.nameSuffix)"
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

    var activityName: String {
        switch self {
        case .light: "Light appearance"
        case .dark: "Dark appearance"
        }
    }
}
#endif
#endif
