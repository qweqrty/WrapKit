//
//  SUIChunkedTextFieldStateModel.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import Combine

public final class SUIChunkedTextFieldStateModel: ObservableObject {
    @Published private(set) var text: String?
    @Published private(set) var isHidden = false
    @Published private(set) var isValid = true
    @Published private(set) var isUserInteractionEnabled = true

    private var didChangeText = [((String?) -> Void)]()
    private let count: Int
    private let adapter: TextInputOutputSwiftUIAdapter
    private var cancellables = Set<AnyCancellable>()

    init(
        count: Int,
        adapter: TextInputOutputSwiftUIAdapter
    ) {
        self.count = count
        self.adapter = adapter
        observeAdapter()
    }

    func character(at index: Int) -> String {
        guard index >= 0 else { return "" }
        let characters = Array((text ?? "").prefix(count))
        guard index < characters.count else { return "" }
        return String(characters[index])
    }

    func updateCharacter(at index: Int, with value: String) {
        guard index >= 0, index < count else { return }

        var characters = (text ?? "").map(String.init)
        if characters.count < count {
            characters.append(contentsOf: Array(repeating: "", count: count - characters.count))
        }

        let filteredValue = value.filter { $0.isWholeNumber }
        characters[index] = String(filteredValue.suffix(1))
        text = characters.joined().isEmpty ? nil : characters.joined()
        didChangeText.forEach { $0(text) }
    }
}

private extension SUIChunkedTextFieldStateModel {
    func observeAdapter() {
        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.apply(model: state.model)
            }
            .store(in: &cancellables)

        adapter.$displayTextState
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.text = self?.normalizedText(state.text)
            }
            .store(in: &cancellables)

        adapter.$displayIsValidState
            .compactMap { $0?.isValid }
            .sink { [weak self] isValid in
                self?.isValid = isValid
            }
            .store(in: &cancellables)

        adapter.$displayIsUserInteractionEnabledState
            .compactMap { $0?.isUserInteractionEnabled }
            .sink { [weak self] isUserInteractionEnabled in
                self?.isUserInteractionEnabled = isUserInteractionEnabled
            }
            .store(in: &cancellables)

        adapter.$displayIsHiddenState
            .compactMap { $0?.isHidden }
            .sink { [weak self] isHidden in
                self?.isHidden = isHidden
            }
            .store(in: &cancellables)

        adapter.$displayDidChangeTextState
            .compactMap { $0?.didChangeText }
            .sink { [weak self] didChangeText in
                self?.didChangeText = didChangeText
            }
            .store(in: &cancellables)
    }

    func apply(model: TextInputPresentableModel?) {
        isHidden = model == nil
        guard let model else { return }

        text = normalizedText(model.text)
        if let isValid = model.isValid {
            self.isValid = isValid
        }
        if let isUserInteractionEnabled = model.isUserInteractionEnabled {
            self.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }

    func normalizedText(_ text: String?) -> String? {
        guard let text, !text.isEmpty else { return nil }
        return String(text.prefix(count))
    }
}

#endif
