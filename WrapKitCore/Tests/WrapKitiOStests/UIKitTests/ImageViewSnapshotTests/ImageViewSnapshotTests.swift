//
//  ImageViewSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils
import Kingfisher

private enum ImageTestLinks: String {
    case light = "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png"
    case dark = "https://uxwing.com/wp-content/themes/uxwing/download/web-app-development/dark-mode-icon.png"
}

class ImageViewSnapshotTests: XCTestCase {
    override class func setUp() {
            super.setUp()
            
            KingfisherManager.shared.cache.clearCache()
            KingfisherManager.shared.cache.clearMemoryCache()
            KingfisherManager.shared.cache.clearDiskCache()
        }
    
    func test_imageView_defaultState() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
//        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image), completion: { _ in
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_DEFAULT_STATE_DARK")
    }
    
    func test_ImageView_from_urlString_light() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let urlString = ImageTestLinks.light.rawValue
        sut.display(image: .urlString(urlString, urlString)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_URLSTRING_LIGHT")
    }

    func test_ImageView_from_urlString_dark() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let urlString = ImageTestLinks.dark.rawValue
        sut.display(image: .urlString(urlString, urlString)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_URLSTRING_DARK")
    }
    
    func test_ImageView_with_no_urlString() {
        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        // WHEN
        sut.display(image: .urlString(nil, nil))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_NO_URLSTRING_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_NO_URLSTRING_DARK")
    }
    
    func test_ImageView_from_url_light() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let url = URL(string: ImageTestLinks.light.rawValue)!
        sut.display(image: .url(url, url)) { image in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_URL_LIGHT")
    }
    
    func test_ImageView_with_no_url() {
        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        
        // WHEN
        sut.display(image: .url(nil, nil))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_NO_URL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_NO_URL_DARK")
    }
    
    func test_ImageView_viewWhileLoadingView() {
        // GIVEN
        let sut = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit(backgroundColor: .blue)
        
        // WHEN
        let url = URL(string: ImageTestLinks.light.rawValue)!
        sut.display(image: .url(url, url))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_VIEWWHILELOADINGVIEW_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_VIEWWHILELOADINGVIEW_DARK")
    }
    
    func test_ImageView_fallbackView() {
        // GIVEN
        let sut = makeSUT()
        sut.fallbackView = ViewUIKit(backgroundColor: .red)
        
        // WHEN
        let url = URL(string: "wrong url")!
        sut.display(image: .url(url, url))
        
        // Подождать чуть-чуть, пока UI обновится
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_FALLBACKVIEW_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_FALLBACKVIEW_DARK")
    }
    
    func test_ImageView_from_url_dark() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let url = URL(string: ImageTestLinks.dark.rawValue)!
        
        sut.display(image: .url(url, url)) { image in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_URl_DARK")
    }
    
    func test_imageView_contentMode_is_fit() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        let image = UIImage(systemName: "star")
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
        sut.display(borderWidth: 2.0)
        sut.backgroundColor = .cyan
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_BORDERCOLOR_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_BORDERCOLOR_DARK")
    }
    
    func test_imageView_with_cornerRadius() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(cornerRadius: 50)
        sut.backgroundColor = .cyan
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_CORNERRADIUS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_CORNERRADIUS_DARK")
    }
    
    func test_imageView_with_alpha() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(alpha: 0.3)
        sut.backgroundColor = .cyan
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_ALPHA_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_ALPHA_DARK")
    }
    
    func test_imageView_with_hidden() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(isHidden: false)
        sut.backgroundColor = .cyan
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_HIDDEN_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_HIDDEN_DARK")
    }
    
    //MARK: - touches simulation
    func test_imageView_onPress_visualState() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(onPress: {
            
        })
        
        let image = UIImage(systemName: "star.fill")
        sut.display(image: .asset(image))
        
        sut.touchesBegan(Set(), with: nil)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_ONPRESS_PRESSED_LIGHT")
        
        sut.touchesEnded(Set(), with: nil)
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_ONPRESS_RELEASED_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_ONPRESS_RELEASED_DARK")
    }
    
    // MARK: - Completion calling directly
    func test_imageView_direct_onPress() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for animation completion")
        
        // WHEN
        sut.display(onPress: { [weak sut] in
            sut?.backgroundColor = .red
            exp.fulfill()
        })
        
        sut.onPress?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_ONPRESS_DIRECT_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_ONPRESS_DIRECT_DARK")
    }
    
    func test_imageView_direct_onLongPress() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for onLongPress")
        
        // WHEN
        sut.display(onLongPress: { [weak sut] in
            sut?.backgroundColor = .systemYellow
            exp.fulfill()
        })
        
        sut.onLongPress?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_VIEW_ONLONGPRESS_STATIC_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_VIEW_ONLONGPRESS_STATIC_DARK")
    }
}

extension ImageViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> ImageView {
        let sut = ImageView()
        
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

fileprivate extension CardViewPresentableModel.Style {
}
