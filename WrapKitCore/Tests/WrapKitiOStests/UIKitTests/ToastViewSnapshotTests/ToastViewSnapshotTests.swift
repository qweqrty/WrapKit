//
//  ToastViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 11/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

#if canImport(SwiftUI)
import enum SwiftUI.ColorScheme
#endif

final class ToastViewSnapshotTests: XCTestCase {

    private let image = UIImage(systemName: "star.fill")
    private let failImage = UIImage(systemName: "star")
    private weak var currentPairedSUT: PairedToastViewSnapshotSUT?

    private var swiftUISnapshotPrecision: Float {
        0.98
    }

    private var swiftUIFailSnapshotPrecision: Float {
        1
    }

    private var testContainer: UIWindow!
    
    override func setUp() {
        super.setUp()
        testContainer = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        testContainer.makeKeyAndVisible()
        testContainer.backgroundColor = .white
    }
    
    override func tearDown() {
        currentPairedSUT = nil
        super.tearDown()
    }

    func test_ToastView_default_state() {
        let snapshotName = "TOASTVIEW_DEFAULT_STATE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Toast Message")
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_default_state() {
        let snapshotName = "TOASTVIEW_DEFAULT_STATE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Toast Message.")
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_leadingImage() {
        let snapshotName = "TOASTVIEW_WITH_LEADINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Toast Message"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
                borderColor: .red,
        ))
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top)
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_leadingImage() {
        let snapshotName = "TOASTVIEW_WITH_LEADINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        let image = Image(systemName: "star")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Toast Message"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
                borderColor: .red,
            )
        ))
        
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Toast Message"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
                borderColor: .red,
        ))
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top)
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_long_text() {
        let snapshotName = "TOASTVIEW_WITH_LONGTEXT"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("This is a very long toast message that should wrap to multiple lines")
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))

        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_long_text() {
        let snapshotName = "TOASTVIEW_WITH_LONGTEXT"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("This is a very long toast message that should wrap to multiple lines.")
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))

        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_subTitle() {
        let snapshotName = "TOASTVIEW_WITH_SUBTITLE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            subTitle: .text("Subtitle")
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top)
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_subTitle() {
        let snapshotName = "TOASTVIEW_WITH_SUBTITLE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            subTitle: .text("Subtitle.")
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top)
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_valueTitle() {
        let snapshotName = "TOASTVIEW_WITH_VALUETITLE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            valueTitle: .text("Value title")
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top)))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
       
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_valueTitle() {
        let snapshotName = "TOASTVIEW_WITH_VALUETITLE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            valueTitle: .text("Value title.")
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top)))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
       
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_trailingImage() {
        let snapshotName = "TOASTVIEW_WITH_TRAILINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            trailingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
            )
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_trailingImage() {
        let snapshotName = "TOASTVIEW_WITH_TRAILINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            trailingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(failImage),
            )
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_switchControl() {
        let snapshotName = "TOASTVIEW_WITH_SWITCHCONTROL"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            switchControl: .init(
                isOn: true,
                isEnabled: true,
                style: .init(tintColor: .red,
                             thumbTintColor: .systemBlue,
                             backgroundColor: .systemBackground,
                             cornerRadius: 10))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_switchControl() {
        let snapshotName = "TOASTVIEW_WITH_SWITCHCONTROL"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            switchControl: .init(
                isOn: true,
                isEnabled: true,
                style: .init(tintColor: .systemRed,
                             thumbTintColor: .systemBlue,
                             backgroundColor: .systemBackground,
                             cornerRadius: 10))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_bottomSeparator() {
        let snapshotName = "TOASTVIEW_WITH_BOTTOMSEPARATOR"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            bottomSeparator: .init(color: .black, height: 2.0)
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_bottomSeparator() {
        let snapshotName = "TOASTVIEW_WITH_BOTTOMSEPARATOR"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            bottomSeparator: .init(color: .black, height: 1.0)
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_leadingTitles() {
        let snapshotName = "TOASTVIEW_WITH_lEADINGTITLES"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            leadingTitles: .init(.text("First title"), .text("Second title"))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_leadingTitles() {
        let snapshotName = "TOASTVIEW_WITH_lEADINGTITLES"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            leadingTitles: .init(.text("First title."), .text("Second title"))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_trailingTitles() {
        let snapshotName = "TOASTVIEW_WITH_TRAILINGTITLES"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            trailingTitles: .init(.text("First title."), .text("Second title"))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_trailingTitles() {
        let snapshotName = "TOASTVIEW_WITH_TRAILINGTITLES"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            trailingTitles: .init(.text("First title"), .text("Second title"))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_secondaryLeadingImage() {
        let snapshotName = "TOASTVIEW_WITH_SECONDARYLEADINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            secondaryLeadingImage: .init(image: .asset(image))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_secondaryLeadingImage() {
        let snapshotName = "TOASTVIEW_WITH_SECONDARYLEADINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        let image = Image(systemName: "star")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            secondaryLeadingImage: .init(image: .asset(failImage))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_secondaryTrailingImage() {
        let snapshotName = "TOASTVIEW_WITH_SECONDARYTRAILINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            secondaryTrailingImage: .init(image: .asset(image))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_fail_ToastView_with_secondaryTrailingImage() {
        let snapshotName = "TOASTVIEW_WITH_SECONDARYTRAILINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        let image = Image(systemName: "star")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeDefaultStyle(),
            title: .text("Title"),
            secondaryTrailingImage: .init(image: .asset(failImage))
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
    
    func test_ToastView_with_leadingImage_and_subtitle() {
        let snapshotName = "TOASTVIEW_WITH_LEADINGIMAGE_AND_SUBTITLE"
        
        // GIVEN
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion!")
        
        let image = Image(systemName: "star")
        
        // WHEN
        let cardModel = CardViewPresentableModel(
            style: makeCommonStyle(),
            title: .attributes([.init(text: "Title is very long, and should be wrap on two or maybe three lines in depends of font and other parameters", color: .red, font: .systemFont(ofSize: 13))]),
            leadingImage: .init(image: .asset(image)),
            subTitle: .attributes([.init(text: "Subtitle", color: .blue, font: .systemFont(ofSize: 13))])
        )
        
        let toast = CommonToast.custom(.init(
            common: .init(
                cardViewModel: cardModel,
                position: .top
            )
        ))
        
        sut.display(toast)
        sut.show(appWindow: testContainer) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: testContainer.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        
        sut.removeFromSuperview()
    }
}

extension ToastViewSnapshotTests {
    struct PixelBounds {
        let minX: Int
        let minY: Int
        let maxX: Int
        let maxY: Int

        func contains(x: Int, y: Int) -> Bool {
            x >= minX && x <= maxX && y >= minY && y <= maxY
        }
    }

    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 0.98,
        swiftUIPrecision: Float? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let uiKitName = resolvedUIKitSnapshotName(for: name, file: file)
        assert(snapshot: snapshot, named: uiKitName, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assertSwiftUISnapshot(
                snapshot: swiftUISnapshot,
                named: uiKitName,
                precision: swiftUIPrecision ?? swiftUISnapshotPrecision(for: name),
                file: file,
                line: line
            )
        }
    }

    func assertPairedSnapshotFail(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let uiKitName = resolvedUIKitSnapshotName(for: name, file: file)
        assertFail(snapshot: snapshot, named: uiKitName, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assertSwiftUISnapshotFail(
                snapshot: swiftUISnapshot,
                named: uiKitName,
                precision: swiftUIFailSnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func assertSwiftUISnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let reference = storedSnapshot(named: name, file: file, line: line) else { return }

        let normalizedReference = normalizedToastSnapshot(reference)
        let normalizedSnapshot = normalizedToastSnapshot(snapshot)
        guard let diff = Diffing.image(precision: precision).diff(normalizedReference, normalizedSnapshot) else { return }

        writeDiffArtifacts(
            reference: normalizedReference,
            snapshot: normalizedSnapshot,
            diff: diff.artifacts.diff,
            name: name
        )
        XCTFail(diff.message + "\n Diff snapshot URL: \(artifactsURL(named: name))", file: file, line: line)
    }

    func assertSwiftUISnapshotFail(
        snapshot: UIImage,
        named name: String,
        precision: Float,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let reference = storedSnapshot(named: name, file: file, line: line) else { return }

        let normalizedReference = normalizedToastSnapshot(reference)
        let normalizedSnapshot = normalizedToastSnapshot(snapshot)
        guard Diffing.image(precision: precision).diff(normalizedReference, normalizedSnapshot) != nil else {
            XCTFail("Images should be different.", file: file, line: line)
            return
        }
    }

    func normalizedToastSnapshot(_ snapshot: UIImage) -> UIImage {
        guard let cgImage = snapshot.cgImage,
              let pixels = pixelData(from: cgImage) else {
            return snapshot
        }

        let width = cgImage.width
        let height = cgImage.height
        let bounds = toastBounds(in: pixels, width: width, height: height)

        guard let bounds else { return snapshot }

        let scale = snapshot.scale
        let size = snapshot.size
        let clipRect = CGRect(
            x: CGFloat(bounds.minX) / scale,
            y: CGFloat(bounds.minY) / scale,
            width: CGFloat(bounds.maxX - bounds.minX + 1) / scale,
            height: CGFloat(bounds.maxY - bounds.minY + 1) / scale
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            context.cgContext.clip(to: CGRect(origin: .zero, size: clipRect.size))
            snapshot.draw(
                in: CGRect(
                    x: -clipRect.minX,
                    y: -clipRect.minY,
                    width: size.width,
                    height: size.height
                )
            )
        }
    }

    func storedSnapshot(
        named name: String,
        file: StaticString,
        line: UInt
    ) -> UIImage? {
        let url = snapshotURL(named: name, file: file)
        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            XCTFail(
                "Failed to load stored snapshot at URL: \(url). Use the `record` method to store a snapshot before asserting.",
                file: file,
                line: line
            )
            return nil
        }
        return image
    }

    func pixelData(from cgImage: CGImage) -> [UInt8]? {
        var pixels = [UInt8](repeating: 0, count: cgImage.width * cgImage.height * 4)
        guard let context = makeBitmapContext(
            data: &pixels,
            width: cgImage.width,
            height: cgImage.height
        ) else {
            return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        return pixels
    }

    func makeBitmapContext(data: inout [UInt8], width: Int, height: Int) -> CGContext? {
        CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }

    func toastBounds(
        in pixels: [UInt8],
        width: Int,
        height: Int
    ) -> PixelBounds? {
        var minX = width
        var minY = height
        var maxX = 0
        var maxY = 0
        let searchHeight = min(height, 360 * Int(UIScreen.main.scale))

        for y in 0..<searchHeight {
            for x in 0..<width {
                let index = (y * width + x) * 4
                if isToastCardPixel(
                    red: pixels[index],
                    green: pixels[index + 1],
                    blue: pixels[index + 2],
                    alpha: pixels[index + 3]
                ) {
                    minX = min(minX, x)
                    minY = min(minY, y)
                    maxX = max(maxX, x)
                    maxY = max(maxY, y)
                }
            }
        }

        guard minX <= maxX, minY <= maxY else { return nil }
        return PixelBounds(
            minX: max(minX - 12, 0),
            minY: max(minY - 12, 0),
            maxX: min(maxX + 12, width - 1),
            maxY: min(maxY + 12, height - 1)
        )
    }

    func isToastCardPixel(
        red: UInt8,
        green: UInt8,
        blue: UInt8,
        alpha: UInt8
    ) -> Bool {
        let red = Int(red)
        let green = Int(green)
        let blue = Int(blue)
        return alpha > 0 && green > 120 && green > red + 25 && green > blue + 25
    }

    func writeDiffArtifacts(reference: UIImage, snapshot: UIImage, diff: UIImage, name: String) {
        let url = artifactsURL(named: name)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        try? reference.pngData()?.write(to: url.appendingPathComponent("origin.png"))
        try? snapshot.pngData()?.write(to: url.appendingPathComponent("new.png"))
        try? diff.pngData()?.write(to: url.appendingPathComponent("diff.png"))
    }

    func artifactsURL(named name: String) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(name)
    }

    func snapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    func uiKitSnapshotName(for snapshotName: String) -> String {
        "UIKit_\(snapshotName)"
    }

    func resolvedUIKitSnapshotName(for snapshotName: String, file: StaticString) -> String {
        let prefixed = uiKitSnapshotName(for: snapshotName)
        if snapshotExists(named: prefixed, file: file) {
            return prefixed
        }
        return snapshotName
    }

    func snapshotExists(named name: String, file: StaticString) -> Bool {
        let url = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        return FileManager.default.fileExists(atPath: url.path)
    }

    func colorScheme(from snapshotName: String) -> ColorScheme {
        snapshotName.hasSuffix("_DARK") ? .dark : .light
    }

    func swiftUISnapshotPrecision(for snapshotName: String) -> Float {
        return swiftUISnapshotPrecision
    }

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> PairedToastViewSnapshotSUT {
        let sut = PairedToastViewSnapshotSUT()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        currentPairedSUT = sut
        return sut
    }
    
    func makeCommonStyle() -> CardViewPresentableModel.Style {
        .init(
            backgroundColor: .green,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .init(top: 12, leading: 12, bottom: 12, trailing: 12),
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: .black,
            titleKeyTextColor: .red,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .yellow,
            subTitleTextColor: .blue,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 13),
            titleKeyLabelFont: .systemFont(ofSize: 13),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 13),
            titleValueLabelFont: .systemFont(ofSize: 13),
            subTitleLabelFont: .systemFont(ofSize: 13),
            subtitleNumberOfLines: 1,
            cornerRadius: 12,
            stackSpace: 4,
            hStackViewSpacing: 14,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            trailingImageLeadingSpacing: 0
        )
    }
    
    func makeDefaultStyle() -> CardViewPresentableModel.Style {
        return .init(
            backgroundColor: .green,
            vStacklayoutMargins: .init(top: 12, leading: 12, bottom: 12, trailing: 12),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: .black,
            titleKeyTextColor: .black,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .gray,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 14),
            titleKeyLabelFont: .boldSystemFont(ofSize: 15),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 14),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 13),
            cornerRadius: 12,
            stackSpace: 4,
            hStackViewSpacing: 12,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .lightGray,
            borderWidth: 1
        )
    }
}
