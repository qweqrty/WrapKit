//
//  EmptyViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 14/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class EmptyViewSnapshotTests: XCTestCase {
    func test_emptyView_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: .text("Empty view"))
        sut.backgroundColor = .cyan
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EMPTYVIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EMPTYVIEW_DEFAULT_STATE_DARK")
    }
    
    func test_emptyView_with_subTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.backgroundColor = .cyan
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EMPTYVIEW_WITH_SUBTITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EMPTYVIEW_WITH_SUBTITLE_DARK")
    }
    
    func test_emptyView_with_Button() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        let image = Image(systemName: "star.fill")
        let buttonStyle = ButtonStyle(
            backgroundColor: .systemBlue,
            titleColor: .black,
            borderWidth: 2,
            borderColor: .red,
            pressedColor: .green,
            pressedTintColor: .yellow,
            font: .systemFont(ofSize: 22),
            cornerRadius: 5,
            wrongUrlPlaceholderImage: image)
        
        let buttonModel = ButtonPresentableModel(
            title: "Button",
            image: image,
            spacing: 2,
            height: 40,
            style: buttonStyle,
            enabled: true,
        )
        
        // WHEN
        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(buttonModel: buttonModel)
        sut.backgroundColor = .cyan
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EMPTYVIEW_WITH_BUTTON_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EMPTYVIEW_WITH_BUTTON_DARK")
    }
    
    func test_emptyView_with_Image() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        let image = Image(systemName: "star.fill")
        let imageModel = ImageViewPresentableModel(image: .asset(image))
        // WHEN
        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(image: imageModel)
        sut.backgroundColor = .cyan
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EMPTYVIEW_WITH_IMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EMPTYVIEW_WITH_IMAGE_DARK")
    }
    
    func test_emptyView_with_hidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.backgroundColor = .cyan
        sut.display(isHidden: true)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EMPTYVIEW_WITH_HIDDEN_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EMPTYVIEW_WITH_HIDDEN_DARK")
    }
    
    func test_emptyView_with_model() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        let image = Image(systemName: "star.fill")
        let imageModel = ImageViewPresentableModel(image: .asset(image))
        
        let buttonStyle = ButtonStyle(
            backgroundColor: .systemBlue,
            titleColor: .black,
            borderWidth: 2,
            borderColor: .red,
            pressedColor: .green,
            pressedTintColor: .yellow,
            font: .systemFont(ofSize: 22),
            cornerRadius: 5,
            wrongUrlPlaceholderImage: image)
        
        let buttonModel = ButtonPresentableModel(
            title: "Button",
            image: image,
            spacing: 2,
            height: 40,
            style: buttonStyle,
            enabled: true,
        )
        
        // WHEN
        sut.backgroundColor = .cyan
        
        let model = EmptyViewPresentableModel(
            title: .text("Title"),
            subTitle: .text("Subtitle"),
            button: buttonModel,
            image: imageModel,
            animationConfig: .default
        )
        
        sut.display(model: model)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "EMPTYVIEW_WITH_MODEL_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "EMPTYVIEW_WITH_MODEL_DARK")
    }
}

extension EmptyViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: EmptyView, container: UIView) {
        
        let sut = EmptyView()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
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
