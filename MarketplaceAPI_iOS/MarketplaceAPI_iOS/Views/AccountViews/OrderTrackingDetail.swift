import SwiftUI

struct OrderTrackingDetailView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Order #\(order.id.prefix(8))")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            StatusBadge(status: order.status)
                        }
                        
                        Text("Placed on \(order.createdAt, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tracking progress")
                            .font(.headline)
                        
                        TrackingProgressView(status: order.status)
                    }
                    
                    if !order.shippingAddress.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shipping address")
                                .font(.headline)
                            
                            Text(order.shippingAddress)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Order details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.logCustomEvent("order_tracking_detail_viewed", parameters: [
                "order_id": order.id,
                "order_status": order.status.rawValue
            ])
        }
    }
}
