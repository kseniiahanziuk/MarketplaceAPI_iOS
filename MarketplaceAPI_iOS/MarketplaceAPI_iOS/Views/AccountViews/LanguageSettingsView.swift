import SwiftUI

struct LanguageSettingsView: View {
    @State private var selectedLanguage = "English"
    let languages = ["English", "Українська"]
    
    var body: some View {
        List {
            ForEach(languages, id: \.self) { language in
                HStack {
                    Text(language)
                    Spacer()
                    if language == selectedLanguage {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLanguage = language
                }
            }
        }
        .navigationTitle("Language")
    }
}
