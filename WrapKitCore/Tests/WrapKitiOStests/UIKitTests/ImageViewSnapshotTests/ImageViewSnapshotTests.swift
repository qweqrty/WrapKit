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

final class ImageViewSnapshotTests: XCTestCase {
    
    private let light = "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png"
    private let dark = "https://uxwing.com/wp-content/themes/uxwing/download/web-app-development/dark-mode-icon.png"
    private let apiRandomImage = "https://picsum.photos/200/300"
    private let cachedImageTest1 = "https://picsum.photos/seed/test1/200/300"
    private let cachedImageTest2 = "https://picsum.photos/seed/test2/200/300"
    
    override class func setUp() {
            super.setUp()
            
            KingfisherManager.shared.cache.clearCache()
            KingfisherManager.shared.cache.clearMemoryCache()
            KingfisherManager.shared.cache.clearDiskCache()
        }
    
    func test_imageView_defaultState() {
        let snapshotName = "IMAGE_VIEW_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
//        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image), completion: { _ in
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_defaultState() {
        let snapshotName = "IMAGE_VIEW_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
//        // WHEN
        let image = UIImage(systemName: "star.fill")
        sut.display(image: .asset(image), completion: { _ in
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - Check it
    func test_imageView_withCachedImage_light() {
        let snapshotName = "IMAGE_VIEW_WITH_CACHED_IMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit(backgroundColor: .blue)
        
        let firstUrl = URL(string: cachedImageTest1)!
        let secondUrl = URL(string: cachedImageTest2)!
        
        let firstLoadExp = expectation(description: "First image load")
        sut.display(image: .url(firstUrl, firstUrl)) { _ in
            firstLoadExp.fulfill()
        }
        wait(for: [firstLoadExp], timeout: 5.0)
        
        // first image snapshot
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS26_\(snapshotName)_FIRST_LOADED_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                   named: "iOS18.3.1_\(snapshotName)_FIRST_LOADED_LIGHT")
        }
        
        guard let cachedImage = sut.image else {
            XCTFail("First image should be loaded")
            return
        }
        
        KingfisherManager.shared.cache.store(
            cachedImage,
            forKey: secondUrl.absoluteString,
            toDisk: true
        ) { _ in
            
        }
        
        Thread.sleep(forTimeInterval: 0.5)
        
        KingfisherManager.shared.cache.clearMemoryCache()
        sut.image = nil
        
        let secondLoadExp = expectation(description: "Second image load")
        
        sut.display(image: .url(secondUrl, secondUrl))
        
        // loading view snapshot
        DispatchQueue.main.async {
            if #available(iOS 26, *) {
                self.assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                           named: "iOS26_\(snapshotName)_LOADINGVIEW_LIGHT")
            } else {
                self.assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                           named: "iOS18.3.1_\(snapshotName)_LOADINGVIEW_LIGHT")
            }
        }
        
        // image from cache snapshot
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if #available(iOS 26, *) {
                self.assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                           named: "iOS26_\(snapshotName)_FROM_CACHE_LIGHT")
            } else {
                self.assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                           named: "iOS18.3.1_\(snapshotName)_FROM_CACHE_LIGHT")
            }
        }
        
        // second image snapshot
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if #available(iOS 26, *) {
                self.assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                           named: "iOS26_\(snapshotName)_UPDATED_LIGHT")
            } else {
                self.assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
                           named: "iOS18.3.1_\(snapshotName)_UPDATED_LIGHT")
            }
            secondLoadExp.fulfill()
        }
        
        wait(for: [secondLoadExp], timeout: 10.0)
    }
    
    func test_ImageView_from_urlString_light() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_LIGHT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let urlString = light
        sut.display(image: .urlString(urlString, urlString)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        }
    }
    
    func test_fail_ImageView_from_urlString_light() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_LIGHT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let urlString = light
        sut.display(image: .urlString(urlString, urlString)) { [weak sut] _ in
            sut?.backgroundColor = .red
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        }
    }

    func test_ImageView_from_urlString_dark() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_DARK"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let urlString = light
        sut.display(image: .urlString(urlString, urlString)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ImageView_from_urlString_dark() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_DARK"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let urlString = light
        sut.display(image: .urlString(urlString, urlString)) { [weak sut] _ in
            sut?.backgroundColor = .red
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ImageView_with_no_urlString() {
        let snapshotName = "IMAGE_VIEW_NO_URLSTRING"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        // WHEN
        sut.display(image: .urlString(nil, nil))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ImageView_with_no_urlString() {
        let snapshotName = "IMAGE_VIEW_NO_URLSTRING"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark.circle")!
        // WHEN
        sut.display(image: .urlString(nil, nil))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ImageView_from_url_light() {
        let snapshotName = "IMAGE_VIEW_URL_LIGHT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let url = URL(string: light)!
        sut.display(image: .url(url, url)) { image in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        }
    }
    
    func test_fail_ImageView_from_url_light() {
        let snapshotName = "IMAGE_VIEW_URL_LIGHT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let url = URL(string: light)!
        sut.display(image: .url(url, url)) { [weak sut] _ in
            sut?.backgroundColor = .red
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        }
    }
    
    func test_ImageView_with_no_url() {
        let snapshotName = "IMAGE_VIEW_NO_URL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        
        // WHEN
        sut.display(image: .url(nil, nil))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ImageView_with_no_url() {
        let snapshotName = "IMAGE_VIEW_NO_URL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark.circle")!
        
        // WHEN
        sut.display(image: .url(nil, nil))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ImageView_viewWhileLoadingView() {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit(backgroundColor: .blue)
        
        // WHEN
        let url = URL(string: light)!
        sut.display(image: .url(url, url))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ImageView_viewWhileLoadingView() {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit(backgroundColor: .cyan)
        
        // WHEN
        let url = URL(string: light)!
        sut.display(image: .url(url, url))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ImageView_fallbackView() {
        let snapshotName = "IMAGE_VIEW_FALLBACKVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.fallbackView = ViewUIKit(backgroundColor: .red)
        
        // WHEN
        let url = URL(string: "wrong url")!
        sut.display(image: .url(url, url))
        
        // Подождать чуть-чуть, пока UI обновится
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ImageView_fallbackView() {
        let snapshotName = "IMAGE_VIEW_FALLBACKVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.fallbackView = ViewUIKit(backgroundColor: .systemRed)
        
        // WHEN
        let url = URL(string: "wrong url")!
        sut.display(image: .url(url, url))
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_ImageView_from_url_dark() {
        let snapshotName = "IMAGE_VIEW_URl_DARK"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let url = URL(string: light)!
        
        sut.display(image: .url(url, url)) { image in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_ImageView_from_url_dark() {
        let snapshotName = "IMAGE_VIEW_URl_DARK"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let url = URL(string: light)!
        
        sut.display(image: .url(url, url)) { [weak sut] _ in
            sut?.backgroundColor = .red
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_imageView_contentMode_is_fit() {
        let snapshotName = "IMAGE_VIEW_FITCONTENTMODE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image))
        sut.display(contentModeIsFit: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_contentMode_is_fit() {
        let snapshotName = "IMAGE_VIEW_FITCONTENTMODE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image))
        sut.display(contentModeIsFit: false)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_imageView_with_borderdWidth() {
        let snapshotName = "IMAGE_VIEW_BORDERWIDTH"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(borderWidth: 2.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_with_borderdWidth() {
        let snapshotName = "IMAGE_VIEW_BORDERWIDTH"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(borderWidth: 3.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_imageView_with_borderColor() {
        let snapshotName = "IMAGE_VIEW_BORDERCOLOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(borderColor: .red)
        sut.display(borderWidth: 2.0)
        sut.backgroundColor = .cyan
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_with_borderColor() {
        let snapshotName = "IMAGE_VIEW_BORDERCOLOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(borderColor: .systemRed)
        sut.display(borderWidth: 2.0)
        sut.backgroundColor = .cyan
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_imageView_with_cornerRadius() {
        let snapshotName = "IMAGE_VIEW_CORNERRADIUS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(cornerRadius: 50)
        sut.backgroundColor = .cyan
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_with_cornerRadius() {
        let snapshotName = "IMAGE_VIEW_CORNERRADIUS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(cornerRadius: 51)
        sut.backgroundColor = .cyan
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_imageView_with_alpha() {
        let snapshotName = "IMAGE_VIEW_ALPHA"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(alpha: 0.3)
        sut.backgroundColor = .cyan
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_with_alpha() {
        let snapshotName = "IMAGE_VIEW_ALPHA"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(alpha: 0.4)
        sut.backgroundColor = .cyan
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_imageView_with_hidden() {
        let snapshotName = "IMAGE_VIEW_HIDDEN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(isHidden: false)
        sut.backgroundColor = .cyan
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_with_hidden() {
        let snapshotName = "IMAGE_VIEW_HIDDEN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(isHidden: true)
        sut.backgroundColor = .cyan
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    //MARK: - touches simulation
    func test_imageView_onPress_visualState() {
        let snapshotName = "IMAGE_VIEW_ONPRESS"
        let releasedSnapshotName = "IMAGE_VIEW_ONPRESS_RELEASED"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(onPress: {
            
        })
        
        let image = UIImage(systemName: "star.fill")
        sut.display(image: .asset(image))
        
        sut.touchesBegan(Set(), with: nil)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        }
        
        sut.touchesEnded(Set(), with: nil)
        
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(releasedSnapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(releasedSnapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(releasedSnapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(releasedSnapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_onPress_visualState() {
        let snapshotName = "IMAGE_VIEW_ONPRESS"
        let releasedSnapshotName = "IMAGE_VIEW_ONPRESS_RELEASED"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(onPress: {
           
        })
        
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image))
        
        sut.touchesBegan(Set(), with: nil)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
        }
        
        sut.touchesEnded(Set(), with: nil)
        
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(releasedSnapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(releasedSnapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(releasedSnapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(releasedSnapshotName)_DARK")
        }
    }
    
    // MARK: - Completion calling directly
    func test_imageView_direct_onPress() {
        let snapshotName = "IMAGE_VIEW_ONPRESS_DIRECT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for animation completion")
        
        // WHEN
        sut.display(onPress: { [weak sut] in
            sut?.backgroundColor = .red
            exp.fulfill()
        })
        
        sut.onPress?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_direct_onPress() {
        let snapshotName = "IMAGE_VIEW_ONPRESS_DIRECT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for animation completion")
        
        // WHEN
        sut.display(onPress: { [weak sut] in
            sut?.backgroundColor = .systemRed
            exp.fulfill()
        })
        
        sut.onPress?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_imageView_direct_onLongPress() {
        let snapshotName = "IMAGE_VIEW_ONLONGPRESS_DIRECT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for onLongPress")
        
        // WHEN
        sut.display(onLongPress: { [weak sut] in
            sut?.backgroundColor = .systemYellow
            exp.fulfill()
        })
        
        sut.onLongPress?()
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_imageView_direct_onLongPress() {
        let snapshotName = "IMAGE_VIEW_ONLONGPRESS_DIRECT"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for onLongPress")
        
        // WHEN
        sut.display(onLongPress: { [weak sut] in
            sut?.backgroundColor = .yellow
            exp.fulfill()
        })
        
        sut.onLongPress?()
        
        wait(for: [exp], timeout: 1.0)
        
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

extension ImageViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ImageView, container: UIView) {
        let sut = ImageView()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(150, priority: .required)
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

fileprivate extension CardViewPresentableModel.Style {
}
