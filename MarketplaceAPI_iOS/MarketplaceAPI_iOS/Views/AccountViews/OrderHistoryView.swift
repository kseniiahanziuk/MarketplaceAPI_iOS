import SwiftUI

struct OrderHistoryView: View {
    var body: some View {
        VStack {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No orders yet")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Order history")
    }
}
