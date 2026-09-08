#if canImport(UIKit)
import Foundation
import XCTest

final class SnapshotOriginInventoryTests: XCTestCase {
    func test_separateOriginInventoryHasExpectedCrossPlatformPairs() throws {
        let testRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let uiKitOrigins = try origins(
            below: testRoot.appendingPathComponent("UIKitTests"),
            swiftUI: false
        )
        let swiftUIOrigins = try origins(
            below: testRoot.appendingPathComponent("SwiftUITests/SwiftUISnapshotTests"),
            swiftUI: true
        )
        let uiKitNames = Set(uiKitOrigins.map(\.fileName))
        let swiftUIUIKitNames = Set(swiftUIOrigins.map(\.uiKitFileName))
        let allOrigins = uiKitOrigins + swiftUIOrigins
        let physicalFiles = Set(allOrigins.map(\.physicalFileIdentifier))
        let uiKitPairs = Set(uiKitOrigins.map(\.pairKey))
        let swiftUIPairs = Set(swiftUIOrigins.map(\.pairKey))
        let missingSwiftUI = uiKitPairs.subtracting(swiftUIPairs)
        let missingUIKit = swiftUIPairs.subtracting(uiKitPairs)
        let expectedMissingSwiftUI = Set(
            uiKitOrigins
                .filter { documentedUIKitOnlyScenarios.contains($0.scenarioKey) }
                .map(\.pairKey)
        )
        let reviewedUIKitManifest = try loadReviewedUIKitManifest()
        let currentUIKitManifest = Set(manifestEntries(for: uiKitOrigins))
        let removedReviewedScenarios = reviewedUIKitManifest.subtracting(currentUIKitManifest)
        let unreviewedScenarios = currentUIKitManifest.subtracting(reviewedUIKitManifest)

        XCTAssertEqual(uiKitNames.count, uiKitOrigins.count, "UIKit origin names must be unique")
        XCTAssertEqual(swiftUIUIKitNames.count, swiftUIOrigins.count, "SwiftUI origin names must be unique")
        XCTAssertEqual(
            physicalFiles.count,
            allOrigins.count,
            "UIKit and SwiftUI origins must be independent files, not hard links"
        )
        XCTAssertTrue(
            removedReviewedScenarios.isEmpty,
            "Reviewed UIKit snapshot scenarios or variants were removed:\n"
                + removedReviewedScenarios.sorted().joined(separator: "\n")
        )
        XCTAssertTrue(
            unreviewedScenarios.isEmpty,
            "UIKit snapshot scenarios or variants changed without updating the reviewed manifest:\n"
                + unreviewedScenarios.sorted().joined(separator: "\n")
        )
        XCTAssertTrue(
            missingUIKit.isEmpty,
            "SwiftUI origins without a UIKit scenario:\n\(missingUIKit.sorted().joined(separator: "\n"))"
        )
        XCTAssertEqual(missingSwiftUI, expectedMissingSwiftUI, "UIKit-only origin files changed")

        try assertOriginsAreReferencedByPositiveTests(allOrigins)
    }

    func test_positiveTestSource_excludesMutationTestsRegardlessOfName() {
        let source = """
        func test_visibleState() {
            let snapshotName = "VISIBLE_STATE"
            assert(snapshot: image, named: snapshotName)
        }

        func test_visibleStateShouldFail() {
            let snapshotName = "MUTATION_ONLY_STATE"
            assertFail(snapshot: image, named: snapshotName)
        }

        func test_otherMutationOnlyState() {
            let snapshotName = "HELPER_MUTATION_ONLY_STATE"
            assertFailSnapshots(of: view, named: snapshotName)
        }

        func test_orphanedStateWithoutSnapshotAssertion() {
            let snapshotName = "NO_ASSERTION_STATE"
        }

        func test_mismatchedStateName() {
            let snapshotName = "DECLARED_BUT_NOT_ASSERTED_STATE"
            assert(snapshot: image, named: "DIFFERENT_STATE")
        }
        """

        let result = positiveTestSource(source)

        XCTAssertTrue(result.contains("VISIBLE_STATE"))
        XCTAssertFalse(result.contains("MUTATION_ONLY_STATE"))
        XCTAssertFalse(result.contains("HELPER_MUTATION_ONLY_STATE"))
        XCTAssertFalse(result.contains("NO_ASSERTION_STATE"))
        XCTAssertFalse(result.contains("DECLARED_BUT_NOT_ASSERTED_STATE"))
        XCTAssertTrue(result.contains("DIFFERENT_STATE"))
    }

    func test_assertedOriginFileNames_doesNotBlessUnassertedRuntimeOrAppearanceVariants() {
        let source = """
        func test_visibleState() {
            let snapshotName = "VISIBLE_STATE"
            assert(snapshot: image, named: "SwiftUI_iOS26_\\(snapshotName)_LIGHT")
        }
        """

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: true),
            ["SwiftUI_iOS26_VISIBLE_STATE_LIGHT.png"]
        )
    }

    func test_assertedOriginFileNames_expandsKnownPairHelperToAllRuntimeAndAppearanceVariants() {
        let source = """
        func test_visibleState() {
            let snapshotName = "VISIBLE_STATE"
            assertSnapshots(sut, named: snapshotName)
        }
        """

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: true),
            [
                "SwiftUI_iOS18.5_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS18.5_VISIBLE_STATE_LIGHT.png",
                "SwiftUI_iOS26_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS26_VISIBLE_STATE_LIGHT.png",
            ]
        )
    }

    func test_assertedOriginFileNames_ignoresNamedArgumentsOutsideSnapshotAssertions() {
        let source = """
        func test_visibleState() {
            XCTContext.runActivity(named: "ORPHAN_STATE") { _ in }
            assertSnapshots(sut, named: "VISIBLE_STATE")
        }
        """

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: true),
            [
                "SwiftUI_iOS18.5_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS18.5_VISIBLE_STATE_LIGHT.png",
                "SwiftUI_iOS26_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS26_VISIBLE_STATE_LIGHT.png",
            ]
        )
    }

    func test_assertedOriginFileNames_ignoresAssertionsInsideCommentsAndStringLiterals() {
        let source = #"""
        func test_visibleState() {
            // assertSnapshots(sut, named: "LINE_COMMENT_STATE")
            /*
             assertSnapshots(sut, named: "BLOCK_COMMENT_STATE")
             */
            let note = "assertSnapshots(sut, named: \"STRING_LITERAL_STATE\")"
            assertSnapshots(sut, named: "VISIBLE_STATE")
        }
        """#

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: true),
            [
                "SwiftUI_iOS18.5_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS18.5_VISIBLE_STATE_LIGHT.png",
                "SwiftUI_iOS26_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS26_VISIBLE_STATE_LIGHT.png",
            ]
        )
    }

    func test_assertedOriginFileNames_ignoresBracesInsideStringLiterals() {
        let source = #"""
        func test_visibleState() {
            let closingBrace = "}"
            let multilineJSON = """
            { "value": true }
            """
            assertSnapshots(sut, named: "VISIBLE_STATE")
        }

        func test_secondVisibleState() {
            let openingBrace = "{"
            assertSnapshots(sut, named: "SECOND_VISIBLE_STATE")
        }
        """#

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: true),
            Set([
                "SwiftUI_iOS18.5_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS18.5_VISIBLE_STATE_LIGHT.png",
                "SwiftUI_iOS26_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS26_VISIBLE_STATE_LIGHT.png",
                "SwiftUI_iOS18.5_SECOND_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS18.5_SECOND_VISIBLE_STATE_LIGHT.png",
                "SwiftUI_iOS26_SECOND_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS26_SECOND_VISIBLE_STATE_LIGHT.png",
            ])
        )
    }

    func test_assertedOriginFileNames_honorsUIKitHelperAppearanceSubset() {
        let source = """
        func test_visibleState() {
            assertUIKitSnapshots(view, named: "VISIBLE_STATE", appearances: [.light])
        }
        """

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: false),
            [
                "iOS18.5_VISIBLE_STATE_LIGHT.png",
                "iOS26_VISIBLE_STATE_LIGHT.png",
            ]
        )
    }

    func test_assertedOriginFileNames_usesOnlyTopLevelNamedArgument() {
        let source = """
        func test_visibleState() {
            assertSnapshots(makeImage(named: "NESTED_ARGUMENT_STATE"), named: "VISIBLE_STATE")
        }
        """

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: false),
            [
                "iOS18.5_VISIBLE_STATE_DARK.png",
                "iOS18.5_VISIBLE_STATE_LIGHT.png",
                "iOS26_VISIBLE_STATE_DARK.png",
                "iOS26_VISIBLE_STATE_LIGHT.png",
            ]
        )
    }

    func test_assertedOriginFileNames_failsClosedForEmptyOrDynamicAppearances() {
        let emptyAppearances = """
        func test_emptyAppearances() {
            assertUIKitSnapshots(view, named: "EMPTY_STATE", appearances: [])
        }
        """
        let dynamicAppearances = """
        func test_dynamicAppearances() {
            assertUIKitSnapshots(view, named: "DYNAMIC_STATE", appearances: appearances)
        }
        """

        XCTAssertTrue(assertedOriginFileNames(in: emptyAppearances, swiftUI: false).isEmpty)
        XCTAssertTrue(assertedOriginFileNames(in: dynamicAppearances, swiftUI: false).isEmpty)
    }

    func test_assertedOriginFileNames_usesOnlyTopLevelAppearancesArgument() {
        let nestedOnly = """
        func test_nestedOnly() {
            assertUIKitSnapshots(makeView(appearances: [.light]), named: "VISIBLE_STATE")
        }
        """
        let nestedAndTopLevel = """
        func test_nestedAndTopLevel() {
            assertUIKitSnapshots(
                makeView(appearances: [.light]),
                named: "DARK_STATE",
                appearances: [.dark]
            )
        }
        """

        XCTAssertEqual(
            assertedOriginFileNames(in: nestedOnly, swiftUI: false),
            [
                "iOS18.5_VISIBLE_STATE_DARK.png",
                "iOS18.5_VISIBLE_STATE_LIGHT.png",
                "iOS26_VISIBLE_STATE_DARK.png",
                "iOS26_VISIBLE_STATE_LIGHT.png",
            ]
        )
        XCTAssertEqual(
            assertedOriginFileNames(in: nestedAndTopLevel, swiftUI: false),
            [
                "iOS18.5_DARK_STATE_DARK.png",
                "iOS26_DARK_STATE_DARK.png",
            ]
        )
    }

    func test_assertedOriginFileNames_requiresExactCalleeAndNamedArgumentLabels() {
        let source = """
        func test_visibleState() {
            myassertSnapshots(sut, named: "WRONG_CALLEE_STATE")
            assertSnapshots(sut, unnamed: "WRONG_ARGUMENT_STATE")
            assertSnapshots(sut, named: "VISIBLE_STATE")
        }
        """

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: true),
            [
                "SwiftUI_iOS18.5_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS18.5_VISIBLE_STATE_LIGHT.png",
                "SwiftUI_iOS26_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS26_VISIBLE_STATE_LIGHT.png",
            ]
        )
    }

    func test_assertedOriginFileNames_preservesCalleeBoundaryAcrossWhitespace() {
        let source = """
        func test_visibleState() {
            flag = true
            assertSnapshots(sut, named: "VISIBLE_STATE")
        }
        """

        XCTAssertEqual(
            assertedOriginFileNames(in: source, swiftUI: true),
            [
                "SwiftUI_iOS18.5_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS18.5_VISIBLE_STATE_LIGHT.png",
                "SwiftUI_iOS26_VISIBLE_STATE_DARK.png",
                "SwiftUI_iOS26_VISIBLE_STATE_LIGHT.png",
            ]
        )
    }
}

private extension SnapshotOriginInventoryTests {
    struct Origin {
        let url: URL
        let fileName: String
        let swiftUI: Bool
        let state: String
        let physicalFileIdentifier: String

        var uiKitFileName: String {
            swiftUI ? String(fileName.dropFirst("SwiftUI_".count)) : fileName
        }

        var suite: String {
            url.deletingLastPathComponent().deletingLastPathComponent().lastPathComponent
        }

        var component: String {
            switch suite {
            case "LabelTests", "LabelSnapshotTests":
                return "Label"
            case "NavBarSnapshotTests", "NavigationBarSnapshotTests":
                return "NavigationBar"
            default:
                return suite.replacingOccurrences(of: "SnapshotTests", with: "")
            }
        }

        var pairKey: String {
            "\(component)|\(uiKitFileName)"
        }

        var scenarioKey: String {
            "\(component)|\(state)"
        }
    }

    var documentedUIKitOnlyScenarios: Set<String> {
        [
            // Concrete Button image-loading APIs are not part of ButtonOutput.
            "Button|BUTTON_IMAGE_ASSET",
            "Button|BUTTON_IMAGE_URL_STATE",
            "Button|BUTTON_IMAGE_URLSTRING_STATE",
            "Button|BUTTON_IMAGE_NOURL",
            "Button|BUTTON_IMAGE_NOURLSTRING",
            "Button|BUTTON_OUTPUT_NO_URL",

            // SwiftUI unit snapshots cannot hold a real Button gesture in its transient
            // pressed phase. The released view and public action contract are covered.
            "Button|BUTTON_STYLE_PRESSED_COLOR_STATE",
            "Button|BUTTON_STYLE_PRESSED_TINTCOLOR_STATE",

            // SwiftUI has no unit-level API for holding a real gesture in its transient
            // pressed phase. Released interaction and accessibility actions are covered.
            "ImageView|IMAGE_VIEW_ONPRESS",

            // These mutate UIKit view/layer internals and have no shared Output-model input.
            "ProgressBar|PROGRESSBAR_WITH_GRADIENT",
            "TextView|TEXTVIEW_MASKED_INPUT",
            "TextView|TEXTVIEW_MASK_COLOR",
            "WrapperView|WRAPPERVIEW_WITH_BORDER"
        ]
    }

    func loadReviewedUIKitManifest() throws -> Set<String> {
        let manifestURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("UIKitOriginManifest.txt")
        let source = try String(contentsOf: manifestURL, encoding: .utf8)
        let entries = source.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }

        for entry in entries {
            XCTAssertEqual(
                entry.split(separator: "|", omittingEmptySubsequences: false).count,
                3,
                "Invalid UIKit origin manifest entry: \(entry)"
            )
        }
        XCTAssertEqual(Set(entries).count, entries.count, "UIKit origin manifest entries must be unique")
        return Set(entries)
    }

    func manifestEntries(for origins: [Origin]) -> [String] {
        let grouped = Dictionary(grouping: origins) { origin in
            "\(origin.suite)|\(originState(origin.fileName) ?? "INVALID")"
        }

        return grouped.map { key, origins in
            let variants = origins.compactMap { originVariant($0.fileName) }.sorted()
            return "\(key)|\(variants.joined(separator: ","))"
        }
    }

    func originVariant(_ fileName: String) -> String? {
        var name = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        if name.hasPrefix("SwiftUI_") {
            name.removeFirst("SwiftUI_".count)
        }

        let os: String
        if name.hasPrefix("iOS18.5_") {
            os = "iOS18.5"
        } else if name.hasPrefix("iOS26_") {
            os = "iOS26"
        } else {
            return nil
        }

        if name.hasSuffix("_LIGHT") {
            return "\(os)_LIGHT"
        }
        if name.hasSuffix("_DARK") {
            return "\(os)_DARK"
        }
        return nil
    }

    func origins(below root: URL, swiftUI: Bool) throws -> [Origin] {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            XCTFail("Could not enumerate snapshot origins below \(root.path)")
            return []
        }

        return try enumerator.compactMap { value -> Origin? in
            guard let url = value as? URL,
                  url.pathExtension == "png",
                  url.deletingLastPathComponent().lastPathComponent == "snapshots" else {
                return nil
            }
            let resourceValues = try url.resourceValues(forKeys: [
                .isRegularFileKey,
                .isSymbolicLinkKey,
            ])
            guard resourceValues.isRegularFile == true,
                  resourceValues.isSymbolicLink != true else {
                throw OriginInventoryError.nonIndependentFile(url.path)
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let systemNumber = attributes[.systemNumber] as? NSNumber,
                  let fileNumber = attributes[.systemFileNumber] as? NSNumber else {
                throw OriginInventoryError.missingFileIdentifier(url.path)
            }
            let fileName = url.lastPathComponent
            guard swiftUI == fileName.hasPrefix("SwiftUI_") else {
                throw OriginInventoryError.invalidPlatformPrefix(url.path)
            }
            guard let state = originState(fileName) else {
                throw OriginInventoryError.invalidCanonicalName(url.path)
            }
            return Origin(
                url: url,
                fileName: fileName,
                swiftUI: swiftUI,
                state: state,
                physicalFileIdentifier: "\(systemNumber):\(fileNumber)"
            )
        }
    }

    func assertOriginsAreReferencedByPositiveTests(_ origins: [Origin]) throws {
        let originsBySuite = Dictionary(grouping: origins) {
            $0.url.deletingLastPathComponent().deletingLastPathComponent()
        }

        for (suiteDirectory, suiteOrigins) in originsBySuite {
            let assertedOriginNames = try FileManager.default.contentsOfDirectory(
                at: suiteDirectory,
                includingPropertiesForKeys: nil
            )
            .filter { $0.pathExtension == "swift" }
            .map { try String(contentsOf: $0, encoding: .utf8) }
            .reduce(into: Set<String>()) { result, source in
                result.formUnion(assertedOriginFileNames(in: source, swiftUI: suiteOrigins[0].swiftUI))
            }

            for origin in suiteOrigins {
                XCTAssertTrue(
                    assertedOriginNames.contains(origin.fileName),
                    "Orphan snapshot origin is not referenced by a positive test: \(origin.url.path)"
                )
            }
        }
    }

    func assertedOriginFileNames(in source: String, swiftUI: Bool) -> Set<String> {
        let sourceWithoutComments = removingComments(from: source)
        return positiveSnapshotFunctions(in: sourceWithoutComments).reduce(into: Set<String>()) { names, function in
            let compactFunction = compactingSnapshotSource(function)
            let variables = snapshotNameVariables(in: function)
            let expandedFunction = variables.reduce(compactFunction) { result, entry in
                result
                    .replacingOccurrences(of: "\\(\(entry.key))", with: entry.value)
                    .replacingOccurrences(
                        of: "named:\(entry.key)",
                        with: "named:\"\(entry.value)\""
                    )
            }

            for invocation in snapshotAssertionInvocations(in: expandedFunction) {
                guard let value = topLevelNamedStringLiteral(in: invocation.source) else {
                    continue
                }
                if originState(value + ".png") != nil {
                    names.insert(value + ".png")
                } else if invocation.expandsCanonicalVariants {
                    names.formUnion(canonicalOriginFileNames(
                        for: value,
                        swiftUI: swiftUI,
                        appearances: invocation.appearances
                    ))
                }
            }
        }
    }

    func snapshotAssertionInvocations(
        in compactFunction: String
    ) -> [(source: String, expandsCanonicalVariants: Bool, appearances: Set<String>?)] {
        let markers: [(value: String, expandsCanonicalVariants: Bool, honorsAppearances: Bool)] = [
            ("assert(snapshot:", false, false),
            ("assertSnapshots(", true, false),
            ("assertSnapshotPair(", true, false),
            ("assertUIKitSnapshots(", true, true),
        ]

        return markers.flatMap { marker in
            var invocations: [(source: String, expandsCanonicalVariants: Bool, appearances: Set<String>?)] = []
            var searchStart = compactFunction.startIndex
            while let markerRange = nextCodeRange(
                of: marker.value,
                in: compactFunction,
                from: searchStart
            ) {
                guard let invocation = balancedInvocation(
                    in: compactFunction,
                    startingAt: markerRange.lowerBound
                ) else { break }
                let invocationSource = String(invocation)
                invocations.append((
                    invocationSource,
                    marker.expandsCanonicalVariants,
                    marker.honorsAppearances ? explicitAppearances(in: invocationSource) : nil
                ))
                searchStart = invocation.endIndex
            }
            return invocations
        }
    }

    func nextCodeRange(
        of marker: String,
        in source: String,
        from start: String.Index
    ) -> Range<String.Index>? {
        var index = start
        var stringDelimiterLength = 0
        var isEscaped = false

        while index < source.endIndex {
            if stringDelimiterLength == 0 {
                if source[index...].hasPrefix("\"\"\"") {
                    stringDelimiterLength = 3
                    index = source.index(index, offsetBy: 3)
                    continue
                }
                if source[index] == "\"" {
                    stringDelimiterLength = 1
                    index = source.index(after: index)
                    continue
                }
                if source[index...].hasPrefix(marker),
                   isCalleeBoundary(before: index, in: source) {
                    return index..<source.index(index, offsetBy: marker.count)
                }
            } else if stringDelimiterLength == 3 {
                if source[index...].hasPrefix("\"\"\"") {
                    stringDelimiterLength = 0
                    index = source.index(index, offsetBy: 3)
                    continue
                }
            } else if isEscaped {
                isEscaped = false
            } else if source[index] == "\\" {
                isEscaped = true
            } else if source[index] == "\"" {
                stringDelimiterLength = 0
            }
            index = source.index(after: index)
        }
        return nil
    }

    func isCalleeBoundary(before index: String.Index, in source: String) -> Bool {
        guard index > source.startIndex else { return true }
        let previous = source[source.index(before: index)]
        return previous != "_" && !previous.isLetter && !previous.isNumber
    }

    func balancedInvocation(
        in source: String,
        startingAt invocationStart: String.Index
    ) -> Substring? {
        guard let openingParenthesis = source[invocationStart...].firstIndex(of: "(") else {
            return nil
        }

        var depth = 0
        var stringDelimiterLength = 0
        var isEscaped = false
        var index = openingParenthesis
        while index < source.endIndex {
            let character = source[index]
            if stringDelimiterLength == 3 {
                if source[index...].hasPrefix("\"\"\"") {
                    stringDelimiterLength = 0
                    index = source.index(index, offsetBy: 3)
                    continue
                }
            } else if stringDelimiterLength == 1 {
                if isEscaped {
                    isEscaped = false
                } else if character == "\\" {
                    isEscaped = true
                } else if character == "\"" {
                    stringDelimiterLength = 0
                }
            } else if source[index...].hasPrefix("\"\"\"") {
                stringDelimiterLength = 3
                index = source.index(index, offsetBy: 3)
                continue
            } else if character == "\"" {
                stringDelimiterLength = 1
            } else if character == "(" {
                depth += 1
            } else if character == ")" {
                depth -= 1
                if depth == 0 {
                    let end = source.index(after: index)
                    return source[invocationStart..<end]
                }
            }
            index = source.index(after: index)
        }
        return nil
    }

    func canonicalOriginFileNames(
        for state: String,
        swiftUI: Bool,
        appearances: Set<String>? = nil
    ) -> Set<String> {
        let prefix = swiftUI ? "SwiftUI_" : ""
        let appearances = appearances ?? Set(["LIGHT", "DARK"])
        return Set(["iOS18.5", "iOS26"].flatMap { os in
            appearances.map { "\(prefix)\(os)_\(state)_\($0).png" }
        })
    }

    func explicitAppearances(in invocation: String) -> Set<String>? {
        guard let valueStart = topLevelArgumentValueStart(
            for: "appearances",
            in: invocation
        ) else {
            return nil
        }
        let remainder = invocation[valueStart...]
        if remainder.hasPrefix("SnapshotAppearance.allCases") || remainder.hasPrefix(".allCases") {
            return ["LIGHT", "DARK"]
        }
        guard remainder.hasPrefix("["),
              let end = remainder.firstIndex(of: "]") else {
            return []
        }
        let value = remainder[remainder.index(after: remainder.startIndex)..<end]
        var appearances: Set<String> = []
        if value.contains(".light") { appearances.insert("LIGHT") }
        if value.contains(".dark") { appearances.insert("DARK") }
        return appearances
    }

    func topLevelNamedStringLiteral(in invocation: String) -> String? {
        guard let openingParenthesis = invocation.firstIndex(of: "(") else { return nil }
        var index = invocation.index(after: openingParenthesis)
        var parenthesisDepth = 1
        var bracketDepth = 0
        var braceDepth = 0
        var stringDelimiterLength = 0
        var isEscaped = false

        while index < invocation.endIndex {
            let character = invocation[index]
            if stringDelimiterLength == 3 {
                if invocation[index...].hasPrefix("\"\"\"") {
                    stringDelimiterLength = 0
                    index = invocation.index(index, offsetBy: 3)
                    continue
                }
            } else if stringDelimiterLength == 1 {
                if isEscaped {
                    isEscaped = false
                } else if character == "\\" {
                    isEscaped = true
                } else if character == "\"" {
                    stringDelimiterLength = 0
                }
            } else if invocation[index...].hasPrefix("\"\"\"") {
                stringDelimiterLength = 3
                index = invocation.index(index, offsetBy: 3)
                continue
            } else if character == "\"" {
                stringDelimiterLength = 1
            } else if character == "(" {
                parenthesisDepth += 1
            } else if character == ")" {
                parenthesisDepth -= 1
            } else if character == "[" {
                bracketDepth += 1
            } else if character == "]" {
                bracketDepth -= 1
            } else if character == "{" {
                braceDepth += 1
            } else if character == "}" {
                braceDepth -= 1
            } else if parenthesisDepth == 1,
                      bracketDepth == 0,
                      braceDepth == 0,
                      isArgumentLabelBoundary(before: index, in: invocation),
                      invocation[index...].hasPrefix("named:\"") {
                let valueStart = invocation.index(index, offsetBy: "named:\"".count)
                var valueEnd = valueStart
                var valueIsEscaped = false
                while valueEnd < invocation.endIndex {
                    let valueCharacter = invocation[valueEnd]
                    if valueIsEscaped {
                        valueIsEscaped = false
                    } else if valueCharacter == "\\" {
                        valueIsEscaped = true
                    } else if valueCharacter == "\"" {
                        return String(invocation[valueStart..<valueEnd])
                    }
                    valueEnd = invocation.index(after: valueEnd)
                }
                return nil
            }
            index = invocation.index(after: index)
        }
        return nil
    }

    func topLevelArgumentValueStart(
        for label: String,
        in invocation: String
    ) -> String.Index? {
        guard let openingParenthesis = invocation.firstIndex(of: "(") else { return nil }
        let marker = "\(label):"
        var index = invocation.index(after: openingParenthesis)
        var parenthesisDepth = 1
        var bracketDepth = 0
        var braceDepth = 0
        var stringDelimiterLength = 0
        var isEscaped = false

        while index < invocation.endIndex {
            let character = invocation[index]
            if stringDelimiterLength == 3 {
                if invocation[index...].hasPrefix("\"\"\"") {
                    stringDelimiterLength = 0
                    index = invocation.index(index, offsetBy: 3)
                    continue
                }
            } else if stringDelimiterLength == 1 {
                if isEscaped {
                    isEscaped = false
                } else if character == "\\" {
                    isEscaped = true
                } else if character == "\"" {
                    stringDelimiterLength = 0
                }
            } else if invocation[index...].hasPrefix("\"\"\"") {
                stringDelimiterLength = 3
                index = invocation.index(index, offsetBy: 3)
                continue
            } else if character == "\"" {
                stringDelimiterLength = 1
            } else if character == "(" {
                parenthesisDepth += 1
            } else if character == ")" {
                parenthesisDepth -= 1
            } else if character == "[" {
                bracketDepth += 1
            } else if character == "]" {
                bracketDepth -= 1
            } else if character == "{" {
                braceDepth += 1
            } else if character == "}" {
                braceDepth -= 1
            } else if parenthesisDepth == 1,
                      bracketDepth == 0,
                      braceDepth == 0,
                      isArgumentLabelBoundary(before: index, in: invocation),
                      invocation[index...].hasPrefix(marker) {
                return invocation.index(index, offsetBy: marker.count)
            }
            index = invocation.index(after: index)
        }
        return nil
    }

    func isArgumentLabelBoundary(before index: String.Index, in invocation: String) -> Bool {
        guard index > invocation.startIndex else { return false }
        let previous = invocation[invocation.index(before: index)]
        return previous == "(" || previous == ","
    }

    func removingComments(from source: String) -> String {
        var result = ""
        var index = source.startIndex
        var stringDelimiterLength = 0
        var isEscaped = false
        var blockCommentDepth = 0
        var isLineComment = false

        while index < source.endIndex {
            let character = source[index]
            let next = source.index(after: index)

            if isLineComment {
                if character == "\n" {
                    isLineComment = false
                    result.append(character)
                } else {
                    result.append(" ")
                }
                index = next
                continue
            }

            if blockCommentDepth > 0 {
                if source[index...].hasPrefix("/*") {
                    blockCommentDepth += 1
                    result.append(contentsOf: "  ")
                    index = source.index(index, offsetBy: 2)
                } else if source[index...].hasPrefix("*/") {
                    blockCommentDepth -= 1
                    result.append(contentsOf: "  ")
                    index = source.index(index, offsetBy: 2)
                } else {
                    result.append(character == "\n" ? "\n" : " ")
                    index = next
                }
                continue
            }

            if stringDelimiterLength == 3 {
                if source[index...].hasPrefix("\"\"\"") {
                    stringDelimiterLength = 0
                    result.append(contentsOf: "\"\"\"")
                    index = source.index(index, offsetBy: 3)
                } else {
                    result.append(character)
                    index = next
                }
                continue
            }

            if stringDelimiterLength == 1 {
                result.append(character)
                if isEscaped {
                    isEscaped = false
                } else if character == "\\" {
                    isEscaped = true
                } else if character == "\"" {
                    stringDelimiterLength = 0
                }
                index = next
                continue
            }

            if source[index...].hasPrefix("//") {
                isLineComment = true
                result.append(contentsOf: "  ")
                index = source.index(index, offsetBy: 2)
            } else if source[index...].hasPrefix("/*") {
                blockCommentDepth = 1
                result.append(contentsOf: "  ")
                index = source.index(index, offsetBy: 2)
            } else if source[index...].hasPrefix("\"\"\"") {
                stringDelimiterLength = 3
                result.append(contentsOf: "\"\"\"")
                index = source.index(index, offsetBy: 3)
            } else {
                result.append(character)
                if character == "\"" { stringDelimiterLength = 1 }
                index = next
            }
        }
        return result
    }

    func snapshotNameVariables(in function: String) -> [String: String] {
        var variables: [String: String] = [:]
        for line in function.components(separatedBy: .newlines) {
            let declaration = line.trimmingCharacters(in: .whitespaces)
            guard declaration.hasPrefix("let "),
                  let assignment = declaration.firstIndex(of: "=") else { continue }

            let variable = declaration[declaration.index(declaration.startIndex, offsetBy: 4)..<assignment]
                .trimmingCharacters(in: .whitespaces)
            let value = declaration[declaration.index(after: assignment)...]
                .trimmingCharacters(in: .whitespaces)
            guard variable.hasSuffix("Name"),
                  value.hasPrefix("\""),
                  let closingQuote = value.dropFirst().firstIndex(of: "\"") else { continue }

            variables[variable] = String(value[value.index(after: value.startIndex)..<closingQuote])
        }
        return variables
    }

    func positiveTestSource(_ source: String) -> String {
        positiveSnapshotFunctions(in: source)
            .flatMap(assertedSnapshotStates)
            .map { "\"\($0)\"" }
            .joined(separator: "\n")
    }

    func positiveSnapshotFunctions(in source: String) -> [String] {
        var positiveFunctions: [String] = []
        var currentFunction: [String] = []
        var braceDepth = 0
        var isCollectingPositiveTest = false
        var braceScannerState = BraceScannerState()

        for line in source.components(separatedBy: .newlines) {
            let declaration = line.trimmingCharacters(in: .whitespaces)
            if braceDepth == 0, declaration.hasPrefix("func test") {
                let functionName = declaration
                    .dropFirst("func ".count)
                    .prefix { $0 != "(" }
                isCollectingPositiveTest = !functionName.hasPrefix("test_fail")
                    && !functionName.hasPrefix("tests_fail")
                currentFunction = isCollectingPositiveTest ? [line] : []
                braceScannerState = BraceScannerState()
                braceDepth = braceDelta(in: line, state: &braceScannerState)
                if braceDepth == 0, isCollectingPositiveTest {
                    appendIfPositiveSnapshotTest(currentFunction, to: &positiveFunctions)
                    currentFunction = []
                    isCollectingPositiveTest = false
                }
                continue
            }

            guard braceDepth > 0 else { continue }
            if isCollectingPositiveTest {
                currentFunction.append(line)
            }
            braceDepth += braceDelta(in: line, state: &braceScannerState)
            if braceDepth == 0 {
                if isCollectingPositiveTest {
                    appendIfPositiveSnapshotTest(currentFunction, to: &positiveFunctions)
                }
                currentFunction = []
                isCollectingPositiveTest = false
            }
        }

        return positiveFunctions
    }

    func appendIfPositiveSnapshotTest(_ lines: [String], to functions: inout [String]) {
        let function = lines.joined(separator: "\n")
        let compactFunction = compactingSnapshotSource(function)
        let negativeMarkers = [
            "assertFail",
            "assertSnapshotsFail(",
            "expectingMatch:false",
            "mustMatch:false"
        ]
        let positiveMarkers = [
            "assert(snapshot:",
            "assertSnapshots(",
            "assertSnapshotPair(",
            "assertUIKitSnapshots("
        ]
        guard !negativeMarkers.contains(where: { compactFunction.contains($0) }),
              positiveMarkers.contains(where: { compactFunction.contains($0) }) else {
            return
        }
        functions.append(function)
    }

    func assertedSnapshotStates(in function: String) -> [String] {
        let compactFunction = compactingSnapshotSource(function)
        var states: [String] = []

        for line in function.components(separatedBy: .newlines) {
            let declaration = line.trimmingCharacters(in: .whitespaces)
            guard declaration.hasPrefix("let "),
                  let assignment = declaration.firstIndex(of: "=") else { continue }

            let variable = declaration[declaration.index(declaration.startIndex, offsetBy: 4)..<assignment]
                .trimmingCharacters(in: .whitespaces)
            let value = declaration[declaration.index(after: assignment)...]
                .trimmingCharacters(in: .whitespaces)
            guard variable.hasSuffix("Name"),
                  value.hasPrefix("\""),
                  let closingQuote = value.dropFirst().firstIndex(of: "\"") else { continue }

            let state = String(value[value.index(after: value.startIndex)..<closingQuote])
            let isPassedDirectly = compactFunction.contains("named:\(variable)")
            let isInterpolated = compactFunction.contains("\\(\(variable))")
            if isPassedDirectly || isInterpolated {
                states.append(state)
            }
        }

        var searchStart = compactFunction.startIndex
        while let namedRange = compactFunction.range(
            of: "named:\"",
            range: searchStart..<compactFunction.endIndex
        ) {
            let valueStart = namedRange.upperBound
            guard let valueEnd = compactFunction[valueStart...].firstIndex(of: "\"") else { break }
            let literal = String(compactFunction[valueStart..<valueEnd])
            if !literal.contains("\\(") {
                states.append(literal)
            }
            searchStart = compactFunction.index(after: valueEnd)
        }

        return Array(Set(states)).sorted()
    }

    func compactingSnapshotSource(_ source: String) -> String {
        var result = ""
        var index = source.startIndex

        while index < source.endIndex {
            let character = source[index]
            guard character.isWhitespace else {
                result.append(character)
                index = source.index(after: index)
                continue
            }

            var nextNonWhitespace = source.index(after: index)
            while nextNonWhitespace < source.endIndex,
                  source[nextNonWhitespace].isWhitespace {
                nextNonWhitespace = source.index(after: nextNonWhitespace)
            }
            if let previous = result.last,
               nextNonWhitespace < source.endIndex,
               isIdentifierCharacter(previous),
               isIdentifierCharacter(source[nextNonWhitespace]) {
                result.append(" ")
            }
            index = nextNonWhitespace
        }

        return result
    }

    func isIdentifierCharacter(_ character: Character) -> Bool {
        character == "_" || character.isLetter || character.isNumber
    }

    struct BraceScannerState {
        var stringDelimiterLength = 0
        var isEscaped = false
    }

    func braceDelta(in line: String, state: inout BraceScannerState) -> Int {
        var depth = 0
        var index = line.startIndex

        while index < line.endIndex {
            let character = line[index]
            if state.stringDelimiterLength == 3 {
                if line[index...].hasPrefix("\"\"\"") {
                    state.stringDelimiterLength = 0
                    index = line.index(index, offsetBy: 3)
                    continue
                }
            } else if state.stringDelimiterLength == 1 {
                if state.isEscaped {
                    state.isEscaped = false
                } else if character == "\\" {
                    state.isEscaped = true
                } else if character == "\"" {
                    state.stringDelimiterLength = 0
                }
            } else if line[index...].hasPrefix("\"\"\"") {
                state.stringDelimiterLength = 3
                index = line.index(index, offsetBy: 3)
                continue
            } else if character == "\"" {
                state.stringDelimiterLength = 1
            } else if character == "{" {
                depth += 1
            } else if character == "}" {
                depth -= 1
            }
            index = line.index(after: index)
        }
        return depth
    }

    func originState(_ fileName: String) -> String? {
        var name = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        if name.hasPrefix("SwiftUI_") {
            name.removeFirst("SwiftUI_".count)
        }

        if name.hasPrefix("iOS18.5_") {
            name.removeFirst("iOS18.5_".count)
        } else if name.hasPrefix("iOS26_") {
            name.removeFirst("iOS26_".count)
        } else {
            return nil
        }

        if name.hasSuffix("_LIGHT") {
            name.removeLast("_LIGHT".count)
        } else if name.hasSuffix("_DARK") {
            name.removeLast("_DARK".count)
        } else {
            return nil
        }
        return name
    }
}

private enum OriginInventoryError: Error {
    case invalidPlatformPrefix(String)
    case invalidCanonicalName(String)
    case missingFileIdentifier(String)
    case nonIndependentFile(String)
}
#endif
