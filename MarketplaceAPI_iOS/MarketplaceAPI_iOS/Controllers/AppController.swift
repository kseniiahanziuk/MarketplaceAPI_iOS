import Foundation
import SwiftUI
import Combine

class AppController: ObservableObject {
    @Published var catalogController = CatalogController()
    @Published var orderController = OrderController()
    @Published var productController = ProductController()
    @Published var cartItems: [ProductItem] = []
    @Published var likedProducts: [Product] = []
    @AppStorage("userEmail") private var userEmail = "user@gmail.com"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadInitialData()
    }
    
    private func setupBindings() {
        catalogController.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        .store(in: &cancellables)
    }
    
    func loadInitialData() {
        catalogController.loadProducts(refresh: true)
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
        guard !cartItems.isEmpty else { return }
        
        AnalyticsManager.shared.logCheckoutStarted(items: cartItems, totalValue: getCartTotal())
        
        orderController.createOrder(customerId: userEmail, cartItems: cartItems)
        
        orderController.orderCreated = true
        clearCart()
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
    }
}
