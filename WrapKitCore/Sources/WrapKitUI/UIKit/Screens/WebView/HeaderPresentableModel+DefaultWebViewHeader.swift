//
//  HeaderPresentableModel+DefaultWebViewHeader.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

import Foundation

extension HeaderPresentableModel {
    static func defaultWebViewHeader(
        title: String? = nil,
        leadingCard: CardViewPresentableModel
    ) -> Self {
        return .init(
            centerView: .keyValue(
                .init(
                    .attributes(
                        [.init(
                            text: title ?? "",
                            font: .systemFont(ofSize: 18, weight: .semibold)
                        )]
                    ),
                    nil
                )
            ),
            leadingCard: leadingCard
        )
    }
}
