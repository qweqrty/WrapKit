import XCTest
import Foundation
import WrapKit

final class ImageViewPresentableModelTests: XCTestCase {
    
    func test_ImageViewPresentableModel_fixedLayout() {
        let size = CGSize(width: 24, height: 32)
        
        let sut = ImageViewPresentableModel(layout: .fixed(size))
        
        XCTAssertEqual(sut.layout, .fixed(size))
        XCTAssertEqual(sut.size, size)
        XCTAssertNil(sut.stretchToContainerWidth)
        XCTAssertNil(sut.heightByWidthRatio)
    }
    
    func test_ImageViewPresentableModel_fillWidthLayout() {
        let ratio: CGFloat = 0.29
        
        let sut = ImageViewPresentableModel(layout: .fillWidth(heightByWidthRatio: ratio))
        
        XCTAssertEqual(sut.layout, .fillWidth(heightByWidthRatio: ratio))
        XCTAssertNil(sut.size)
        XCTAssertEqual(sut.stretchToContainerWidth, true)
        XCTAssertEqual(sut.heightByWidthRatio, ratio)
    }
    
    func test_ImageViewPresentableModel_sizeInitializerUsesFixedLayout() {
        let size = CGSize(width: 32, height: 32)
        
        let sut = ImageViewPresentableModel(size: size)
        
        XCTAssertEqual(sut.layout, .fixed(size))
        XCTAssertEqual(sut.size, size)
        XCTAssertNil(sut.stretchToContainerWidth)
        XCTAssertNil(sut.heightByWidthRatio)
    }
}
