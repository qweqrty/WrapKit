//
//  WebViewPresenter.swift
//  WrapKit
//
//  Created by Stas Lee on 12/1/24.
//

import Foundation

protocol WebViewOutput: AnyObject {
    func display(url: URL)
}

protocol WebViewInput {
    func viewDidLoad()
    func onBackButtonTap()
}

class WebViewPresenter {
    weak var view: WebViewOutput?
    var navigateToBack: (() -> Void)?
    private var url: URL
    
    init(url: URL) {
        self.url = url
    }
}

extension WebViewPresenter: WebViewInput {
    func viewDidLoad() {
        view?.display(url: url)
    }
    
    func onBackButtonTap() {
        navigateToBack?()
    }
}

