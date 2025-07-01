import Foundation
import SwiftUI

class CatalogController: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var hasMoreProducts = true
    
    private let apiService = CatalogService.shared
    private var currentPage = 0
    private let pageSize = 20
    
    func loadProducts(
        filter: ProductFilter = ProductFilter(),
        searchTerm: String = "",
        refresh: Bool = false
    ) {
        if refresh {
            currentPage = 0
            products = []
            hasMoreProducts = true
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        
        let searchTermToUse = searchTerm.isEmpty ? nil : searchTerm
        
        apiService.getProducts(
            filter: filter,
            page: currentPage,
            size: pageSize,
            searchTerm: searchTermToUse
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedProducts):
                    if self.currentPage == 0 {
                        self.products = fetchedProducts
                    } else {
                        self.products.append(contentsOf: fetchedProducts)
                    }
                    
                    self.hasMoreProducts = fetchedProducts.count >= self.pageSize
                    self.currentPage += 1
                    
                    if let searchTerm = searchTermToUse {
                        AnalyticsManager.shared.logSearch(searchTerm, resultCount: fetchedProducts.count)
                        
                        if fetchedProducts.isEmpty {
                            AnalyticsManager.shared.logEmptySearchResults(searchTerm: searchTerm)
                        }
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "load_products")
                }
            }
        }
    }
    
    func loadMoreProducts(filter: ProductFilter = ProductFilter(), searchTerm: String = "") {
        guard hasMoreProducts && !isLoading else { return }
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: false)
    }
    
    func searchProducts(_ searchTerm: String, filter: ProductFilter = ProductFilter()) {
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: true)
    }
    
    func applyFilter(_ filter: ProductFilter, searchTerm: String = "") {
        AnalyticsManager.shared.logFilterApplied(
            categories: filter.selectedCategories,
            brands: filter.selectedBrands,
            priceRange: filter.priceRange
        )
        
        AnalyticsManager.shared.logSortApplied(filter.sortBy)
        
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: true)
    }
    
    func refreshProducts(filter: ProductFilter = ProductFilter(), searchTerm: String = "") {
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: true)
    }
}
