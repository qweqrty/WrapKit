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
public class SimulatedCameraViewController: ViewController<SimulatedCameraContentView> {
    
    private let onCapture: ((UIImage?) -> Void)?
    
    init(contentView: SimulatedCameraContentView, onCapture: ((UIImage?) -> Void)?) {
        self.onCapture = onCapture
        super.init(contentView: contentView)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        presentationController?.delegate = self
        
        contentView.shutterButton.display { [weak self] in
            guard let self else { return }
            onCapture?(contentView.fakeImage)
        }
        
        contentView.cancelButton.display { [weak self] in
            self?.onCapture?(nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SimulatedCameraViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onCapture?(nil)
    }
}
#endif
#endif
