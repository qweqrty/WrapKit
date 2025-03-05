//
//  HeaderPresentableModel+DefaultWebViewHeader.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

import Foundation

extension HeaderPresentableModel {
    static func defaultWebViewHeader(title: String? = nil, onPress: (() -> Void)? = nil) -> Self {
        let image = Image(named: "icChevronLeft")
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
            leadingCard: .init(
                leadingImage: .init(size: image?.size, image: .asset(image)),
                onPress: onPress
            )
        )
    }
}
