//
//  WrapperViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 13/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class WrapperViewSnapshotTests: XCTestCase {
    func test_wrapperView_defaul_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "WRAPPERVIEW_DEFAULT_STATE"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_defaul_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "WRAPPERVIEW_DEFAULT_STATE"
        
        // WHEN
        sut.contentView.backgroundColor = .systemYellow
        sut.backgroundColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_with_content() {
        // GIVEN
        let (sut, container) = makeSUT()
        let label = Label()
        
        let snapshotName = "WRAPPERVIEW_WITH_CONTENT"
        
        // WHEN
        label.text = "Content to show!"
        label.textColor = .black
        
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        sut.contentView.addSubview(label)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_with_content() {
        // GIVEN
        let (sut, container) = makeSUT()
        let label = Label()
        
        let snapshotName = "WRAPPERVIEW_WITH_CONTENT"
        
        // WHEN
        label.text = "Content to show!."
        label.textColor = .black
        
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        sut.contentView.addSubview(label)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_with_multiline_text() {
        // GIVEN
        let (sut, container) = makeSUT()
        let label = Label()
        
        let snapshotName = "WRAPPERVIEW_MULTILINE_TEXT"
        
        // WHEN
        label.text = "This is a longer text that should wrap to multiple lines in the wrapper view"
        label.textColor = .black
        label.textAlignment = .center
        
        sut.contentView.backgroundColor = .white
        sut.contentView.addSubview(label)
        label.fillSuperview(padding: .init(top: 10, left: 10, bottom: 10, right: 10))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_with_multiline_text() {
        // GIVEN
        let (sut, container) = makeSUT()
        let label = Label()
        
        let snapshotName = "WRAPPERVIEW_MULTILINE_TEXT"
        
        // WHEN
        label.text = "This is a longer text that should wrap to multiple lines in the wrapper view."
        label.textColor = .black
        label.textAlignment = .center
        
        sut.contentView.backgroundColor = .white
        sut.contentView.addSubview(label)
        label.fillSuperview(padding: .init(top: 10, left: 10, bottom: 10, right: 10))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_hidden_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "WRAPPERVIEW_HIDDEN_STATE"
        
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        sut.isHidden = true
        
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_hidden_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "WRAPPERVIEW_HIDDEN_STATE"
        
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        sut.isHidden = false
        
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_with_button() {
        // GIVEN
        let (sut, container) = makeSUT()
        let button = Button(type: .system)
        
        let snapshotName = "WRAPPERVIEW_WITH_BUTTON"
        
        // WHEN
        let image = Image(systemName: "star.fill")
        button.textBackgroundColor = .cyan
        button.textColor = .black
        button.display(image: image)
        button.display(model: .init(title: "Tap Me", image: image))
        
        sut.contentView.addSubview(button)
        button.centerInSuperview()
        button.anchor(.width(120), .height(44))
        
        container.layoutIfNeeded()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_with_button() {
        // GIVEN
        let (sut, container) = makeSUT()
        let button = Button(type: .system)
        
        let snapshotName = "WRAPPERVIEW_WITH_BUTTON"
        
        // WHEN
        let image = Image(systemName: "star.fill")
        button.textBackgroundColor = .blue
        button.textColor = .black
        button.display(image: image)
        button.display(model: .init(title: "Tap Me", image: image))
        
        sut.contentView.addSubview(button)
        button.centerInSuperview()
        button.anchor(.width(120), .height(44))
        
        container.layoutIfNeeded()
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_no_padding() {
        // GIVEN
        let (sut, container) = makeSUT(padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        let snapshotName = "WRAPPERVIEW_NO_PADDING"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_no_padding() {
        // GIVEN
        let (sut, container) = makeSUT(padding: .init(top: 1, left: 0, bottom: 0, right: 0))
        let snapshotName = "WRAPPERVIEW_NO_PADDING"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_large_padding() {
        // GIVEN
        let (sut, container) = makeSUT(padding: .init(top: 60, left: 60, bottom: 60, right: 60))
        let snapshotName = "WRAPPERVIEW_LARGE_PADDING"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_large_padding() {
        // GIVEN
        let (sut, container) = makeSUT(padding: .init(top: 59, left: 60, bottom: 60, right: 60))
        let snapshotName = "WRAPPERVIEW_LARGE_PADDING"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_asymmetric_padding() {
        // GIVEN
        let (sut, container) = makeSUT(padding: .init(top: 0, left: 20, bottom: 45, right: 85))
        let snapshotName = "WRAPPERVIEW_ASYMMETRIC_PADDING"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_asymmetric_padding() {
        // GIVEN
        let (sut, container) = makeSUT(padding: .init(top: 1, left: 20, bottom: 45, right: 85))
        let snapshotName = "WRAPPERVIEW_ASYMMETRIC_PADDING"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.backgroundColor = .red
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_with_rounded_corners() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "WRAPPERVIEW_ROUNDED_CORNERS"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.contentView.layer.cornerRadius = 16
        sut.contentView.layer.masksToBounds = true
        sut.backgroundColor = .red
        sut.layer.cornerRadius = 16
        sut.layer.masksToBounds = true
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_with_rounded_corners() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "WRAPPERVIEW_ROUNDED_CORNERS"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.contentView.layer.cornerRadius = 15
        sut.contentView.layer.masksToBounds = true
        sut.backgroundColor = .red
        sut.layer.cornerRadius = 16
        sut.layer.masksToBounds = true
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_wrapperView_with_border() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "WRAPPERVIEW_WITH_BORDER"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.contentView.layer.borderWidth = 3
        sut.contentView.layer.borderColor = UIColor.blue.cgColor
        sut.backgroundColor = .red
        sut.layer.borderColor = UIColor.black.cgColor
        sut.layer.borderWidth = 3
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_wrapperView_with_border() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "WRAPPERVIEW_WITH_BORDER"
        
        // WHEN
        sut.contentView.backgroundColor = .yellow
        sut.contentView.layer.borderWidth = 3
        sut.contentView.layer.borderColor = UIColor.blue.cgColor
        sut.backgroundColor = .red
        sut.layer.borderColor = UIColor.black.cgColor
        sut.layer.borderWidth = 2
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
}

extension WrapperViewSnapshotTests {
    func makeSUT(
        padding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: WrapperView<UIView>, container: UIView) {
        
        let sut = WrapperView(contentView: UIView(), contentViewConstraints: { contentView, superVIew in
            contentView.fillSuperview(padding: padding)
        })
        
        let container = makeContainer()
        
        sut.contentView.backgroundColor = .red
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(200, priority: .required)
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
