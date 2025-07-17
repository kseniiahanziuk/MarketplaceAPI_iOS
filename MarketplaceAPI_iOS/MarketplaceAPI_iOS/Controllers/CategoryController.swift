import Foundation
import SwiftUI

class CategoryController: ObservableObject {
    @Published var categories: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    
    private let apiService = CategoryService.shared
    
    func loadCategories() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        
        apiService.getCategories { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedCategories):
                    var updatedCategories = ["All"]
                    
                    let filteredCategories = fetchedCategories.filter { $0.lowercased() != "all" }
                    updatedCategories.append(contentsOf: filteredCategories)
                    
                    self.categories = updatedCategories
                    
                    AnalyticsManager.shared.logCustomEvent("categories_loaded", parameters: [
                        "category_count": fetchedCategories.count,
                        "categories": fetchedCategories.joined(separator: ",")
                    ])
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    
                    AnalyticsManager.shared.logError(error, context: "load_categories")
                }
            }
        }
    }
    
    func refreshCategories() {
        categories = []
        loadCategories()
    }
    
    func getCategoriesWithoutAll() -> [String] {
        return categories.filter { $0 != "All" }
    }
    
    func categoryExists(_ category: String) -> Bool {
        return categories.contains(category)
    }
}
