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
import SwiftUI

final class ImageViewSnapshotTests: XCTestCase {
    private weak var currentPairedSUT: PairedImageViewSnapshotSUT?
    
    private let light = "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png"
    private let dark = "https://uxwing.com/wp-content/themes/uxwing/download/web-app-development/dark-mode-icon.png"
    private let apiRandomImage = "https://picsum.photos/200/300"
    private let cachedImageTest1 = "https://picsum.photos/seed/test1/200/300"
    private let cachedImageTest2 = "https://picsum.photos/seed/test2/200/300"
    
    override class func setUp() {
        super.setUp()
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearCache()
        KingfisherManager.shared.cache.clearDiskCache()
        KingfisherManager.shared.cache.cleanExpiredCache()
        KingfisherManager.shared.cache.cleanExpiredMemoryCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
    }

    override func tearDown() {
        currentPairedSUT = nil
        super.tearDown()
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }
    
    // MARK: - TODO - URMAT
//    func test_imageView_withCachedImage_light() {
//        let snapshotName = "IMAGE_VIEW_WITH_CACHED_IMAGE"
//        
//        // GIVEN
//        let (sut, container) = makeSUT()
//        sut.viewWhileLoadingView = ViewUIKit(backgroundColor: .blue)
//        
//        let firstUrl = URL(string: cachedImageTest1)!
//        let secondUrl = URL(string: cachedImageTest2)!
//        
//        let firstLoadExp = expectation(description: "First image load")
//        sut.display(image: .url(firstUrl, firstUrl)) { _ in
//            firstLoadExp.fulfill()
//        }
//        wait(for: [firstLoadExp], timeout: 5.0)
//        
//        // first image snapshot
//        if #available(iOS 26, *) {
//            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)),
//                   named: "iOS26_\(snapshotName)_FIRST_LOADED_LIGHT")
//        } else {
//            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)),
//                   named: "iOS18.5_\(snapshotName)_FIRST_LOADED_LIGHT")
//        }
//        
//        guard let cachedImage = sut.image else {
//            XCTFail("First image should be loaded")
//            return
//        }
//        
//        KingfisherManager.shared.cache.store(
//            cachedImage,
//            forKey: secondUrl.absoluteString,
//            toDisk: true
//        ) { _ in
//            
//        }
//        
//        Thread.sleep(forTimeInterval: 0.5)
//        
//        KingfisherManager.shared.cache.clearMemoryCache()
//        sut.image = nil
//        
//        let secondLoadExp = expectation(description: "Second image load")
//        
//        sut.display(image: .url(secondUrl, secondUrl))
//        
//        // loading view snapshot
//        DispatchQueue.main.async {
//            if #available(iOS 26, *) {
//                self.assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)),
//                           named: "iOS26_\(snapshotName)_LOADINGVIEW_LIGHT")
//            } else {
//                self.assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)),
//                           named: "iOS18.5_\(snapshotName)_LOADINGVIEW_LIGHT")
//            }
//        }
//        
//        // image from cache snapshot
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            if #available(iOS 26, *) {
//                self.assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)),
//                           named: "iOS26_\(snapshotName)_FROM_CACHE_LIGHT")
//            } else {
//                self.assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)),
//                           named: "iOS18.5_\(snapshotName)_FROM_CACHE_LIGHT")
//            }
//        }
//        
//        // second image snapshot
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            if #available(iOS 26, *) {
//                self.assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)),
//                           named: "iOS26_\(snapshotName)_UPDATED_LIGHT")
//            } else {
//                self.assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)),
//                           named: "iOS18.5_\(snapshotName)_UPDATED_LIGHT")
//            }
//            secondLoadExp.fulfill()
//        }
//        
//        wait(for: [secondLoadExp], timeout: 10.0)
//    }
    
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_ImageView_from_urlString_dark() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_DARK"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let urlString = dark
        sut.display(image: .urlString(urlString, urlString)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_ImageView_viewWhileLoadingView() {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit(backgroundColor: .blue)
        
        // WHEN
        let url = URL(string: "\(apiRandomImage)?snapshot=\(UUID().uuidString)")!
        sut.display(image: .url(url, url))

        let capture: (_ dark: Bool) -> UIImage = { dark in
            sut.uiKitImageView.image = nil
            sut.uiKitImageView.backgroundColor = sut.uiKitImageView.viewWhileLoadingView?.backgroundColor
            sut.uiKitImageView.viewWhileLoadingView?.isHidden = false
            sut.uiKitImageView.viewWhileLoadingView?.alpha = 1
            sut.showLoadingForSnapshot(color: sut.uiKitImageView.viewWhileLoadingView?.backgroundColor)
            sut.uiKitImageView.viewWhileLoadingView?.setNeedsLayout()
            sut.uiKitImageView.viewWhileLoadingView?.layoutIfNeeded()
            sut.uiKitImageView.setNeedsLayout()
            sut.uiKitImageView.layoutIfNeeded()
            container.setNeedsLayout()
            container.layoutIfNeeded()
            return container.snapshot(for: .iPhone(style: dark ? .dark : .light))
        }
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: capture(true), named: "iOS26_\(snapshotName)_DARK")
            assertPairedSnapshot(snapshot: capture(false), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshot(snapshot: capture(true), named: "iOS18.5_\(snapshotName)_DARK")
            assertPairedSnapshot(snapshot: capture(false), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }
    
    func test_fail_ImageView_viewWhileLoadingView() {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        
        // GIVEN
        let (sut, container) = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit(backgroundColor: .cyan)
        
        // WHEN
        let url = URL(string: "\(apiRandomImage)?snapshot=\(UUID().uuidString)")!
        sut.display(image: .url(url, url))

        let capture: (_ dark: Bool) -> UIImage = { dark in
            sut.uiKitImageView.image = nil
            sut.uiKitImageView.backgroundColor = sut.uiKitImageView.viewWhileLoadingView?.backgroundColor
            sut.uiKitImageView.viewWhileLoadingView?.isHidden = false
            sut.uiKitImageView.viewWhileLoadingView?.alpha = 1
            sut.showLoadingForSnapshot(color: sut.uiKitImageView.viewWhileLoadingView?.backgroundColor)
            sut.uiKitImageView.viewWhileLoadingView?.setNeedsLayout()
            sut.uiKitImageView.viewWhileLoadingView?.layoutIfNeeded()
            sut.uiKitImageView.setNeedsLayout()
            sut.uiKitImageView.layoutIfNeeded()
            container.setNeedsLayout()
            container.layoutIfNeeded()
            return container.snapshot(for: .iPhone(style: dark ? .dark : .light))
        }
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: capture(true), named: "iOS26_\(snapshotName)_DARK")
            assertPairedSnapshotFail(snapshot: capture(false), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshotFail(snapshot: capture(true), named: "iOS18.5_\(snapshotName)_DARK")
            assertPairedSnapshotFail(snapshot: capture(false), named: "iOS18.5_\(snapshotName)_LIGHT")
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
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        sut.showFallbackForSnapshot()

        let capture: (Bool) -> UIImage = { isDark in
            sut.uiKitImageView.image = nil
            sut.uiKitImageView.viewWhileLoadingView?.isHidden = true
            sut.uiKitImageView.viewWhileLoadingView?.alpha = 0
            sut.uiKitImageView.fallbackView?.isHidden = false
            sut.uiKitImageView.fallbackView?.alpha = 1
            container.setNeedsLayout()
            container.layoutIfNeeded()
            return container.snapshot(for: .iPhone(style: isDark ? .dark : .light))
        }
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: capture(false), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: capture(true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: capture(false), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: capture(true), named: "iOS18.5_\(snapshotName)_DARK")
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
        sut.showFallbackForSnapshot()

        let capture: (Bool) -> UIImage = { isDark in
            sut.uiKitImageView.image = nil
            sut.uiKitImageView.viewWhileLoadingView?.isHidden = true
            sut.uiKitImageView.viewWhileLoadingView?.alpha = 0
            sut.uiKitImageView.fallbackView?.isHidden = false
            sut.uiKitImageView.fallbackView?.alpha = 1
            container.setNeedsLayout()
            container.layoutIfNeeded()
            return container.snapshot(for: .iPhone(style: isDark ? .dark : .light))
        }
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: capture(false), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: capture(true), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: capture(false), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: capture(true), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_ImageView_from_url_dark() {
        let snapshotName = "IMAGE_VIEW_URl_DARK"
        
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        // WHEN
        let url = URL(string: dark)!
        
        sut.display(image: .url(url, url)) { image in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
        
        sut.touchesEnded(Set(), with: nil)
        
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(releasedSnapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(releasedSnapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(releasedSnapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(releasedSnapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
        
        sut.touchesEnded(Set(), with: nil)
        
        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(releasedSnapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(releasedSnapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(releasedSnapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(releasedSnapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

private extension ImageViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PairedImageViewSnapshotSUT, container: UIView) {
        let sut = PairedImageViewSnapshotSUT()
        let container = makeContainer()

        container.addSubview(sut.uiKitImageView)
        sut.uiKitImageView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(150, priority: .required)
        )

        container.layoutIfNeeded()

        currentPairedSUT = sut

        checkForMemoryLeaks(sut.uiKitImageView, file: file, line: line)
        return (sut, container)
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }

}

private extension ImageViewSnapshotTests {
    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        saveAssertSnapshot(snapshot, named: assertSnapshotName(for: name, context: "UIKit"), context: "UIKit")
        assertStoredSnapshotEquals(snapshot, named: name, precision: precision, context: "UIKit", file: file, line: line)

        if #available(iOS 17, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            saveAssertSnapshot(swiftUISnapshot, named: assertSnapshotName(for: name, context: "SwiftUI"), context: "SwiftUI")
            assertStoredSnapshotEquals(
                swiftUISnapshot,
                named: name,
                precision: swiftUISnapshotPrecision,
                context: "SwiftUI",
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
        saveAssertSnapshot(snapshot, named: assertSnapshotName(for: name, context: "UIKit"), context: "UIKit")
        assertStoredSnapshotDifferent(snapshot, named: name, precision: precision, context: "UIKit", file: file, line: line)

        if #available(iOS 17, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            saveAssertSnapshot(swiftUISnapshot, named: assertSnapshotName(for: name, context: "SwiftUI"), context: "SwiftUI")
            assertStoredSnapshotDifferent(
                swiftUISnapshot,
                named: name,
                precision: swiftUIFailSnapshotPrecision,
                context: "SwiftUI",
                file: file,
                line: line
            )
        }
    }

    func recordPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        recordUIKitSnapshot(snapshot, named: recordedSnapshotName(for: name), file: file, line: line)
    }

    private var swiftUISnapshotPrecision: Float {
        0.98
    }

    private var swiftUIFailSnapshotPrecision: Float {
        1
    }

    private func colorScheme(from snapshotName: String) -> ColorScheme {
        normalizedSnapshotName(from: snapshotName).hasSuffix("_DARK") ? .dark : .light
    }

    private func recordedSnapshotName(for snapshotName: String) -> String {
        "UIKit_\(normalizedSnapshotName(from: snapshotName))"
    }

    private func assertSnapshotName(for snapshotName: String, context: String) -> String {
        let prefix = context == "SwiftUI" ? "SiwftUI" : "UIKit"
        return "\(prefix)_\(normalizedSnapshotName(from: snapshotName))"
    }

    private func normalizedSnapshotName(from snapshotName: String) -> String {
        if snapshotName.hasPrefix("UIKit_") {
            return String(snapshotName.dropFirst("UIKit_".count))
        }
        if snapshotName.hasPrefix("SiwftUI_") {
            return String(snapshotName.dropFirst("SiwftUI_".count))
        }
        if snapshotName.hasPrefix("SwiftUI_") {
            return String(snapshotName.dropFirst("SwiftUI_".count))
        }
        return snapshotName
    }
}

private extension ImageViewSnapshotTests {
    private func recordUIKitSnapshot(
        _ snapshot: UIImage,
        named name: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    private func saveAssertSnapshot(
        _ snapshot: UIImage,
        named name: String,
        context: String
    ) {
        let root = URL(fileURLWithPath: "/Users/ubeishenkulov/Documents/WrapKit/tmp_snapshot_compare/paired_assert", isDirectory: true)
            .appendingPathComponent(context, isDirectory: true)
        let snapshotURL = root.appendingPathComponent("\(name).png")
        guard let snapshotData = snapshot.pngData() else { return }

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData.write(to: snapshotURL)
        } catch {
            // Best-effort helper for local visual comparison.
        }
    }

    private func assertStoredSnapshotEquals(
        _ snapshot: UIImage,
        named name: String,
        precision: Float,
        context: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeReferenceSnapshotURL(named: name, file: file)

        guard
            let storedSnapshotData = try? Data(contentsOf: snapshotURL),
            let oldImage = UIImage(data: storedSnapshotData)
        else {
            if context == "UIKit" {
                recordUIKitSnapshot(snapshot, named: recordedSnapshotName(for: name), file: file, line: line)
                return
            }
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use record mode before asserting.", file: file, line: line)
            return
        }

        guard let diff = Diffing.image(precision: precision).diff(oldImage, snapshot) else { return }

        let normalizedName = normalizedSnapshotName(from: name)
        let uiKitName = recordedSnapshotName(for: normalizedName)
        let currentName = assertSnapshotName(for: normalizedName, context: context)
        let artifactsSubUrl = URL(fileURLWithPath: "/Users/ubeishenkulov/Documents/WrapKit/tmp_snapshot_compare/paired_failures", isDirectory: true)
            .appendingPathComponent(normalizedName)
        try? FileManager.default.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)

        try? storedSnapshotData.write(to: artifactsSubUrl.appendingPathComponent("origin_\(uiKitName).png"))
        try? diff.artifacts.diff.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("diff_\(currentName).png"))
        try? diff.artifacts.image.pngData()?.write(to: artifactsSubUrl.appendingPathComponent("new_\(currentName).png"))

        XCTFail("[\(context)] " + diff.message + "\n Origin: \(uiKitName)\n New: \(currentName)\n Diff snapshot URL: \(artifactsSubUrl)", file: file, line: line)
    }

    private func assertStoredSnapshotDifferent(
        _ snapshot: UIImage,
        named name: String,
        precision: Float,
        context: String,
        file: StaticString,
        line: UInt
    ) {
        let snapshotURL = makeReferenceSnapshotURL(named: name, file: file)

        guard
            let storedSnapshotData = try? Data(contentsOf: snapshotURL),
            let oldImage = UIImage(data: storedSnapshotData)
        else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use record mode before asserting.", file: file, line: line)
            return
        }

        guard Diffing.image(precision: precision).diff(oldImage, snapshot) != nil else {
            XCTFail("[\(context)] Images should be different.", file: file, line: line)
            return
        }
    }

    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    private func makeReferenceSnapshotURL(named name: String, file: StaticString) -> URL {
        for candidate in referenceSnapshotCandidates(for: name) {
            let url = makeSnapshotURL(named: candidate, file: file)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        return makeSnapshotURL(named: normalizedSnapshotName(from: name), file: file)
    }

    private func referenceSnapshotCandidates(for name: String) -> [String] {
        let normalizedName = normalizedSnapshotName(from: name)
        var candidates = [String]()

        func appendUnique(_ value: String) {
            if !candidates.contains(value) {
                candidates.append(value)
            }
        }

        appendUnique(recordedSnapshotName(for: normalizedName))
        appendUnique(normalizedName)

        return candidates
    }
}
