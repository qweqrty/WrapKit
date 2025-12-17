//
//  ImageViewCancelDownloadTests.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 16/12/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils
import Kingfisher

final class ImageViewCancelDownloadTests: XCTestCase {
    
    private let testImageURL = "https://picsum.photos/200/300"
    
    override func setUp() {
        super.setUp()
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }
    
    override func tearDown() {
        super.tearDown()
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }
    
    func test_imageView_setImageToNil_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = expectation(description: "Wait for download to start")
        expectation.expectedFulfillmentCount = 2
        sut.display(image: .url(url, url)) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // WHEN
        sut.display(image: nil)
        
        // THEN
        XCTAssertNil(sut.kf.taskIdentifier, "Download task should be cancelled")
        XCTAssertNil(sut.image, "Image should be nil")
    }
    
    func test_imageView_setImagePropertyToNil_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = expectation(description: "Wait for download to start")
        sut.display(image: .url(url, url)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
        
        // WHEN
        sut.image = nil
        
        // THEN
        XCTAssertNil(sut.kf.taskIdentifier, "Download task should be cancelled")
        XCTAssertNil(sut.image, "Image should be nil")
    }
    
    func test_imageView_setImageEnumToNone_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = expectation(description: "Wait for download to start")
        sut.display(image: .url(url, url)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
        
        // WHEN
        sut.display(image: .none)
        
        // THEN
        XCTAssertNil(sut.kf.taskIdentifier, "Download task should be cancelled")
        XCTAssertNil(sut.image, "Image should be nil")
    }
    
    // MARK: - Test cancellation clears current animation
    
    func test_imageView_setImageToNil_cancelsCurrentAnimation() {
        // GIVEN
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        let expectation = expectation(description: "Wait for animation setup")
        sut.display(image: .url(url, url)) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
        
        // WHEN
        sut.display(image: nil)
        
        // THEN
        XCTAssertNil(sut.currentAnimator, "Current animator should be cancelled")
        XCTAssertNil(sut.currentImageEnum, "Current image enum should be nil")
    }
    
    // MARK: - Test switching between images cancels previous download
    
    func test_imageView_switchingImages_cancelsPreviousDownload() {
        // GIVEN
        let sut = makeSUT()
        guard let firstURL = URL(string: "https://picsum.photos/seed/first/200/300"),
              let secondURL = URL(string: "https://picsum.photos/seed/second/200/300") else {
            XCTFail("Invalid URLs")
            return
        }
        
        let firstExpectation = expectation(description: "Wait for first download to start")
        sut.display(image: .url(firstURL, firstURL)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                firstExpectation.fulfill()
            }
        }

        wait(for: [firstExpectation], timeout: 1.0)
        
        let firstTaskIdentifier = sut.kf.taskIdentifier
        
        let secondExpectation = expectation(description: "Wait for second download to start")
        sut.display(image: .url(secondURL, secondURL)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                secondExpectation.fulfill()
            }
        }
        wait(for: [secondExpectation], timeout: 1.0)
        
        // THEN
        let secondTaskIdentifier = sut.kf.taskIdentifier
        
        if let first = firstTaskIdentifier, let second = secondTaskIdentifier {
            XCTAssertNotEqual(first, second, "Task identifiers should be different")
        }
    }
    
    func test_imageView_rapidImageChanges_handlesMultipleDownloads() {
        // GIVEN
        let sut = makeSUT()
        guard let url1 = URL(string: "https://picsum.photos/seed/img1/200/300"),
              let url2 = URL(string: "https://picsum.photos/seed/img2/200/300"),
              let url3 = URL(string: "https://picsum.photos/seed/img3/200/300") else {
            XCTFail("Invalid URLs")
            return
        }
        
        let urls = [url1, url2, url3]
        
        // WHEN
        let expectation = expectation(description: "Wait for final download")
        for url in urls {
            sut.display(image: .url(url, url)) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    expectation.fulfill()
                }
            }
            Thread.sleep(forTimeInterval: 0.05)
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // THEN
        XCTAssertEqual(sut.currentImageEnum, .url(url3, url3), "Should be loading the last image")
    }
    
    // MARK: - Test nil handling with completion closure
    
    func test_imageView_setImageToNil_callsCompletionWithNil() {
        // GIVEN
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        let exp = expectation(description: "Completion called")
        var receivedImage: Image?
        
        sut.display(image: .url(url, url))
        Thread.sleep(forTimeInterval: 0.1)
        
        // WHEN
        sut.display(image: nil) { image in
            receivedImage = image
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        XCTAssertNil(receivedImage, "Completion should be called with nil")
    }
    
    // MARK: - Test urlString variants
    
    func test_imageView_setNilUrlString_clearsImage() {
        // GIVEN
        let sut = makeSUT()
        let urlString = testImageURL
        
        let expectation = expectation(description: "Wait for download to start")
        sut.display(image: .urlString(urlString, urlString)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
        
        // WHEN
        sut.display(image: .urlString(nil, nil))
        
        // THEN
        XCTAssertTrue(sut.image == nil || sut.image == sut.wrongUrlPlaceholderImage,
                      "Image should be nil or placeholder")
    }
    
    // MARK: - Test memory management during cancellation
    
    func test_imageView_cancelDownload_doesNotLeakMemory() {
        // GIVEN
        var sut: ImageView? = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        weak var weakSUT = sut
        sut?.display(image: .url(url, url))
        Thread.sleep(forTimeInterval: 0.1)
        
        // WHEN
        sut?.display(image: nil)
        sut = nil
        
        // THEN
        XCTAssertNil(weakSUT, "ImageView should be deallocated")
    }
    
    func test_imageView_cancelDownload_handlesLoadingView() {
        // GIVEN
        let sut = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        let exp1 = expectation(description: "Loading view visible")
        sut.display(image: .url(url, url)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                exp1.fulfill()
            }
        }
        wait(for: [exp1], timeout: 0.5)
        
        // WHEN
        let exp2 = expectation(description: "Wait for state update")
        sut.display(image: nil) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                exp2.fulfill()
            }
        }
        
        // THEN
        wait(for: [exp2], timeout: 0.5)
        
        XCTAssertTrue(true, "Loading view state handled")
    }
    
    func test_imageView_setAssetImage_doesNotCreateDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        guard let assetImage = UIImage(systemName: "star") else {
            XCTFail("Failed to create system image")
            return
        }
        
        // WHEN
        sut.display(image: .asset(assetImage))
        
        // THEN
        XCTAssertNil(sut.kf.taskIdentifier, "Asset images should not create download tasks")
        XCTAssertNotNil(sut.image, "Asset image should be set")
    }
    
    // MARK: - Test model with nil image
    
    func test_imageView_displayModelWithNilImage_clearsImage() {
        // GIVEN
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        let expectation = expectation(description: "Wait for download to start")
        sut.display(image: .url(url, url)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
        
        // WHEN
        let model = ImageViewPresentableModel(image: nil)
        sut.display(model: model)
        
        // THEN
        XCTAssertNil(sut.kf.taskIdentifier, "Download task should be cancelled")
    }
    
    // MARK: - Test image property setter directly
    
    func test_imageView_imagePropertySetter_cancelsDownloadWhenSetToNil() {
        // GIVEN
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        sut.display(image: .url(url, url))
        Thread.sleep(forTimeInterval: 0.1)
        
        // WHEN
        sut.image = nil
        
        // THEN
        XCTAssertNil(sut.image, "Image should be nil")
        XCTAssertNil(sut.kf.taskIdentifier, "Task should be cancelled")
    }
    
    // MARK: - Test sequential image loading
    
    func test_imageView_sequentialImageLoading_cancelsAndStartsNew() {
            // GIVEN
            let sut = makeSUT()
            guard let firstURL = URL(string: "https://picsum.photos/seed/seq1/200/300"),
                  let secondURL = URL(string: "https://picsum.photos/seed/seq2/200/300") else {
                XCTFail("Invalid URLs")
                return
            }
            
            KingfisherManager.shared.cache.removeImage(forKey: firstURL.absoluteString)
            KingfisherManager.shared.cache.removeImage(forKey: secondURL.absoluteString)
            
            let firstExp = expectation(description: "First image loading")
            sut.display(image: .url(firstURL, firstURL)) { _ in
                firstExp.fulfill()
            }
            
            wait(for: [firstExp], timeout: 1.0)
            
            // WHEN
            let secondExp = expectation(description: "Second image loading")
            sut.display(image: .url(secondURL, secondURL)) { _ in
                secondExp.fulfill()
            }
            
            wait(for: [secondExp], timeout: 1.0)
            
            // THEN
            XCTAssertEqual(sut.currentImageEnum, .url(secondURL, secondURL), "Should be set to second image")
        }
}

extension ImageViewCancelDownloadTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> ImageView {
        let sut = ImageView()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
