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
    
    func test_alertOutput_showActionSheet() {
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
    
    func test_alertOutput_checkCamerPermissionAndPresentPicker() {
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
    
    func test_viewDidLoad_withMultipleSourceTypes_shouldShowActionSheet() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let alertSpy = components.alertSpy
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        XCTAssertEqual(alertSpy.capturedShowActionSheetModel.count, 1)
        if let model = alertSpy.capturedShowActionSheetModel.first {
            XCTAssertEqual(alertSpy.messages.first, .showActionSheetModel(model: model))
        }
    }
    
    func test_viewDidLoad_withMultipleSourceTypes_actionSheet_shouldHaveCorrectContent() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let alertSpy = components.alertSpy
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        let model = alertSpy.capturedShowActionSheetModel.first
        
        // Verify title
        XCTAssertEqual(model??.title, "Title")
        
        // Verify number of actions (3 sources + cancel)
        XCTAssertEqual(model??.actions.count, 4)
        
        // Verify action titles
        XCTAssertEqual(model??.actions.first?.title, "Camera")
        XCTAssertEqual(model??.actions.dropFirst().first?.title, "Doc")
        XCTAssertEqual(model??.actions.dropFirst(2).first?.title, "Gallery")
        XCTAssertEqual(model??.actions.last?.title, "Cancel")
        
        // Verify cancel button style
        XCTAssertEqual(model??.actions.last?.style, .cancel)
    }
    
    func test_viewDidLoad_withMultipleSourceTypes_cancelAction_shouldCallFinish() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let alertSpy = components.alertSpy
        let flowSpy = components.flowSpy
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        XCTAssertEqual(flowSpy.capturedFinishCallCount, 0)
        
        // Get the cancel action and invoke it
        let cancelAction = alertSpy.capturedShowActionSheetModel.first??.actions.last
        cancelAction?.handler?()
        
        XCTAssertEqual(flowSpy.capturedFinishCallCount, 1)
    }
    
    func test_optionalProperties_shouldNotCrashWhenNil() {
        // GIVEN
        let flow = MediaPickerFlowSpy()
        let galleryConfig = GalleryPickerConfiguration(title: "Gallery")
        
        let mediaPickerLocalizable = MediaPickerLocalizable(
            sourceASTitle: "Title",
            cancel: "Cancel",
            cameraAlertTitle: "AlertTitle",
            cameraAlertText: "AlertText",
            settingsButtonTitle: "Button"
        )
        
        // Test with nil alertView
        let sutAlertView = MediaPickerPresenter(
            flow: flow,
            sourceTypes: [.gallery(galleryConfig)],
            localizable: mediaPickerLocalizable,
            callback: { _ in }
        )
        
        // WHEN - alertView and pickerManager are nil
        sutAlertView.viewDidLoad()
        
        // THEN - should not crash
        XCTAssertNil(sutAlertView.alertView)
        XCTAssertNil(sutAlertView.pickerManager)
        
        // Test with nil callback
        let alertViewSpy = AlertOutputSpy()
        let sutCallback = MediaPickerPresenter(
            flow: flow,
            sourceTypes: [.gallery(galleryConfig)],
            localizable: mediaPickerLocalizable,
            callback: nil
        )
        
        sutCallback.alertView = alertViewSpy
        
        // WHEN
        sutCallback.viewDidLoad()
        
        // THEN - should not crash with nil callback
        XCTAssertEqual(alertViewSpy.capturedShowActionSheetModel.count, 0)
    }
    
    func test_viewDidLoad_withFourSourceTypes_shouldShowActionSheetWithFiveActions() {
        // GIVEN
        let alertViewSpy = AlertOutputSpy()
        let flow = MediaPickerFlowSpy()
        
        let cameraConfig = CameraPickerConfiguration(title: "Camera")
        let galleryConfig = GalleryPickerConfiguration(title: "Gallery")
        let docConfig = DocumentPickerConfiguration(title: "Doc")
        let anotherDocConfig = DocumentPickerConfiguration(title: "Files")
        
        let mediaPickerLocalizable = MediaPickerLocalizable(
            sourceASTitle: "Title",
            cancel: "Cancel",
            cameraAlertTitle: "AlertTitle",
            cameraAlertText: "AlertText",
            settingsButtonTitle: "Button"
        )
        
        let sut = MediaPickerPresenter(
            flow: flow,
            sourceTypes: [.camera(cameraConfig), .gallery(galleryConfig), .file(docConfig), .file(anotherDocConfig)],
            localizable: mediaPickerLocalizable,
            callback: { _ in }
        )
        
        sut.alertView = alertViewSpy
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        XCTAssertEqual(alertViewSpy.capturedShowActionSheetModel.count, 1)
        XCTAssertEqual(alertViewSpy.capturedShowActionSheetModel.first??.actions.count, 5) // 4 sources + cancel
    }
    
    func test_viewDidLoad_multipleCallsShouldShowActionSheetMultipleTimes() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let alertSpy = components.alertSpy
        
        // WHEN
        sut.viewDidLoad()
        sut.viewDidLoad()
        sut.viewDidLoad()
        
        // THEN
        XCTAssertEqual(alertSpy.capturedShowActionSheetModel.count, 3)
    }
    
    func test_actionSheet_allActionsShouldHaveHandlers() {
        // GIVEN
        let components = makeSUT()
        let sut = components.sut
        let alertSpy = components.alertSpy
        
        // WHEN
        sut.viewDidLoad()
        
        // THEN
        let actions = alertSpy.capturedShowActionSheetModel.first??.actions
        XCTAssertNotNil(actions?.first?.handler) // Camera
        XCTAssertNotNil(actions?.dropFirst().first?.handler) // Doc
        XCTAssertNotNil(actions?.dropFirst(2).first?.handler) // Gallery
        XCTAssertNotNil(actions?.last?.handler) // Cancel
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
