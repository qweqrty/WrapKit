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

    var textFieldHeight: CGFloat {
        appearance.font.lineHeight + padding.top + padding.bottom
    }

    private var cancellables: Set<AnyCancellable> = []

    init(
        adapter: SearchBarOutputSwiftUIAdapter,
        appearance: TextfieldAppearance,
        spacing: CGFloat,
        cornerRadius: CGFloat,
        padding: SwiftUI.EdgeInsets
    ) {
        self.appearance = appearance
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.padding = padding

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
            }
            .store(in: &cancellables)

        adapter.$displayLeftViewState
            .sink { [weak self] state in
                guard let state else { return }
                self?.leftView = state.leftView
            }
            .store(in: &cancellables)

        adapter.$displayRightViewState
            .sink { [weak self] state in
                guard let state else { return }
                self?.rightView = state.rightView
            }
            .store(in: &cancellables)

        adapter.$displayPlaceholderState
            .sink { [weak self] state in
                guard let state else { return }
                self?.placeholder = state.placeholder
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
        guard let model else {
            clear()
            return
        }

        textField = model.textField
        isTextFieldHidden = model.textField == nil
        leftView = model.leftView
        rightView = model.rightView
        placeholder = model.placeholder
        if let backgroundColor = model.backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let spacing = model.spacing {
            self.spacing = spacing
        }
    }

    private func clear() {
        textField = nil
        isTextFieldHidden = false
        leftView = nil
        rightView = nil
        placeholder = nil
        backgroundColor = nil
    }
}
#endif
