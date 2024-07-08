//
//  WebViewVC.swift
//  WrapKit
//
//  Created by Stas Lee on 12/1/24.
//

#if canImport(UIKit)
import Foundation
import UIKit

open class WebViewVC: ViewController<WebViewContentView> {
    private let presenter: WebViewInput
    
    public init(contentView: WebViewContentView, presenter: WebViewInput) {
        self.presenter = presenter
        super.init(contentView: contentView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    public func setupUI() {
        contentView.navigationBar.leadingCardView.onPress = presenter.onBackButtonTap
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WebViewVC: WebViewOutput {
    public func display(url: URL) {
        contentView.webView.load(URLRequest(url: url))
    }
    
    
}
#endif
