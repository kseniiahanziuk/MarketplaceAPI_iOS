import SwiftUI

struct TrackingOrderCard: View {
    let order: Order
    
    private var estimatedDelivery: String {
        let calendar = Calendar.current
        let daysToAdd: Int
        
        switch order.status {
        case .pending:
            daysToAdd = 7
        case .confirmed:
            daysToAdd = 5
        case .shipped:
            daysToAdd = 2
        case .delivered:
            return "Delivered"
        case .cancelled:
            return "Cancelled"
        }
        
        if let deliveryDate = calendar.date(byAdding: .day, value: daysToAdd, to: order.createdAt) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: deliveryDate)
        }
        
        return "Unknown"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.id.prefix(8))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Placed \(order.createdAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
            
            TrackingProgressView(status: order.status)
            
            HStack {
                Image(systemName: "truck.box")
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Estimated delivery")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(estimatedDelivery)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
