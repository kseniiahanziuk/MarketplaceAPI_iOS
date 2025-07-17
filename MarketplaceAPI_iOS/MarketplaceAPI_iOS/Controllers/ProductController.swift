import Foundation

class ProductController: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var currentPage = 0
    @Published var totalPages = 0
    @Published var totalProducts = 0
    @Published var hasMoreProducts = true
    
    private let apiService = CatalogService.shared
    private let pageSize = 20
    
    func loadProducts(filter: ProductFilter = ProductFilter(), searchTerm: String = "", refresh: Bool = false) {
        if refresh {
            products = []
            currentPage = 0
            totalPages = 0
            totalProducts = 0
            hasMoreProducts = true
        }
        
        isLoading = true
        errorMessage = ""
        
        apiService.getProducts(
            filter: filter,
            page: currentPage,
            size: pageSize,
            searchTerm: searchTerm.isEmpty ? nil : searchTerm
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.totalPages = response.totalPages ?? 1
                    self.totalProducts = response.totalElements ?? response.products.count
                    self.currentPage = response.currentPage ?? 0
                    self.hasMoreProducts = response.hasMore
                    
                    if refresh {
                        self.products = response.products
                    } else {
                        self.products.append(contentsOf: response.products)
                    }
                    
                    print("Loaded \(response.products.count) products")
                    
                    if !searchTerm.isEmpty {
                        AnalyticsManager.shared.logSearch(searchTerm, resultCount: response.products.count)
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    print("Failed to load products: \(error)")
                    AnalyticsManager.shared.logError(error, context: "load_products")
                }
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
    
    func loadMoreProducts(filter: ProductFilter = ProductFilter(), searchTerm: String = "") {
        guard hasMoreProducts && !isLoading else { return }
        
        currentPage += 1
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: false)
    }
    
    func goToPage(_ page: Int, filter: ProductFilter = ProductFilter(), searchTerm: String = "") {
        guard page >= 0 && page < totalPages else { return }
        
        currentPage = page
        loadProducts(filter: filter, searchTerm: searchTerm, refresh: true)
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
