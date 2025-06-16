//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation

#if canImport(UIKit)
import UIKit

#if targetEnvironment(simulator)
public class SimulatedCameraPresenter: NSObject {
    
    private lazy var fakeImage = {
        /// Generate a fake image
        let size = CGSize(width: 800, height: 600)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let text = "Simulated Photo"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 36)
            ]
            let textSize = text.size(withAttributes: attributes)
            let textPoint = CGPoint(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2
            )
            text.draw(at: textPoint, withAttributes: attributes)
        }
        return image
    }()
    
    public var shutterButton: ButtonOutput?
    public var cancelButton: ButtonOutput?
    
    private let onCapture: ((UIImage?) -> Void)?
    
    public init(onCapture: ((UIImage?) -> Void)?) {
        self.onCapture = onCapture
    }
}

extension SimulatedCameraPresenter: LifeCycleViewOutput {
    public func viewDidLoad() {
        
        shutterButton?.display { [weak self] in
            guard let self else { return }
            onCapture?(fakeImage)
        }
        
        cancelButton?.display { [weak self] in
            self?.onCapture?(nil)
        }
    }
}

extension SimulatedCameraPresenter: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onCapture?(nil)
    }
}
#endif
#endif
