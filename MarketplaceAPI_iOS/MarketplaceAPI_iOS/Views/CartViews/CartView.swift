import SwiftUI

struct CartView: View {
    @Binding var cartItems: [ProductItem]
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var body: some View {
        VStack {
            if cartItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    Text("The cart is empty.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(cartItems) { item in
                        CartItemView(item: item, cartItems: $cartItems)
                    }
                    .onDelete(perform: removeItems)
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Total price: ")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(totalPrice)) ₴")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.horizontal)
                    
                    // add checkout view implementation
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Cart")
    }
    
    private func removeItems(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
}
