//
//  SelectionFactory.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

public protocol ISelectionFactory<Controller> {
    associatedtype Controller
    
    func resolveSelection(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration
    ) -> Controller
}

#if canImport(UIKit)
#if canImport(BottomSheet)
#if canImport(BottomSheetUtils)
import UIKit

public class SelectionFactoryiOS: ISelectionFactory {
    public func resolveSelection(
        title: String?,
        isMultipleSelectionEnabled: Bool,
        items: [SelectionType.SelectionCellPresentableModel],
        flow: SelectionFlow,
        configuration: SelectionConfiguration
    ) -> UIViewController {
        let presenter = SelectionPresenter(
            title: title,
            isMultipleSelectionEnabled: isMultipleSelectionEnabled,
            items: items,
            flow: flow.mainQueueDispatched,
            configuration: configuration
        )
        let vc = SelectionVC(
            contentView: .init(config: configuration),
            presenter: presenter
        )
        presenter.view = vc
            .weakReferenced
            .mainQueueDispatched
        
        return vc
    }
    
    public init() {}
}
#endif
#endif
#endif
