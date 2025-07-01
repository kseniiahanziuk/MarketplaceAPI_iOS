import Foundation

class ProductController: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    
    private let apiService = OrderService.shared
    
    func loadProducts(filter: ProductFilter = ProductFilter(), searchTerm: String = "", refresh: Bool = false) {
        if refresh {
            products = []
        }
        
        isLoading = true
        errorMessage = ""
        
        apiService.getProducts(filter: filter, searchTerm: searchTerm.isEmpty ? nil : searchTerm) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let fetchedProducts):
                self.products = fetchedProducts
                print("Loaded \(self.products.count) products")
                
                if !searchTerm.isEmpty {
                    AnalyticsManager.shared.logSearch(searchTerm, resultCount: fetchedProducts.count)
                }
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showError = true
                print("Failed to load products: \(error)")
                AnalyticsManager.shared.logError(error, context: "load_products")
            }
        }
    }
    
    func searchProducts(_ searchTerm: String) {
        guard !searchTerm.isEmpty else {
            loadProducts(refresh: true)
            return
        }
        
        loadProducts(searchTerm: searchTerm, refresh: true)
    }
    
    func applyFilter(_ filter: ProductFilter, searchTerm: String = "") {
        AnalyticsManager.shared.logFilterApplied(
            categories: filter.selectedCategories,
            brands: filter.selectedBrands,
            priceRange: filter.priceRange
        )
        
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: true)
    }
}
