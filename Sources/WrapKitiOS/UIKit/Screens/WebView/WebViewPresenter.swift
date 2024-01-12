//
//  WebViewPresenter.swift
//  WrapKit
//
//  Created by Stas Lee on 12/1/24.
//

import Foundation

public protocol WebViewOutput: AnyObject {
    func display(url: URL)
}

public protocol WebViewInput {
    func viewDidLoad()
    func onBackButtonTap()
}

open class WebViewPresenter {
    weak var view: WebViewOutput?
    var navigateToBack: (() -> Void)?
    private var url: URL
    
    init(url: URL) {
        self.url = url
    }
}

extension WebViewPresenter: WebViewInput {
    public func viewDidLoad() {
        view?.display(url: url)
    }
    
    public func onBackButtonTap() {
        navigateToBack?()
    }
}

