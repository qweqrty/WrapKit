//
//  SelectionFactory.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import UIKit
import WrapKit

public protocol ISelectionFactory {
    func resolveSelection(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow
    ) -> UIViewController
}

public class SelectionFactory: ISelectionFactory {
    public func resolveSelection(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            title: title,
            isMultipleSelectionEnabled: isMultipleSelectionEnabled,
            items: items,
            flow: flow
        )
        let vc = SelectionVC(
            contentView: .init(),
            presenter: presenter
        )
        presenter.view = vc
        return vc
    }
}
