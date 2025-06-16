import SwiftUI

struct AddressView: View {
    var body: some View {
        VStack {
            Image(systemName: "house")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No addresses saved")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Shipping address")
    }
}
