//
//  ToastViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 11/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class ToastViewSnapshotTests: XCTestCase {
    
    private let image = UIImage(systemName: "star.fill")
    
    func test_ToastView_default_state() {
        let snapshotName = "TOASTVIEW_DEFAULT_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Toast Message")
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_default_state() {
        let snapshotName = "TOASTVIEW_DEFAULT_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Toast Message.")
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_leadingImage() {
        let snapshotName = "TOASTVIEW_WITH_LEADINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
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
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
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
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    // TODO: = title doesnt wrap to multiple lines
    func test_ToastView_with_long_text() {
        let snapshotName = "TOASTVIEW_WITH_LONGTEXT"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("This is a very long toast message that should wrap to multiple lines"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
            ),
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_long_text() {
        let snapshotName = "TOASTVIEW_WITH_LONGTEXT"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text(".This is a very long toast message that should wrap to multiple lines"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
            ),
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_subTitle() {
        let snapshotName = "TOASTVIEW_WITH_SUBTITLE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
            ),
            subTitle: .text("Subtitile")
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_subTitle() {
        let snapshotName = "TOASTVIEW_WITH_SUBTITLE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
            ),
            subTitle: .text("Subtitile.")
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_valueTitle() {
        let snapshotName = "TOASTVIEW_WITH_VALUETITLE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
            ),
            valueTitle: .text("Value title")
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
       
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_valueTitle() {
        let snapshotName = "TOASTVIEW_WITH_VALUETITLE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            leadingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
            ),
            valueTitle: .text("Value title.")
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
       
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_trailingImage() {
        let snapshotName = "TOASTVIEW_WITH_TRAILINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            trailingImage: .init(
                size: .init(width: 32, height: 32),
                image: .asset(image),
            ),
            subTitle: .text("Subtitile")
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_trailingImage() {
        let snapshotName = "TOASTVIEW_WITH_TRAILINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            trailingImage: .init(
                size: .init(width: 33, height: 32),
                image: .asset(image),
            ),
            subTitle: .text("Subtitile")
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_switchControl() {
        let snapshotName = "TOASTVIEW_WITH_SWITCHCONTROL"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            switchControl: .init(
                isOn: true,
                isEnabled: true,
                style: .init(tintColor: .red,
                             thumbTintColor: .systemBlue,
                             backgroundColor: .systemBackground,
                             cornerRadius: 10))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_switchControl() {
        let snapshotName = "TOASTVIEW_WITH_SWITCHCONTROL"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            switchControl: .init(
                isOn: true,
                isEnabled: true,
                style: .init(tintColor: .systemRed,
                             thumbTintColor: .systemBlue,
                             backgroundColor: .systemBackground,
                             cornerRadius: 10))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_bottomSeparator() {
        let snapshotName = "TOASTVIEW_WITH_BOTTOMSEPARATOR"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            bottomSeparator: .init(color: .black, height: 2.0)
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_bottomSeparator() {
        let snapshotName = "TOASTVIEW_WITH_BOTTOMSEPARATOR"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            bottomSeparator: .init(color: .black, height: 1.0)
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_leadingTitles() {
        let snapshotName = "TOASTVIEW_WITH_lEADINGTITLES"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            leadingTitles: .init(.text("First title"), .text("Second title"))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_leadingTitles() {
        let snapshotName = "TOASTVIEW_WITH_lEADINGTITLES"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            leadingTitles: .init(.text("First title."), .text("Second title"))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_trailingTitles() {
        let snapshotName = "TOASTVIEW_WITH_TRAILINGTITLES"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            trailingTitles: .init(.text("First title"), .text("Second title"))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_trailingTitles() {
        let snapshotName = "TOASTVIEW_WITH_TRAILINGTITLES"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            trailingTitles: .init(.text("First title."), .text("Second title"))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_secondaryLeadingImage() {
        let snapshotName = "TOASTVIEW_WITH_SECONDARYLEADINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            secondaryLeadingImage: .init(image: .asset(image))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_secondaryLeadingImage() {
        let snapshotName = "TOASTVIEW_WITH_SECONDARYLEADINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        let image = Image(systemName: "star")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            secondaryLeadingImage: .init(image: .asset(image))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ToastView_with_secondaryTrailingImage() {
        let snapshotName = "TOASTVIEW_WITH_SECONDARYTRAILINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            secondaryTrailingImage: .init(image: .asset(image))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ToastView_with_secondaryTrailingImage() {
        let snapshotName = "TOASTVIEW_WITH_SECONDARYTRAILINGIMAGE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion!")
        
        let image = Image(systemName: "star")
        
        // WHEN
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Title"),
            secondaryTrailingImage: .init(image: .asset(image))
        ))
        
        sut.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
}

extension ToastViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> ToastView {
        let sut = ToastView(duration: nil, position: .top)
        
        checkForMemoryLeaks(sut, file: file, line: line)
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
        return sut
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
