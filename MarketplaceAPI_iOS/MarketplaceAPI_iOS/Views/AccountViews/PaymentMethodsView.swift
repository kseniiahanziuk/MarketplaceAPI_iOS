import SwiftUI

struct PaymentMethodsView: View {
    var body: some View {
        VStack {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No payment methods yet")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Payment methods")
    }
}
