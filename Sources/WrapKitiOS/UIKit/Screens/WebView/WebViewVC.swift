//
//  WebViewVC.swift
//  WrapKit
//
//  Created by Stas Lee on 12/1/24.
//

#if canImport(UIKit)
import Foundation
import UIKit

class WebViewVC: ViewController<WebViewContentView> {
    private let presenter: WebViewInput
    
    init(contentView: WebViewContentView, presenter: WebViewInput) {
        self.presenter = presenter
        super.init(contentView: contentView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    func setupUI() {
        contentView.closeButton.onPress = presenter.onBackButtonTap
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WebViewVC: WebViewOutput {
    func display(url: URL) {
        contentView.webView.load(URLRequest(url: url))
    }
    
    
}
#endif
