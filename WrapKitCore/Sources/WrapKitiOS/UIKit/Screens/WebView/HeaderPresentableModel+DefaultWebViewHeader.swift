//
//  HeaderPresentableModel+DefaultWebViewHeader.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

import Foundation

extension HeaderPresentableModel {
    static func defaultWebViewHeader(title: String? = nil, onPress: (() -> Void)? = nil) -> Self {
        .init(
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
            leadingCard: .init(
                leadingImage: .init(image: .asset(Image(named: "icChevronLeft"))),
                onPress: onPress
            )
        )
    }
}
