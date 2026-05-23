//
//  SUILabelViewModel.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 5/11/25.
//

#if canImport(Combine)
import Combine
import Dispatch

public final class SUILabelStateModel: ObservableObject {
    @Published var presentable: TextOutputPresentableModel = .text(nil)
    @Published var isHidden: Bool = false
    
    @Published private var adapter: TextOutputSwiftUIAdapter
    private var pendingAnimationCompletion: DispatchWorkItem?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
        adapter.$displayModelState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.cancelPendingAnimationCompletion()
                self.presentable = value.model
                self.isHidden = Self.shouldHide(value.model.model)
            }
            .store(in: &cancellables)
        adapter.$displayTextState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.cancelPendingAnimationCompletion()
                self.presentable = .text(value.text)
                self.isHidden = value.text.isEmpty
            }
            .store(in: &cancellables)
        adapter.$displayAttributesState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.cancelPendingAnimationCompletion()
                self.presentable = .attributes(value.attributes)
                self.isHidden = value.attributes.isEmpty
            }
            .store(in: &cancellables)
        adapter.$displayTextModelState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.cancelPendingAnimationCompletion()
                self.presentable = .init(model: value.textModel)
                self.isHidden = Self.shouldHide(value.textModel)
            }
            .store(in: &cancellables)
        adapter.$displayHtmlStringConfigState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.cancelPendingAnimationCompletion()
                self.presentable = .attributedString(value.htmlString, config: value.config)
                self.isHidden = value.htmlString?.isEmpty ?? true
            }
            .store(in: &cancellables)
        adapter.$displayHtmlStringState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.cancelPendingAnimationCompletion()
                self.presentable = .attributedString(value.htmlString, config: .default)
                self.isHidden = value.htmlString?.isEmpty ?? true
            }
            .store(in: &cancellables)
        adapter.$displayIdStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.cancelPendingAnimationCompletion()
                self.presentable = .animatedDecimal(
                    id: value.id,
                    from: value.startAmount,
                    to: value.endAmount,
                    mapToString: value.mapToString,
                    animationStyle: value.animationStyle,
                    duration: value.duration,
                    completion: nil
                )
                self.isHidden = false

                let completion = value.completion
                let work = DispatchWorkItem { [weak self] in
                    guard let self else { return }
                    self.presentable = .animatedDecimal(
                        id: value.id,
                        from: value.endAmount,
                        to: value.endAmount,
                        mapToString: value.mapToString,
                        animationStyle: value.animationStyle,
                        duration: 0,
                        completion: nil
                    )
                    completion?()
                }
                self.pendingAnimationCompletion = work
                DispatchQueue.main.asyncAfter(deadline: .now() + max(value.duration, 0), execute: work)
            }
            .store(in: &cancellables)
        adapter.$displayIsHiddenState
            .sink { [weak self] value in
                guard let self, let value else { return }
                if value.isHidden {
                    self.cancelPendingAnimationCompletion()
                }
                self.isHidden = value.isHidden
            }
            .store(in: &cancellables)
    }

    deinit {
        cancelPendingAnimationCompletion()
    }

    private func cancelPendingAnimationCompletion() {
        pendingAnimationCompletion?.cancel()
        pendingAnimationCompletion = nil
    }

    private static func shouldHide(_ model: TextOutputPresentableModel.TextModel?) -> Bool {
        guard let model else { return true }

        switch model {
        case .text(let text):
            let normalized = text?.removingPercentEncoding ?? text ?? ""
            return normalized.isEmpty
        case .attributes(let attributes):
            return attributes.isEmpty
        case .attributedString(let htmlString, _):
            return htmlString?.isEmpty ?? true
        case .animatedDecimal, .animated:
            return false
        case .textStyled(let text, _, _, _, _):
            return shouldHide(text)
        }
    }
}

#endif
