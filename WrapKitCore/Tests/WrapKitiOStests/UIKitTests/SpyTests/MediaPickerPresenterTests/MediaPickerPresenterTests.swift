//
//  MediaPickerPresenterTests.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 26/12/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils
import Combine

final class MediaPickerPresenterTests: XCTestCase {
    
    func test() {
        let components = makeSUT()
        let sut = components.sut
        let alertSpy = components.alertSpy
        
        sut.viewDidLoad()
        
        let actions: [AlertAction] = [
            .init(title: "Camera", handler: { }),
            .init(title: "Doc", handler: { }),
            .init(title: "Gallery", handler: { }),
            .init(title: "Cancel", style: .cancel, handler: { })
        ]
        
        let model = AlertPresentableModel(
            title: "Title",
            actions: actions,
        )
        
        XCTAssertEqual(alertSpy.messages[0], .showActionSheetModel(model: model))
    }
    
}

extension MediaPickerPresenterTests {
    
    struct SUTComponents {
        let sut: MediaPickerPresenter
        let flowSpy: MediaPickerFlowSpy
        let alertSpy: AlertOutputSpy
    }
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUTComponents {
        let alertViewSpy = AlertOutputSpy()
        
        let flow = MediaPickerFlowSpy()
        
        let cameraConfig = CameraPickerConfiguration(title: "Camera")
        let docConfig = DocumentPickerConfiguration(title: "Doc")
        let galleryConfig = GalleryPickerConfiguration(title: "Gallery")
        
        let sourceType: [MediaPickerSource] = [.camera(cameraConfig), .file(docConfig), .gallery(galleryConfig)]
        
        let mediaPickerLocalizable = MediaPickerLocalizable(
            sourceASTitle: "Title",
            cancel: "Cancel",
            cameraAlertTitle: "AlertTitle",
            cameraAlertText: "AlertText",
            settingsButtonTitle: "Button")
        
        let sut = MediaPickerPresenter(
            flow: flow,
            sourceTypes: sourceType,
            localizable: mediaPickerLocalizable,
            callback: {_ in } )
        
        sut.alertView = alertViewSpy
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(alertViewSpy, file: file, line: line)
        return SUTComponents(sut: sut, flowSpy: flow, alertSpy: alertViewSpy)
    }
}
