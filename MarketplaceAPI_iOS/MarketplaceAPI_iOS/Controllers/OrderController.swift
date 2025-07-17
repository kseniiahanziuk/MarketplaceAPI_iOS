import Foundation

class OrderController: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    @Published var orderCreated = false
    
    private let apiService = OrderService.shared
    
    private func verifyOrderCreation(orderId: String, cartItems: [ProductItem], newOrder: Order) {
        apiService.getOrderStatus(id: orderId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    if status == .pending || status == .confirmed {
                        self.orders.insert(newOrder, at: 0)
                        
                        AnalyticsManager.shared.logPurchase(
                            items: cartItems,
                            totalValue: newOrder.totalAmount,
                            transactionId: newOrder.id
                        )
                        
                        self.orderCreated = true
                        self.isLoading = false
                        print("Order verified successfully: \(newOrder.id) with status: \(status.rawValue)")
                    } else {
                        self.isLoading = false
                        self.errorMessage = "Order creation failed due to invalid status: \(status.rawValue)"
                        self.showError = true
                        AnalyticsManager.shared.logError(
                            APIError(message: "Invalid order status", code: "INVALID_STATUS", details: status.rawValue),
                            context: "verify_order_status"
                        )
                    }
                    
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = "Failed to verify order: \(error.localizedDescription)"
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "verify_order")
                }
            }
        }
    }
    
    func createOrder(customerId: String, cartItems: [ProductItem]) {
        guard !cartItems.isEmpty else {
            errorMessage = "Cart is empty"
            showError = true
            return
        }
        
        guard !customerId.isEmpty else {
            errorMessage = "Customer ID is required"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        orderCreated = false
        
        apiService.createOrder(customerId: customerId, cartItems: cartItems) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let newOrder):
                print("Order created successfully: \(newOrder.id)")
                self.verifyOrderCreation(orderId: newOrder.id, cartItems: cartItems, newOrder: newOrder)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to create order: \(error.localizedDescription)"
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "create_order")
                    print("Order creation failed: \(error)")
                }
            }
        }
    }
    
    func loadOrders(customerId: String, status: OrderStatus? = nil) {
        guard !customerId.isEmpty else {
            errorMessage = "Customer ID is required"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        apiService.getOrders(status: status, customerId: customerId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedOrders):
                    self.orders = fetchedOrders
                    print("Loaded \(self.orders.count) orders for customer \(customerId)")
                    
                    AnalyticsManager.shared.logCustomEvent("orders_loaded", parameters: [
                        "order_count": fetchedOrders.count,
                        "customer_id": customerId
                    ])
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    AnalyticsManager.shared.logError(error, context: "load_orders")
                }
            }
        }
    }
    
    func refreshOrders(customerId: String, status: OrderStatus? = nil) {
        orders = []
        loadOrders(customerId: customerId, status: status)
    }
}
