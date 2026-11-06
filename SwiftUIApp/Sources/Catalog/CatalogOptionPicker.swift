import SwiftUI

// The Selection screen moved to DesignSystem (MYO-7397), so catalog scenes pick
// their presets with a plain SwiftUI confirmation dialog instead of SelectionFlow.

struct CatalogOption: Identifiable {
    let id: String
    let title: String
    let isSelected: Bool
}

protocol CatalogOptionPicking: AnyObject {
    func pickOption(
        title: String,
        options: [CatalogOption],
        onSelect: @escaping (String) -> Void
    )
}

final class CatalogOptionPicker: ObservableObject, CatalogOptionPicking {
    struct Request {
        let title: String
        let options: [CatalogOption]
        let onSelect: (String) -> Void
    }

    @Published var request: Request?

    func pickOption(
        title: String,
        options: [CatalogOption],
        onSelect: @escaping (String) -> Void
    ) {
        request = Request(title: title, options: options, onSelect: onSelect)
    }
}

struct CatalogOptionPickerHost<Content: View>: View {
    @ObservedObject private var picker: CatalogOptionPicker
    private let content: Content

    init(picker: CatalogOptionPicker, @ViewBuilder content: () -> Content) {
        self.picker = picker
        self.content = content()
    }

    var body: some View {
        content.confirmationDialog(
            picker.request?.title ?? "",
            isPresented: isPresented,
            titleVisibility: .visible,
            presenting: picker.request
        ) { request in
            ForEach(request.options) { option in
                Button(option.isSelected ? "✓ \(option.title)" : option.title) {
                    request.onSelect(option.id)
                }
            }
        }
    }

    private var isPresented: Binding<Bool> {
        Binding(
            get: { picker.request != nil },
            set: { isPresented in
                if !isPresented {
                    picker.request = nil
                }
            }
        )
    }
}
