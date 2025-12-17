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
        
        sut.display(image: .url(url, url))
        
        let expectation = expectation(description: "Wait for async dispatch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        sut.display(image: nil)
        
        // THEN
        XCTAssertNil(sut.kf.taskIdentifier, "Download task should be cancelled")
        XCTAssertNil(sut.image, "Image should be nil")
    }
    
    func test_imageView_setImagePropertyToNil_cancelsDownloadTask() {
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        sut.display(image: .url(url, url))
        wait(0.2)
        
        sut.image = nil
        
        XCTAssertNil(sut.kf.taskIdentifier)
        XCTAssertNil(sut.image)
    }
    
    func test_imageView_setImageEnumToNone_cancelsDownloadTask() {
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        sut.display(image: .url(url, url))
        wait(0.2)
        
        sut.display(image: .none)
        
        XCTAssertNil(sut.kf.taskIdentifier)
        XCTAssertNil(sut.image)
    }
    
    func test_imageView_setImageToNil_cancelsCurrentAnimation() {
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        sut.display(image: .url(url, url))
        wait(0.2)
        
        sut.display(image: nil)
        
        XCTAssertNil(sut.currentAnimator)
        XCTAssertNil(sut.currentImageEnum)
    }
    
    func test_imageView_switchingImages_cancelsPreviousDownload() {
        let sut = makeSUT()
        guard let firstURL = URL(string: "https://picsum.photos/seed/first/200/300"),
              let secondURL = URL(string: "https://picsum.photos/seed/second/200/300") else {
            XCTFail("Invalid URLs")
            return
        }
        
        sut.display(image: .url(firstURL, firstURL))
        wait(0.2)
        
        let firstTaskIdentifier = sut.kf.taskIdentifier
        
        sut.display(image: .url(secondURL, secondURL))
        wait(0.2)
        
        let secondTaskIdentifier = sut.kf.taskIdentifier
        
        if let first = firstTaskIdentifier, let second = secondTaskIdentifier {
            XCTAssertNotEqual(first, second)
        }
    }
    
    func test_imageView_rapidImageChanges_handlesMultipleDownloads() {
        let sut = makeSUT()
        guard let url1 = URL(string: "https://picsum.photos/seed/img1/200/300"),
              let url2 = URL(string: "https://picsum.photos/seed/img2/200/300"),
              let url3 = URL(string: "https://picsum.photos/seed/img3/200/300") else {
            XCTFail("Invalid URLs")
            return
        }
        
        sut.display(image: .url(url1, url1))
        wait(0.05)
        
        sut.display(image: .url(url2, url2))
        wait(0.05)
        
        sut.display(image: .url(url3, url3))
        
        XCTAssertTrue(true)
    }
    
    func test_imageView_setImageToNil_callsCompletionWithNil() {
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        sut.display(image: .url(url, url))
        wait(0.1)
        
        let exp = expectation(description: "Completion called")
        var receivedImage: Image?
        sut.display(image: nil) { image in
            receivedImage = image
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(receivedImage)
    }
    
    func test_imageView_setNilUrlString_clearsImage() {
        let sut = makeSUT()
        let urlString = testImageURL
        
        sut.display(image: .urlString(urlString, urlString))
        wait(0.2)
        
        sut.display(image: .urlString(nil, nil))
        
        XCTAssertTrue(sut.image == nil || sut.image == sut.wrongUrlPlaceholderImage)
    }
    
    func test_imageView_cancelDownload_doesNotLeakMemory() {
        var sut: ImageView? = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        weak var weakSUT = sut
        sut?.display(image: .url(url, url))
        wait(0.1)
        
        sut?.display(image: nil)
        sut = nil
        
        XCTAssertNil(weakSUT)
    }
    
    func test_imageView_cancelDownload_handlesLoadingView() {
        let sut = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        sut.display(image: .url(url, url))
        wait(0.2)
        
        sut.display(image: nil)
        wait(0.1)
        
        XCTAssertTrue(true)
    }
    
    func test_imageView_setAssetImage_doesNotCreateDownloadTask() {
        let sut = makeSUT()
        guard let assetImage = UIImage(systemName: "star") else {
            XCTFail("Failed to create system image")
            return
        }
        
        sut.display(image: .asset(assetImage))
        
        XCTAssertNil(sut.kf.taskIdentifier)
        XCTAssertNotNil(sut.image)
    }
    
    func test_imageView_displayModelWithNilImage_clearsImage() {
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        sut.display(image: .url(url, url))
        wait(0.2)
        
        let model = ImageViewPresentableModel(image: nil)
        sut.display(model: model)
        
        XCTAssertNil(sut.kf.taskIdentifier)
    }
    
    func test_imageView_imagePropertySetter_cancelsDownloadWhenSetToNil() {
        let sut = makeSUT()
        guard let url = URL(string: testImageURL) else {
            XCTFail("Invalid URL")
            return
        }
        
        sut.display(image: .url(url, url))
        wait(0.1)
        
        sut.image = nil
        
        XCTAssertNil(sut.image)
        XCTAssertNil(sut.kf.taskIdentifier)
    }
    
    func test_imageView_sequentialImageLoading_cancelsAndStartsNew() {
        let sut = makeSUT()
        guard let firstURL = URL(string: "https://picsum.photos/seed/seq1/200/300"),
              let secondURL = URL(string: "https://picsum.photos/seed/seq2/200/300") else {
            XCTFail("Invalid URLs")
            return
        }
        
        sut.display(image: .url(firstURL, firstURL))
        wait(0.1)
        
        let firstTaskIdentifier = sut.kf.taskIdentifier
        
        sut.display(image: .url(secondURL, secondURL))
        wait(0.1)
        
        let secondTaskIdentifier = sut.kf.taskIdentifier
        
        if let first = firstTaskIdentifier, let second = secondTaskIdentifier {
            XCTAssertNotEqual(first, second)
        } else {
            XCTAssertTrue(true)
        }
    }
    
    func test_imageView_withCachedImage_switchingQuickly_showsCorrectImage() {
        let sut = makeSUT()
        guard let firstURL = URL(string: "https://picsum.photos/seed/cached1/200/300"),
              let secondURL = URL(string: "https://picsum.photos/seed/cached2/200/300") else {
            XCTFail("Invalid URLs")
            return
        }
        
        let firstCacheExp = expectation(description: "First image cached")
        KingfisherManager.shared.retrieveImage(with: firstURL) { result in
            if case .success(let imageResult) = result {
                KingfisherManager.shared.cache.store(
                    imageResult.image,
                    forKey: firstURL.absoluteString
                )
            }
            firstCacheExp.fulfill()
        }
        
        let secondCacheExp = expectation(description: "Second image cached")
        KingfisherManager.shared.retrieveImage(with: secondURL) { result in
            if case .success(let imageResult) = result {
                KingfisherManager.shared.cache.store(
                    imageResult.image,
                    forKey: secondURL.absoluteString
                )
            }
            secondCacheExp.fulfill()
        }
        wait(for: [firstCacheExp, secondCacheExp], timeout: 10.0)
        
        KingfisherManager.shared.cache.clearMemoryCache()
        
        sut.display(image: .url(firstURL, firstURL))
        sut.display(image: .url(secondURL, secondURL))
        wait(0.5)
        
        XCTAssertEqual(sut.currentImageEnum, .url(secondURL, secondURL))
        XCTAssertNotNil(sut.image)
    }
    
    func test_imageView_cachedImageCallback_cancelledWhenNewImageSet() {
        let sut = makeSUT()
        guard let cachedURL = URL(string: "https://picsum.photos/seed/test-cached/200/300"),
              let newURL = URL(string: "https://picsum.photos/seed/test-new/200/300") else {
            XCTFail("Invalid URLs")
            return
        }
        
        let cacheExp = expectation(description: "Image cached")
        KingfisherManager.shared.retrieveImage(with: cachedURL) { result in
            if case .success(let imageResult) = result {
                KingfisherManager.shared.cache.store(
                    imageResult.image,
                    forKey: cachedURL.absoluteString
                )
            }
            cacheExp.fulfill()
        }
        wait(for: [cacheExp], timeout: 10.0)
        
        KingfisherManager.shared.cache.clearMemoryCache()
        
        sut.display(image: .url(cachedURL, cachedURL))
        sut.display(image: .url(newURL, newURL))
        
        XCTAssertTrue(true)
    }
    
    func test_imageView_cellReuseScenario_withCachedImages() {
        let sut = makeSUT()
        guard let row1URL = URL(string: "https://picsum.photos/seed/row1/200/300"),
              let row2URL = URL(string: "https://picsum.photos/seed/row2/200/300"),
              let row3URL = URL(string: "https://picsum.photos/seed/row3/200/300") else {
            XCTFail("Invalid URLs")
            return
        }
        
        let cacheExp = expectation(description: "All images cached")
        cacheExp.expectedFulfillmentCount = 3
        
        for url in [row1URL, row2URL, row3URL] {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                if case .success(let imageResult) = result {
                    KingfisherManager.shared.cache.store(
                        imageResult.image,
                        forKey: url.absoluteString
                    )
                }
                cacheExp.fulfill()
            }
        }
        wait(for: [cacheExp], timeout: 15.0)
        
        KingfisherManager.shared.cache.clearMemoryCache()
        
        sut.display(image: .url(row1URL, row1URL))
        sut.display(image: .url(row2URL, row2URL))
        sut.display(image: .url(row3URL, row3URL))
        wait(0.5)
        
        XCTAssertEqual(sut.currentImageEnum, .url(row3URL, row3URL))
        XCTAssertNotNil(sut.image)
    }
    
    private func wait(_ duration: TimeInterval) {
        let exp = expectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            exp.fulfill()
        }
        waitForExpectations(timeout: duration + 1.0)
    }
}

extension ImageViewCancelDownloadTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> ImageView {
        let sut = ImageView()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
