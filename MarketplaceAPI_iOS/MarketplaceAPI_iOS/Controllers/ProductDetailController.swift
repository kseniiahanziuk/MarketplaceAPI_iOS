import Foundation
import SwiftUI

class ProductDetailController: ObservableObject {
    @Published var product: Product?
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    
    private let apiService = CatalogService.shared
    
    func loadProduct(id: String) {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        product = nil
        
        apiService.getProduct(id: id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedProduct):
                    self.product = fetchedProduct
                    AnalyticsManager.shared.logProductView(fetchedProduct)
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "load_product_detail")
                }
            }
        }
    }
    
    func refreshProduct(id: String) {
        loadProduct(id: id)
    }
}
