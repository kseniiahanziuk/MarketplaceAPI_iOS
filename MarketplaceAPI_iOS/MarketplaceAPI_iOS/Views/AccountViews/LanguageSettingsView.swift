import SwiftUI

struct LanguageSettingsView: View {
    @StateObject private var localization = LocalizationHelper.shared
    @State private var showingRestartAlert = false
    
    let languages = [
        ("English", "en"),
        ("Українська", "uk")
    ]
    
    var body: some View {
        VStack {
            List {
                ForEach(languages, id: \.1) { language in
                    HStack {
                        Text(language.0)
                        Spacer()
                        if language.1 == localization.currentLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if localization.currentLanguage != language.1 {
                            let previousLanguage = localization.currentLanguage
                            localization.currentLanguage = language.1
                            
                            AnalyticsManager.shared.logCustomEvent("language_changed", parameters: [
                                "new_language": language.1,
                                "previous_language": previousLanguage
                            ])
                            
                            UserDefaults.standard.set([language.1], forKey: "AppleLanguages")
                            UserDefaults.standard.synchronize()
                            
                            showingRestartAlert = true
                        }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Language"))
        .onAppear {
            AnalyticsManager.shared.logScreenView("language_settings")
        }
        .alert(String(localized: "Language changed"), isPresented: $showingRestartAlert) {
            Button(String(localized: "Restart now")) {
                exit(0)
            }
            Button(String(localized: "Later")) { }
        } message: {
            Text(String(localized: "The app needs to restart to fully apply language changes."))
        }
    }
}
