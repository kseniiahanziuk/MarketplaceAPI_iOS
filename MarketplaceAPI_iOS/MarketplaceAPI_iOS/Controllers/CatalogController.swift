import Foundation
import SwiftUI

class CatalogController: ObservableObject {
    @Published var products: [Product] = []
    @Published var allProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var hasMoreProducts = true
    @Published var currentPage = 0
    @Published var totalPages = 0
    @Published var totalProducts = 0
    @Published var pageSize = 20
    
    private let apiService = CatalogService.shared
    private var currentSearchTerm = ""
    private var currentFilter = ProductFilter()
    
    func loadProducts(
        filter: ProductFilter = ProductFilter(),
        searchTerm: String = "",
        refresh: Bool = false,
        page: Int? = nil
    ) {
        if refresh {
            currentPage = 0
            allProducts = []
            products = []
            hasMoreProducts = true
            totalPages = 0
            totalProducts = 0
            currentSearchTerm = searchTerm
            currentFilter = filter
        }
        
        let targetPage = page ?? currentPage
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        
        let apiSearchTerm = searchTerm.isEmpty ? nil : searchTerm
        
        apiService.getProducts(
            filter: filter,
            page: targetPage,
            size: pageSize,
            searchTerm: apiSearchTerm
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    print("Fetched \(response.products.count) products from API")
                    
                    self.totalPages = response.totalPages ?? 1
                    self.totalProducts = response.totalElements ?? response.products.count
                    self.currentPage = response.currentPage ?? targetPage
                    
                    if refresh || page != nil {
                        self.allProducts = response.products
                        self.products = response.products
                    } else {
                        self.allProducts.append(contentsOf: response.products)
                        self.applyLocalSearchAndSort(searchTerm: searchTerm, filter: filter)
                    }
                    
                    self.hasMoreProducts = response.hasMore
                    
                    if !searchTerm.isEmpty {
                        AnalyticsManager.shared.logSearch(searchTerm, resultCount: self.products.count)
                        
                        if self.products.isEmpty {
                            AnalyticsManager.shared.logEmptySearchResults(searchTerm: searchTerm)
                        }
                    }
                    
                    AnalyticsManager.shared.logCustomEvent("catalog_page_loaded", parameters: [
                        "page": self.currentPage,
                        "total_pages": self.totalPages,
                        "products_count": response.products.count,
                        "total_products": self.totalProducts
                    ])
                    
                case .failure(let error):
                    print("Error loading products: \(error)")
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "load_products")
                }
            }
        }
    }
    
    private func applyLocalSearchAndSort(searchTerm: String, filter: ProductFilter) {
        var filteredProducts = allProducts
        
        if !searchTerm.isEmpty {
            let lowercasedSearchTerm = searchTerm.lowercased()
            filteredProducts = allProducts.filter { product in
                product.name.lowercased().contains(lowercasedSearchTerm) ||
                product.brand.lowercased().contains(lowercasedSearchTerm) ||
                product.tags.contains { tag in
                    tag.lowercased().contains(lowercasedSearchTerm)
                } ||
                product.description.lowercased().contains(lowercasedSearchTerm) ||
                product.category.lowercased().contains(lowercasedSearchTerm)
            }
        }
        
        if !filter.selectedBrands.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                filter.selectedBrands.contains(product.brand)
            }
        }
        
        if !filter.selectedColors.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                filter.selectedColors.contains(product.color)
            }
        }
        
        if filter.priceRange.lowerBound > 0 || filter.priceRange.upperBound < 100000 {
            filteredProducts = filteredProducts.filter { product in
                product.price >= filter.priceRange.lowerBound && product.price <= filter.priceRange.upperBound
            }
        }
        
        switch filter.availabilityFilter {
        case .inStock:
            filteredProducts = filteredProducts.filter { $0.isAvailable }
        case .outOfStock:
            filteredProducts = filteredProducts.filter { !$0.isAvailable }
        case .all:
            break
        }
        
        filteredProducts = sortProducts(filteredProducts, by: filter.sortBy)
        
        self.products = filteredProducts
        print("Final filtered and sorted products: \(filteredProducts.count)")
    }
    
    private func sortProducts(_ products: [Product], by sortOption: SortOption) -> [Product] {
        switch sortOption {
        case .name:
            return products.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .priceAsc:
            return products.sorted { $0.price < $1.price }
        case .priceDesc:
            return products.sorted { $0.price > $1.price }
        case .rating:
            return products.sorted { $0.rating > $1.rating }
        }
    }
    
    func goToPage(_ page: Int, filter: ProductFilter = ProductFilter(), searchTerm: String = "") {
        guard page >= 0 && page < totalPages else { return }
        
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: false, page: page)
        
        AnalyticsManager.shared.logCustomEvent("catalog_page_changed", parameters: [
            "from_page": currentPage,
            "to_page": page,
            "total_pages": totalPages
        ])
    }
    
    func loadMoreProducts(filter: ProductFilter = ProductFilter(), searchTerm: String = "") {
        guard hasMoreProducts && !isLoading &&
              searchTerm == currentSearchTerm &&
              filter == currentFilter else { return }
        
        let nextPage = currentPage + 1
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: false, page: nextPage)
    }
    
    func searchProducts(_ searchTerm: String, filter: ProductFilter = ProductFilter()) {
        if !allProducts.isEmpty && searchTerm != currentSearchTerm {
            currentSearchTerm = searchTerm
            currentFilter = filter
            applyLocalSearchAndSort(searchTerm: searchTerm, filter: filter)
        } else {
            loadProducts(filter: filter, searchTerm: searchTerm, refresh: true)
        }
    }
    
    func applyFilter(_ filter: ProductFilter, searchTerm: String = "") {
        AnalyticsManager.shared.logFilterApplied(
            categories: filter.selectedCategories,
            brands: filter.selectedBrands,
            priceRange: filter.priceRange
        )
        
        AnalyticsManager.shared.logSortApplied(filter.sortBy)
        
        if !allProducts.isEmpty &&
           filter.selectedCategories == currentFilter.selectedCategories &&
           searchTerm == currentSearchTerm {
            currentFilter = filter
            applyLocalSearchAndSort(searchTerm: searchTerm, filter: filter)
        } else {
            loadProducts(filter: filter, searchTerm: searchTerm, refresh: true)
        }
    }
    
    func refreshProducts(filter: ProductFilter = ProductFilter(), searchTerm: String = "") {
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: true)
    }
    
    func clearSearch(filter: ProductFilter = ProductFilter()) {
        currentSearchTerm = ""
        loadProducts(filter: filter, searchTerm: "", refresh: true)
    }
    
    func canGoToPreviousPage() -> Bool {
        return currentPage > 0
    }
    
    func canGoToNextPage() -> Bool {
        return currentPage < totalPages - 1
    }
    
    func getPaginationInfo() -> String {
        if totalProducts > 0 {
            let startItem = currentPage * pageSize + 1
            let endItem = min((currentPage + 1) * pageSize, totalProducts)
            return "Showing \(startItem)-\(endItem) of \(totalProducts) products"
        }
        return "No products found"
    }
}
