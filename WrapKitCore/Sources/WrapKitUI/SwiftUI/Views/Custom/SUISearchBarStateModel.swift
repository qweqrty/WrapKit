import Foundation

#if canImport(SwiftUI)
import Combine
import SwiftUI

final class SUISearchBarStateModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var textField: TextInputPresentableModel?
    @Published var leftView: ButtonPresentableModel?
    @Published var rightView: ButtonPresentableModel?
    @Published var placeholder: String?
    @Published var backgroundColor: Color?
    @Published var isTextFieldHidden: Bool = false
    @Published var spacing: CGFloat

    let appearance: TextfieldAppearance
    let cornerRadius: CGFloat
    let padding: SwiftUI.EdgeInsets
    let textFieldAdapter = TextInputOutputSwiftUIAdapter()
    let leftButtonAdapter: ButtonOutputSwiftUIAdapter
    let rightButtonAdapter: ButtonOutputSwiftUIAdapter
    let leftButtonStateModel: SUIButtonStateModel
    let rightButtonStateModel: SUIButtonStateModel

    private var cancellables: Set<AnyCancellable> = []

    init(
        adapter: SearchBarOutputSwiftUIAdapter,
        appearance: TextfieldAppearance,
        spacing: CGFloat,
        cornerRadius: CGFloat,
        padding: SwiftUI.EdgeInsets
    ) {
        let leftButtonAdapter = ButtonOutputSwiftUIAdapter()
        let rightButtonAdapter = ButtonOutputSwiftUIAdapter()

        self.appearance = appearance
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.leftButtonAdapter = leftButtonAdapter
        self.rightButtonAdapter = rightButtonAdapter
        self.leftButtonStateModel = SUIButtonStateModel(adapter: leftButtonAdapter)
        self.rightButtonStateModel = SUIButtonStateModel(adapter: rightButtonAdapter)

        adapter.$displayModelState
            .sink { [weak self] state in
                guard let state else { return }
                self?.apply(model: state.model)
            }
            .store(in: &cancellables)

        adapter.$displayTextFieldState
            .sink { [weak self] state in
                guard let state else { return }
                self?.textField = state.textField
                self?.isTextFieldHidden = state.textField == nil
                self?.textFieldAdapter.display(model: state.textField)
            }
            .store(in: &cancellables)

        adapter.$displayLeftViewState
            .sink { [weak self] state in
                guard let state else { return }
                self?.leftView = state.leftView
                self?.leftButtonAdapter.display(model: state.leftView)
            }
            .store(in: &cancellables)

        adapter.$displayRightViewState
            .sink { [weak self] state in
                guard let state else { return }
                self?.rightView = state.rightView
                self?.rightButtonAdapter.display(model: state.rightView)
            }
            .store(in: &cancellables)

        adapter.$displayPlaceholderState
            .sink { [weak self] state in
                guard let state else { return }
                self?.placeholder = state.placeholder
                self?.textFieldAdapter.display(placeholder: state.placeholder)
            }
            .store(in: &cancellables)

        adapter.$displayBackgroundColorState
            .sink { [weak self] state in
                guard let state else { return }
                if let backgroundColor = state.backgroundColor {
                    self?.backgroundColor = backgroundColor
                }
            }
            .store(in: &cancellables)

        adapter.$displaySpacingState
            .sink { [weak self] state in
                guard let state else { return }
                self?.spacing = state.spacing
            }
            .store(in: &cancellables)
    }

    private func apply(model: SearchBarPresentableModel?) {
        isHidden = model == nil
        guard let model else { return }

        textField = model.textField
        isTextFieldHidden = model.textField == nil
        textFieldAdapter.display(model: model.textField)
        leftView = model.leftView
        leftButtonAdapter.display(model: model.leftView)
        rightView = model.rightView
        rightButtonAdapter.display(model: model.rightView)
        placeholder = model.placeholder
        textFieldAdapter.display(placeholder: model.placeholder)
        if let backgroundColor = model.backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let spacing = model.spacing {
            self.spacing = spacing
        }
    }

}
#endif
