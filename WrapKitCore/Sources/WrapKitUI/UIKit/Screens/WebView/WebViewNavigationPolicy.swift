//
//  WebViewNavigationPolicy.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 2/4/25.
//

import Foundation

public enum WebViewNavigationDecision {
    case allow
    case cancelAndOpenExternally
    case cancel
}

public enum WebViewNavigationTrigger {
    case linkActivated
    case other
}

public protocol WebViewNavigationPolicy {
    func decideNavigation(for url: URL, trigger: WebViewNavigationTrigger) -> WebViewNavigationDecision?
}

public struct WebViewNavigationPolicyChain: WebViewNavigationPolicy {
    private let policies: [WebViewNavigationPolicy]

    public init(policies: [WebViewNavigationPolicy]) {
        self.policies = policies
    }
    
    public func decideNavigation(for url: URL, trigger: WebViewNavigationTrigger) -> WebViewNavigationDecision? {
        for policy in policies {
            if let decision = policy.decideNavigation(for: url, trigger: trigger) {
                return decision
            }
        }
        return nil
    }
}
