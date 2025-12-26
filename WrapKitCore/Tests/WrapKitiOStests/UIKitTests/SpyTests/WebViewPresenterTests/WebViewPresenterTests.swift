////
////  WebViewPresenterTests.swift
////  WrapKit
////
////  Created by Urmatbek Marat Uulu on 25/12/25.

import WrapKit
import XCTest
import WrapKitTestUtils

final class WebViewPresenterTests: XCTestCase {
    
    let url = URL(string: "https://o.kg/kg/chastnym-klientam/")!
    let image = Image(systemName: "star.fill")
    
    func test_webViewOutput_displayRefreshModel() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.webViewSpy
        
        sut.viewDidLoad()
        
        XCTAssertEqual(viewSpy.capturedDisplayRefreshModel[0], .init(isEnabled: false))
        XCTAssertEqual(viewSpy.messages[0], .displayRefreshModel(refreshModel: .init(isEnabled: false)))
    }
    
    func test_webViewOutput_displayURL() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.webViewSpy
        
        sut.viewDidLoad()
        
        XCTAssertEqual(viewSpy.messages[2], .displayUrl(url: url))
        XCTAssertEqual(viewSpy.capturedDisplayUrl[0], url)
    }
    
    func test_webViewOutput_display_isProgressBarNeeded() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.webViewSpy
        
        sut.viewDidLoad()
        
        XCTAssertEqual(viewSpy.messages[1], .displayIsProgressBarNeeded(isProgressBarNeeded: true))
        XCTAssertEqual(viewSpy.capturedDisplayIsProgressBarNeeded[0], true)
    }
    
    func test_webViewOutput_display_backgroundColor() {
        let components = makeSUT()
        let sut = components.sut
        let viewSpy = components.webViewSpy
        
        sut.viewDidLoad()
        
        XCTAssertEqual(viewSpy.messages[3], .displayBackgroundColor(backgroundColor: .red))
        XCTAssertEqual(viewSpy.capturedDisplayBackgroundColor[0], .red)
    }
    
    func test_progressBarOutput_display_model() {
        let components = makeSUT()
        let sut = components.sut
        let progressBarSpy = components.progressBarSpy
        
        sut.viewDidLoad()
        
        let progressBarStyle = ProgressBarStyle(
            backgroundColor: .cyan
        )
        
        let progressBarModel = ProgressBarPresentableModel(
            progress: 50.0, style: progressBarStyle
        )
        
        XCTAssertEqual(progressBarSpy.messages[0], .displayModel(model: progressBarModel))
    }
    
    func test_headerOutput_display_modelDefault() {
        let components = makeSUT()
        let sut = components.sut
        let headerSpy = components.headerSpy
        
        sut.viewDidLoad()
        
        var capturedId: String = UUID().uuidString
        
        if case .keyValue(let pair) = headerSpy.capturedDisplayModel.first??.centerView,
           case .attributes(let attributes) = pair.first,
           let firstAttribute = attributes.first {
            capturedId = firstAttribute.id
        }
        
        let headerModel = HeaderPresentableModel(
            centerView: .keyValue(
                .init(
                    .attributes(
                        [.init(
                            id: capturedId,
                            text: "Style",
                            font: .systemFont(ofSize: 18, weight: .semibold)
                        )]
                    ),
                    nil
                )
            ),
            leadingCard: .init(
                id: headerSpy.capturedDisplayModel.first??.leadingCard?.id ?? "",
                leadingImage: .init(size: nil, image: .asset(image)),
                onPress: headerSpy.capturedDisplayModel.first??.leadingCard?.onPress ?? { }
            )
        )
                
        XCTAssertEqual(headerSpy.messages[0], .displayModel(model: headerModel))
        XCTAssertEqual(headerSpy.capturedDisplayModel[0], headerModel)
    }
    
    func test_headerOutput_display_modelCustom() {
        let customHeaderModel = HeaderPresentableModel(
            centerView: .keyValue(.init(.attributes([.init(text: "Custom Title")]), nil)),
            leadingCard: .init(title: .text("Close"))
        )
        
        let components = makeSUT(headerStyle: .custom(customHeaderModel))
        let sut = components.sut
        let headerSpy = components.headerSpy
        
        sut.viewDidLoad()
        
        XCTAssertEqual(headerSpy.messages[0], .displayModel(model: customHeaderModel))
        XCTAssertEqual(headerSpy.capturedDisplayModel[0], customHeaderModel)
    }
    
    func test_headerOutput_display_modelHidden() {
        let components = makeSUT(headerStyle: .hidden)
        let sut = components.sut
        let headerSpy = components.headerSpy
        
        sut.viewDidLoad()
        
        XCTAssertEqual(headerSpy.messages[0], .displayModel(model: nil))
        XCTAssertEqual(headerSpy.capturedDisplayModel[0], nil)
    }
    
    func test_decideNavigation_returnsDecisionFromPolicy() {
        let policySpy = WebViewNavigationPolicySpy()
        let components = makeSUT(navigationPolicy: policySpy)
        
        policySpy.decisionToReturn = .cancel
        
        let decision = components.sut.decideNavigation(for: url, trigger: .linkActivated)
        
        XCTAssertEqual(decision, .cancel)
        XCTAssertEqual(policySpy.capturedDecisions.first?.url, url)
        XCTAssertEqual(policySpy.capturedDecisions.first?.trigger, .linkActivated)
    }
    
    func test_decideNavigation_returnsAllowWhenPolicyIsNil() {
        let components = makeSUT(navigationPolicy: nil)

        let decision = components.sut.decideNavigation(for: url, trigger: .linkActivated)
        
        XCTAssertEqual(decision, .allow)
    }
}

fileprivate extension WebViewPresenterTests {
    struct SUTComponents {
        let sut: WebViewPresenter
        let webViewSpy: WebViewOutputSpy
        let headerSpy: HeaderOutputSpy
        let progressBarSpy: ProgressBarOutputSpy
        let refreshControlSpy: LoadingOutputSpy
        let flowSpy: WebViewFlowSpy
    }
    
    func makeSUT(
        headerStyle: WebViewStyle.Header? = nil,
        navigationPolicy: WebViewNavigationPolicy? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUTComponents {
        let viewSpy = WebViewOutputSpy()
        let headerSpy = HeaderOutputSpy()
        let progressBarSpy = ProgressBarOutputSpy()
        let refreshControlSpy = LoadingOutputSpy()
        let flow = WebViewFlowSpy()
        
        let progressBarStyle = ProgressBarStyle(
            backgroundColor: .cyan
        )
        
        let progressBarModel = ProgressBarPresentableModel(progress: 50.0 ,style: progressBarStyle)
        
        let style = WebViewStyle(
            title: "Style",
            header: headerStyle,
            progressBarModel: progressBarModel,
            backgroundColor: .red,
            leadingCard: .init(
                id: headerSpy.capturedDisplayModel.first??.leadingCard?.id ?? "",
                leadingImage: .init(size: nil, image: .asset(image)),
                onPress: headerSpy.capturedDisplayModel.first??.leadingCard?.onPress ?? { }
            )
        )
        
        let sut = WebViewPresenter(url: url, flow: flow, style: style, navigationPolicy: navigationPolicy)
        
        sut.view = viewSpy
        sut.navBarView = headerSpy
        sut.progressBarView = progressBarSpy
        sut.refreshControlView = refreshControlSpy
        
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(viewSpy, file: file, line: line)
        checkForMemoryLeaks(headerSpy, file: file, line: line)
        checkForMemoryLeaks(progressBarSpy, file: file, line: line)
        checkForMemoryLeaks(refreshControlSpy, file: file, line: line)
        return SUTComponents(
            sut: sut,
            webViewSpy: viewSpy,
            headerSpy: headerSpy,
            progressBarSpy: progressBarSpy,
            refreshControlSpy: refreshControlSpy,
            flowSpy: flow
        )
    }
}

private final class WebViewNavigationPolicySpy: WebViewNavigationPolicy {
    
    var capturedDecisions: [(url: URL, trigger: WebViewNavigationTrigger)] = []
    var decisionToReturn: WebViewNavigationDecision = .allow
    
    func decideNavigation(for url: URL, trigger: WrapKit.WebViewNavigationTrigger) -> WrapKit.WebViewNavigationDecision? {
        capturedDecisions.append((url, trigger))
        return decisionToReturn
    }
}
