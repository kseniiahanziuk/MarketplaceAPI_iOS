import Foundation
import SwiftUI

class LocalizationHelper: ObservableObject {
    static let shared = LocalizationHelper()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            self.currentLanguage = savedLanguage
        } else {
            self.currentLanguage = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first ?? "en"
        }
    }
    
    var currentLanguageDisplayName: String {
        switch currentLanguage {
        case "en":
            return currentLanguage == "en" ? "English" : "Англійська"
        case "uk":
            return currentLanguage == "en" ? "Ukrainian" : "Українська"
        default:
            return currentLanguage == "en" ? "English" : "Англійська"
        }
    }
}
