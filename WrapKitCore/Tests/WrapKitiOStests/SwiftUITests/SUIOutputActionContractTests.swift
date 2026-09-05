#if canImport(SwiftUI)
@testable import WrapKit
import XCTest

final class SUIOutputActionContractTests: XCTestCase {
    func test_buttonFullModel_replaysReplacesAndClearsOnPress() {
        let adapter = ButtonOutputSwiftUIAdapter()
        var events: [String] = []

        adapter.display(model: .init(onPress: { events.append("initial") }))
        let sut = SUIButtonStateModel(adapter: adapter)

        XCTAssertNotNil(sut.presentable.onPress)
        sut.presentable.onPress?()

        adapter.display(model: .init(onPress: { events.append("replacement") }))

        XCTAssertNotNil(sut.presentable.onPress)
        sut.presentable.onPress?()

        adapter.display(model: nil)

        XCTAssertTrue(sut.isHidden)
        XCTAssertNil(sut.presentable.onPress)
        XCTAssertEqual(events, ["initial", "replacement"])
    }

    func test_buttonIncrementalOnPress_replaysReplacesAndClearsAction() {
        let adapter = ButtonOutputSwiftUIAdapter()
        let sut = SUIButtonStateModel(adapter: adapter)
        var events: [String] = []

        adapter.display(onPress: { events.append("initial") })

        XCTAssertNotNil(sut.presentable.onPress)
        sut.presentable.onPress?()

        adapter.display(onPress: { events.append("replacement") })

        XCTAssertNotNil(sut.presentable.onPress)
        sut.presentable.onPress?()

        adapter.display(onPress: nil)

        XCTAssertNil(sut.presentable.onPress)
        XCTAssertEqual(events, ["initial", "replacement"])
    }

    func test_headerFullModel_replaysAllNestedActionsThroughStateAndChildAdapters() throws {
        let adapter = HeaderOutputSwiftUIAdapter()
        var events: [String] = []
        adapter.display(model: .init(
            centerView: .titledImage(.init(
                .init(
                    onPress: { events.append("center.press") },
                    onLongPress: { events.append("center.longPress") }
                ),
                nil
            )),
            leadingCard: .init(
                onPress: { events.append("leading.press") },
                onLongPress: { events.append("leading.longPress") }
            ),
            primeTrailingImage: .init(onPress: { events.append("prime") }),
            secondaryTrailingImage: .init(onPress: { events.append("secondary") }),
            tertiaryTrailingImage: .init(onPress: { events.append("tertiary") })
        ))

        let sut = SUINavigationBarStateModel(adapter: adapter)
        let leadingCardStateModel = SUICardViewStateModel(adapter: sut.leadingCardAdapter)

        XCTAssertNotNil(leadingCardStateModel.onPress)
        XCTAssertNotNil(leadingCardStateModel.onLongPress)
        XCTAssertNotNil(sut.primeTrailingButtonStateModel.presentable.onPress)
        XCTAssertNotNil(sut.secondaryTrailingButtonStateModel.presentable.onPress)
        XCTAssertNotNil(sut.tertiaryTrailingButtonStateModel.presentable.onPress)

        leadingCardStateModel.onPress?()
        leadingCardStateModel.onLongPress?()
        let centerImage = try XCTUnwrap(titledImage(from: sut.model))
        centerImage.onPress?()
        centerImage.onLongPress?()
        sut.primeTrailingButtonStateModel.presentable.onPress?()
        sut.secondaryTrailingButtonStateModel.presentable.onPress?()
        sut.tertiaryTrailingButtonStateModel.presentable.onPress?()

        XCTAssertEqual(events, [
            "leading.press",
            "leading.longPress",
            "center.press",
            "center.longPress",
            "prime",
            "secondary",
            "tertiary"
        ])
    }

    func test_headerDisplayNil_hidesAndRetainsConfiguredActionsLikeUIKit() throws {
        let adapter = HeaderOutputSwiftUIAdapter()
        var events: [String] = []
        adapter.display(model: .init(
            centerView: .titledImage(.init(
                .init(onPress: { events.append("center") }),
                nil
            )),
            leadingCard: .init(onPress: { events.append("leading") }),
            primeTrailingImage: .init(onPress: { events.append("prime") })
        ))
        let sut = SUINavigationBarStateModel(adapter: adapter)
        let leadingCardStateModel = SUICardViewStateModel(adapter: sut.leadingCardAdapter)

        adapter.display(model: nil)

        XCTAssertTrue(sut.isHidden)
        XCTAssertNotNil(leadingCardStateModel.onPress)
        XCTAssertNotNil(sut.primeTrailingButtonStateModel.presentable.onPress)
        XCTAssertNotNil(try XCTUnwrap(titledImage(from: sut.model)).onPress)

        leadingCardStateModel.onPress?()
        try XCTUnwrap(titledImage(from: sut.model)).onPress?()
        sut.primeTrailingButtonStateModel.presentable.onPress?()

        XCTAssertEqual(events, ["leading", "center", "prime"])
    }

    func test_headerIncrementalActions_replaceAndClearAtUIKitBoundaries() throws {
        let adapter = HeaderOutputSwiftUIAdapter()
        let sut = SUINavigationBarStateModel(adapter: adapter)
        let leadingCardStateModel = SUICardViewStateModel(adapter: sut.leadingCardAdapter)
        var events: [String] = []

        adapter.display(leadingCard: .init(
            onPress: { events.append("leading.initial") },
            onLongPress: { events.append("leadingLong.initial") }
        ))
        adapter.display(centerView: .titledImage(.init(
            .init(
                onPress: { events.append("center.initial") },
                onLongPress: { events.append("centerLong.initial") }
            ),
            nil
        )))
        adapter.display(primeTrailingImage: .init(onPress: { events.append("prime.initial") }))
        adapter.display(secondaryTrailingImage: .init(onPress: { events.append("secondary.initial") }))
        adapter.display(tertiaryTrailingImage: .init(onPress: { events.append("tertiary.initial") }))

        invokeHeaderActions(
            sut: sut,
            leadingCardStateModel: leadingCardStateModel
        )

        adapter.display(leadingCard: .init(
            onPress: { events.append("leading.replacement") },
            onLongPress: { events.append("leadingLong.replacement") }
        ))
        adapter.display(centerView: .titledImage(.init(
            .init(
                onPress: { events.append("center.replacement") },
                onLongPress: { events.append("centerLong.replacement") }
            ),
            nil
        )))
        adapter.display(primeTrailingImage: .init(onPress: { events.append("prime.replacement") }))
        adapter.display(secondaryTrailingImage: .init(onPress: { events.append("secondary.replacement") }))
        adapter.display(tertiaryTrailingImage: .init(onPress: { events.append("tertiary.replacement") }))

        invokeHeaderActions(
            sut: sut,
            leadingCardStateModel: leadingCardStateModel
        )

        XCTAssertEqual(events, [
            "leading.initial",
            "leadingLong.initial",
            "center.initial",
            "centerLong.initial",
            "prime.initial",
            "secondary.initial",
            "tertiary.initial",
            "leading.replacement",
            "leadingLong.replacement",
            "center.replacement",
            "centerLong.replacement",
            "prime.replacement",
            "secondary.replacement",
            "tertiary.replacement"
        ])

        adapter.display(leadingCard: nil)
        adapter.display(centerView: nil)
        adapter.display(primeTrailingImage: nil)
        adapter.display(secondaryTrailingImage: nil)
        adapter.display(tertiaryTrailingImage: nil)

        XCTAssertNil(sut.model.leadingCard)
        XCTAssertNil(sut.model.centerView)
        XCTAssertNil(sut.model.primeTrailingImage)
        XCTAssertNil(sut.model.secondaryTrailingImage)
        XCTAssertNil(sut.model.tertiaryTrailingImage)
        XCTAssertTrue(leadingCardStateModel.isHidden)
        // UIKit CardView keeps its callbacks while hidden after display(model: nil).
        XCTAssertNotNil(leadingCardStateModel.onPress)
        XCTAssertNotNil(leadingCardStateModel.onLongPress)
        XCTAssertTrue(sut.primeTrailingButtonStateModel.isHidden)
        XCTAssertTrue(sut.secondaryTrailingButtonStateModel.isHidden)
        XCTAssertTrue(sut.tertiaryTrailingButtonStateModel.isHidden)
        XCTAssertNil(sut.primeTrailingButtonStateModel.presentable.onPress)
        XCTAssertNil(sut.secondaryTrailingButtonStateModel.presentable.onPress)
        XCTAssertNil(sut.tertiaryTrailingButtonStateModel.presentable.onPress)
    }
}

private extension SUIOutputActionContractTests {
    func titledImage(from model: HeaderPresentableModel) -> ImageViewPresentableModel? {
        guard let centerView = model.centerView,
              case .titledImage(let pair) = centerView else {
            return nil
        }
        return pair.first
    }

    func invokeHeaderActions(
        sut: SUINavigationBarStateModel,
        leadingCardStateModel: SUICardViewStateModel
    ) {
        leadingCardStateModel.onPress?()
        leadingCardStateModel.onLongPress?()
        let centerImage = titledImage(from: sut.model)
        centerImage?.onPress?()
        centerImage?.onLongPress?()
        sut.primeTrailingButtonStateModel.presentable.onPress?()
        sut.secondaryTrailingButtonStateModel.presentable.onPress?()
        sut.tertiaryTrailingButtonStateModel.presentable.onPress?()
    }
}
#endif
