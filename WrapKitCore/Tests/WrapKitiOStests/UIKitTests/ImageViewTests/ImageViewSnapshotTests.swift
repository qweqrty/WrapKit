//
//  ImageViewSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils

class ImageViewSnapshotTests: XCTestCase {
    
    // TODO: - Doesnt show image from assets, like "mini", "Swift"
    func test_imageView_defaultState() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
//        // WHEN
//        let image = UIImage(systemName: "pencil")
        let image = Image(named: "mini")
        
        sut.display(image: .asset(image), completion: { _ in
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        // THEN
        record(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_DEFAULT_STATE_LIGHT")
        record(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_DEFAULT_STATE_DARK")
    }
    
    // TODO: - from urlString doesnt work
//    func test_ImageView_from_urlString() {
//        // GIVEN
//        let sut = makeSUT()
//        let exp = expectation(description: "Wait for completion")
//        
//        // WHEN
//        let urlString = "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png"
//        
//        sut.display(image: .urlString(urlString, urlString)) { _ in
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 5.0)
//        // THEN
//        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_URLSTRING_LIGHT")
//        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_URLSTRING_DARK")
//    }
    
    // TODO: - from URL doesnt work
    func test_ImageView_from_url() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        let url = URL(string: "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png")!
        sut.display(image: .url(url, url))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_URL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_URl_DARK")
    }
    
    func test_imageView_contentMode_is_fit() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        let image = UIImage(systemName: "pencil")
        sut.display(image: .asset(image))
        sut.display(contentModeIsFit: true)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_FITCONTENTMODE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_FITCONTENTMODE_DARK")
    }
    
    func test_imageView_with_borderdWidth() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(borderWidth: 2.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_BORDERWIDTH_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_BORDERWIDTH_DARK")
    }
    
    func test_imageView_with_borderColor() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(borderColor: .red)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_BORDERWIDTH_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_BORDERWIDTH_DARK")
    }
}

extension ImageViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> ImageView {
        let sut = ImageView()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
        
        return sut
    }
}

fileprivate extension CardViewPresentableModel.Style {
}
