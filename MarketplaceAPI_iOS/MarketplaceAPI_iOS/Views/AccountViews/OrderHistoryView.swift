import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var orderController = OrderController()
    @AppStorage("customerId") private var customerId = ""
    @State private var selectedStatusFilter: OrderStatus? = nil
    @State private var isRefreshing = false
    
    private var filteredOrders: [Order] {
        if let selectedStatus = selectedStatusFilter {
            return orderController.orders.filter { $0.status == selectedStatus }
        }
        return orderController.orders
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if orderController.isLoading && orderController.orders.isEmpty {
                loadingView
            } else if orderController.orders.isEmpty {
                emptyStateView
            } else {
                orderListView
            }
        }
        .navigationTitle("Order history")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("All orders") {
                        selectedStatusFilter = nil
                    }
                    
                    ForEach([OrderStatus.pending, .confirmed, .shipped, .delivered, .cancelled], id: \.self) { status in
                        Button(status.displayName) {
                            selectedStatusFilter = status
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView("order_history")
            loadOrders()
        }
        .refreshable {
            await refreshOrders()
        }
        .alert("Error", isPresented: $orderController.showError) {
            Button("Retry") {
                loadOrders()
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
            Text("Loading orders...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No orders yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Your order history will appear here once you make your first purchase.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var orderListView: some View {
        VStack(spacing: 0) {
            if selectedStatusFilter != nil {
                filterBadge
            }
            
            List {
                ForEach(filteredOrders) { order in
                    OrderRowView(order: order)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                
                if orderController.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more orders...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .padding(.vertical)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private var filterBadge: some View {
        HStack {
            HStack(spacing: 8) {
                Text("Filtered by:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(selectedStatusFilter?.displayName ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selectedStatusFilter?.color ?? .gray)
                    .cornerRadius(8)
                
                Button("Clear") {
                    selectedStatusFilter = nil
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private func loadOrders() {
        guard !customerId.isEmpty else {
            orderController.errorMessage = "Customer ID not found"
            orderController.showError = true
            return
        }
        
        orderController.loadOrders(customerId: customerId)
        
        AnalyticsManager.shared.logCustomEvent("order_history_viewed", parameters: [
            "customer_id": customerId
        ])
    }
    
    private func refreshOrders() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        guard !customerId.isEmpty else { return }
        
        await withCheckedContinuation { continuation in
            orderController.loadOrders(customerId: customerId)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
}
