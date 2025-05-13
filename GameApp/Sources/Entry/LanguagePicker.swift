import SwiftUI

// Структура для кастомизации стиля LanguagePicker
struct LanguagePickerStyle {
    let buttonBackgroundColor: Color
    let buttonTextColor: Color
    let buttonFont: Font
    let chevronColor: Color
    let selectionBackgroundColor: Color
    let selectionTextColor: Color
    let selectionFont: Font
    let selectionIconSize: CGFloat
    let modalTitleFont: Font
    let modalTitleColor: Color
    
    // Значения по умолчанию
    static let `default` = LanguagePickerStyle(
        buttonBackgroundColor: .clear,
        buttonTextColor: .primary,
        buttonFont: .headline,
        chevronColor: .gray,
        selectionBackgroundColor: .blue.opacity(0.2),
        selectionTextColor: .primary,
        selectionFont: .body,
        selectionIconSize: 24,
        modalTitleFont: .title2,
        modalTitleColor: .primary
    )
}

// Кастомный пикер для выбора языка
struct LanguagePicker: View {
    @Binding var selectedLanguage: String
    let languages: [LanguageOption]
    let style: LanguagePickerStyle
    @State private var isLanguageSheetPresented = false
    
    // Инициализатор с кастомным стилем
    init(selectedLanguage: Binding<String>, languages: [LanguageOption], style: LanguagePickerStyle = .default) {
        self._selectedLanguage = selectedLanguage
        self.languages = languages
        self.style = style
    }
    
    // Структура для хранения данных языка
    struct LanguageOption: Identifiable {
        let id = UUID()
        let name: String
        let displayName: String // Отображаемое имя (например, на родном языке)
        let icon: String // Иконка (например, флаг или символ)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isLanguageSheetPresented = true
            }) {
                HStack {
                    Text("Language")
                        .font(style.buttonFont)
                        .foregroundColor(style.buttonTextColor)
                    
                    Spacer()
                    
                    Text(selectedLanguage)
                        .foregroundColor(style.buttonTextColor)
                    Image(systemName: "chevron.right")
                        .foregroundColor(style.chevronColor)
                }
                .padding(.vertical, 8)
                .background(style.buttonBackgroundColor)
                .cornerRadius(8)
            }
            .sheet(isPresented: $isLanguageSheetPresented) {
                LanguageSelectionView(
                    selectedLanguage: $selectedLanguage,
                    languages: languages,
                    style: style,
                    onDismiss: { isLanguageSheetPresented = false }
                )
            }
        }
    }
}

// Внутреннее представление для выбора языка
struct LanguageSelectionView: View {
    @Binding var selectedLanguage: String
    let languages: [LanguagePicker.LanguageOption]
    let style: LanguagePickerStyle
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(languages) { language in
                    Button(action: {
                        selectedLanguage = language.name
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: language.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: style.selectionIconSize, height: style.selectionIconSize)
                                .foregroundColor(style.selectionTextColor)
                            Text(language.displayName)
                                .font(style.selectionFont)
                                .foregroundColor(style.selectionTextColor)
                            Spacer()
                            if selectedLanguage == language.name {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(selectedLanguage == language.name ? style.selectionBackgroundColor : Color.clear)
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Select Language")
            .foregroundColor(style.modalTitleColor)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

// Превью для LanguagePicker
struct LanguagePicker_Previews: PreviewProvider {
    static var previews: some View {
        LanguagePicker(
            selectedLanguage: .constant("English"),
            languages: [
                LanguagePicker.LanguageOption(name: "English", displayName: "English", icon: "globe"),
                LanguagePicker.LanguageOption(name: "Русский", displayName: "Русский", icon: "globe"),
                LanguagePicker.LanguageOption(name: "Español", displayName: "Español", icon: "globe")
            ],
            style: LanguagePickerStyle(
                buttonBackgroundColor: .gray.opacity(0.1),
                buttonTextColor: .black,
                buttonFont: .title3,
                chevronColor: .blue,
                selectionBackgroundColor: .green.opacity(0.3),
                selectionTextColor: .black,
                selectionFont: .body,
                selectionIconSize: 30,
                modalTitleFont: .title,
                modalTitleColor: .blue
            )
        )
    }
}
