import SwiftUI

struct TrackOrderView: View {
    @StateObject private var orderController = OrderController()
    @AppStorage("customerId") private var customerId = ""
    
    private var activeOrders: [Order] {
        return orderController.orders.filter { order in
            order.status == .confirmed || order.status == .shipped || order.status == .pending
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if orderController.isLoading && orderController.orders.isEmpty {
                loadingView
            } else if activeOrders.isEmpty {
                emptyStateView
            } else {
                trackingListView
            }
        }
        .navigationTitle("Track orders")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            AnalyticsManager.shared.logScreenView("track_orders")
            loadActiveOrders()
        }
        .refreshable {
            loadActiveOrders()
        }
        .alert("Error", isPresented: $orderController.showError) {
            Button("Retry") {
                loadActiveOrders()
            }
            Button("OK") {
                orderController.showError = false
            }
        } message: {
            Text(orderController.errorMessage)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading active orders...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No active orders")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("You don't have any orders to track right now. Orders with pending, confirmed, or shipped status will appear here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var trackingListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(activeOrders) { order in
                    TrackingOrderCard(order: order)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }
    
    private func loadActiveOrders() {
        guard !customerId.isEmpty else {
            orderController.errorMessage = "Customer ID not found"
            orderController.showError = true
            return
        }
        
        orderController.loadOrders(customerId: customerId)
        
        AnalyticsManager.shared.logCustomEvent("track_orders_viewed", parameters: [
            "customer_id": customerId
        ])
    }
}
