import SwiftUI

struct OrderRowView: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.id.prefix(8))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(order.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
