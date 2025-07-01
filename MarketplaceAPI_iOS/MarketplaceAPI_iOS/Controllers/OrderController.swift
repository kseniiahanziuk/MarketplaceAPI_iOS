import Foundation

class OrderController: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var orderCreated = false
    
    private let apiService = OrderService.shared
    
    func createOrder(customerId: String, cartItems: [ProductItem]) {
        isLoading = true
        errorMessage = ""
        
        apiService.createOrder(customerId: customerId, cartItems: cartItems) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let newOrder):
                self.orders.insert(newOrder, at: 0)
                self.orderCreated = true
                
                AnalyticsManager.shared.logPurchase(
                    items: cartItems,
                    totalValue: newOrder.totalAmount,
                    transactionId: newOrder.id
                )
                
                print("Order created: \(newOrder.id)")
                
            case .failure(let error):
                self.errorMessage = "Failed to create order: \(error.localizedDescription)"
                self.showError = true
                AnalyticsManager.shared.logError(error, context: "create_order")
            }
        }
    }
    
    func loadOrders(customerId: String? = nil, status: OrderStatus? = nil) {
        isLoading = true
        errorMessage = ""
        
        apiService.getOrders(status: status, customerId: customerId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let fetchedOrders):
                self.orders = fetchedOrders
                print("Loaded \(self.orders.count) orders")
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showError = true
                AnalyticsManager.shared.logError(error, context: "load_orders")
            }
        }
    }
    
    func updateOrderStatus(orderId: String, newStatus: OrderStatus) {
        isLoading = true
        
        apiService.updateOrderStatus(orderId: orderId, newStatus: newStatus) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let updatedOrder):
                if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
                    self.orders[index] = updatedOrder
                }
                
                AnalyticsManager.shared.logCustomEvent("order_status_updated", parameters: [
                    "order_id": orderId,
                    "new_status": newStatus.rawValue
                ])
                
                print("Order status updated: \(orderId) -> \(newStatus.rawValue)")
                
            case .failure(let error):
                self.errorMessage = "Failed to update order: \(error.localizedDescription)"
                self.showError = true
                AnalyticsManager.shared.logError(error, context: "update_order")
            }
        }
    }
    
    func cancelOrder(orderId: String) {
        updateOrderStatus(orderId: orderId, newStatus: .cancelled)
    }
    
    func deleteOrder(orderId: String) {
        isLoading = true
        
        apiService.deleteOrder(id: orderId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success:
                self.orders.removeAll { $0.id == orderId }
                
                AnalyticsManager.shared.logCustomEvent("order_deleted", parameters: [
                    "order_id": orderId
                ])
                
                print("Order deleted: \(orderId)")
                
            case .failure(let error):
                self.errorMessage = "Failed to delete order: \(error.localizedDescription)"
                self.showError = true
                AnalyticsManager.shared.logError(error, context: "delete_order")
            }
        }
    }
}
