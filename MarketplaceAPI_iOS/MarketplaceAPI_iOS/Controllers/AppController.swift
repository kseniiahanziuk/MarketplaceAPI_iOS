import Foundation
import SwiftUI
import Combine

class AppController: ObservableObject {
    @Published var catalogController = CatalogController()
    @Published var orderController = OrderController()
    @Published var productController = ProductController()
    @Published var categoryController = CategoryController()
    @Published var cartItems: [ProductItem] = []
    @Published var likedProducts: [Product] = []
    @AppStorage("userEmail") private var userEmail = "user@gmail.com"
    @AppStorage("customerId") private var customerId = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupCustomerId()
        setupBindings()
        loadInitialData()
    }
    
    private func setupCustomerId() {
        if customerId.isEmpty {
            customerId = UUID().uuidString
            print("Generated new customer ID: \(customerId)")
        } else {
            print("Using existing customer ID: \(customerId)")
        }
    }
    
    private func setupBindings() {
        catalogController.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        .store(in: &cancellables)
        
        orderController.$orderCreated
            .sink { [weak self] orderCreated in
                if orderCreated {
                    DispatchQueue.main.async {
                        self?.clearCart()
                    }
                }
            }
            .store(in: &cancellables)
        
        categoryController.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        .store(in: &cancellables)
    }
    
    func loadInitialData() {
        catalogController.loadProducts(refresh: true)
        categoryController.loadCategories()
    }
    
    func addToCart(_ product: Product, quantity: Int = 1) {
        if let existingIndex = cartItems.firstIndex(where: { $0.productId == product.id }) {
            cartItems[existingIndex].quantity += quantity
        } else {
            let newItem = ProductItem(from: product, quantity: quantity)
            cartItems.append(newItem)
        }
        
        AnalyticsManager.shared.logAddToCart(product, quantity: quantity)
    }
    
    func removeFromCart(_ productId: String) {
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            let item = cartItems[index]
            cartItems.remove(at: index)
            
            AnalyticsManager.shared.logRemoveFromCart(
                item.name,
                quantity: item.quantity,
                value: item.totalPrice
            )
        }
    }
    
    func updateCartQuantity(_ productId: String, newQuantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            if newQuantity > 0 {
                cartItems[index].quantity = newQuantity
            } else {
                removeFromCart(productId)
            }
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    func getCartItemCount() -> Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    func getCartTotal() -> Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    func createOrder() {
        guard !cartItems.isEmpty else {
            orderController.errorMessage = "Cart is empty"
            orderController.showError = true
            return
        }
        
        guard !customerId.isEmpty else {
            orderController.errorMessage = "Customer ID is required"
            orderController.showError = true
            return
        }
        
        AnalyticsManager.shared.logCheckoutStarted(items: cartItems, totalValue: getCartTotal())
        
        orderController.createOrder(customerId: customerId, cartItems: cartItems)
        
        print("Creating order for customer: \(customerId) with \(cartItems.count) items")
    }
    
    func toggleLiked(_ product: Product) {
        if let index = likedProducts.firstIndex(where: { $0.id == product.id }) {
            likedProducts.remove(at: index)
            AnalyticsManager.shared.logLikedProductRemoved(product)
        } else {
            likedProducts.append(product)
            AnalyticsManager.shared.logAddToLiked(product)
        }
    }
    
    func isProductLiked(_ product: Product) -> Bool {
        likedProducts.contains { $0.id == product.id }
    }
    
    func searchProducts(_ searchTerm: String, filter: ProductFilter = ProductFilter()) {
        catalogController.searchProducts(searchTerm, filter: filter)
    }
    
    func applyFilter(_ filter: ProductFilter, searchTerm: String = "") {
        catalogController.applyFilter(filter, searchTerm: searchTerm)
    }
    
    func loadMoreProducts(filter: ProductFilter = ProductFilter(), searchTerm: String = "") {
        catalogController.loadMoreProducts(filter: filter, searchTerm: searchTerm)
    }
    
    func refreshData() {
        loadInitialData()
        categoryController.refreshCategories()
    }
    
    func clearSearch() {
        catalogController.clearSearch()
    }
    
    func performInstantSearch(_ searchTerm: String, filter: ProductFilter = ProductFilter()) {
        if searchTerm.isEmpty {
            catalogController.refreshProducts(filter: filter)
        } else {
            catalogController.searchProducts(searchTerm, filter: filter)
        }
    }
    
    func getCustomerId() -> String {
        return customerId
    }
    
    func loadOrderHistory() {
        guard !customerId.isEmpty else {
            print("Cannot load order history: Customer ID is empty")
            return
        }
        
        orderController.loadOrders(customerId: customerId)
    }
}
