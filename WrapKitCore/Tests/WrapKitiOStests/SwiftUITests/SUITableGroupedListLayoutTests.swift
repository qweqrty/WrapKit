#if os(iOS) && canImport(SwiftUI)
import SwiftUI
import UIKit
import XCTest
@testable import WrapKit

@available(iOS 17.0, *)
@MainActor
final class SUITableGroupedListLayoutTests: XCTestCase {
    func test_groupedList_sectionHeaderScrollsOutWithoutCoveringRows() throws {
        try assertHeaderScrolling(style: .groupedList, shouldPin: false)
    }

    func test_plainList_keepsNativePinnedSectionHeader() throws {
        try assertHeaderScrolling(style: .list, shouldPin: true)
    }

    private func assertHeaderScrolling(style: SUITableViewStyleType, shouldPin: Bool) throws {
        let adapter = TableOutputSwiftUIAdapter<Int, Void, String>()
        adapter.display(sections: [
            .init(header: "Router numbers", cells: (0..<20).map {
                .init(accessibilityIdentifier: "table.router.row.\($0)", cell: $0)
            })
        ])
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUITableView(
                adapter: adapter,
                style: style,
                cellContent: { number, _ in
                    SwiftUI.Text("Router \(number)")
                        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                },
                headerContent: { title in
                    SwiftUI.Text(title)
                        .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
                        .accessibilityIdentifier("table.router.header")
                },
                footerContent: { _ in SwiftUI.EmptyView() }
            ),
            size: CGSize(width: 390, height: 500)
        )
        for _ in 0..<3 { host.settle() }
        let scroll = try XCTUnwrap(host.firstSubview(of: UIScrollView.self))
        let headerBefore = try XCTUnwrap(host.element(withIdentifier: "table.router.header")).accessibilityFrame
        XCTAssertGreaterThan(headerBefore.height, 0)
        XCTAssertTrue(host.frame.intersects(headerBefore), "The header must start in the real visible host")
        let viewport = scroll.convert(scroll.bounds, to: nil).intersection(host.frame)
        let visibleTop = viewport.minY + scroll.adjustedContentInset.top
        let initialOffset = scroll.contentOffset
        let distance = max(headerBefore.maxY - visibleTop + 24, 100)
        try capture(scroll, name: shouldPin ? "plain_before_scroll" : "grouped_before_scroll")

        scroll.setContentOffset(CGPoint(x: initialOffset.x, y: initialOffset.y + distance), animated: false)
        for _ in 0..<3 { host.settle() }
        XCTAssertGreaterThan(scroll.contentOffset.y - initialOffset.y, distance - 1,
                             "The native List must really scroll, not merely update test data")
        let row = try XCTUnwrap(host.element(withIdentifier: "table.router.row.2"))
        XCTAssertGreaterThan(row.accessibilityFrame.intersection(viewport).height, 0,
                             "Rows from the same section must still be on screen")
        let headerAfter = host.element(withIdentifier: "table.router.header")?.accessibilityFrame
        let geometry = XCTAttachment(string:
            "before=\(headerBefore), after=\(String(describing: headerAfter)), viewport=\(viewport), "
            + "visibleTop=\(visibleTop), offsetBefore=\(initialOffset), offsetAfter=\(scroll.contentOffset)"
        )
        geometry.name = shouldPin ? "plain_header_geometry" : "grouped_header_geometry"
        geometry.lifetime = .keepAlways
        add(geometry)
        try capture(scroll, name: shouldPin ? "plain_after_scroll" : "grouped_after_scroll")

        if shouldPin {
            let headerAfter = try XCTUnwrap(headerAfter, "Existing .list keeps native pinned headers")
            XCTAssertGreaterThan(headerAfter.maxY, visibleTop)
            XCTAssertLessThanOrEqual(headerAfter.minY, visibleTop + 1)
        } else if let headerAfter {
            XCTAssertLessThanOrEqual(headerAfter.maxY, visibleTop + 1,
                                     "A grouped header must leave with its content, not cover router rows")
        }
    }

    private func capture(_ view: UIView, name: String) throws {
        let window = try XCTUnwrap(view.window)
        let image = UIGraphicsImageRenderer(size: window.bounds.size).image { context in
            UIColor.systemGroupedBackground.setFill()
            context.fill(window.bounds)
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
#endif
