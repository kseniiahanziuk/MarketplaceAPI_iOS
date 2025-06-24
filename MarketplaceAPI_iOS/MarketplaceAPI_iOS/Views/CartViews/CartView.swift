import SwiftUI

struct CartView: View {
    @Binding var cartItems: [ProductItem]
    @State private var showingClearAllAlert = false
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var totalQuantity: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if cartItems.isEmpty {
                emptyCartView
            } else {
                List {
                    ForEach(cartItems) { item in
                        CartItemView(item: item, cartItems: $cartItems)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .onDelete(perform: removeItems)
                }
                .listStyle(PlainListStyle())
                
                cartFooterView
            }
        }
        .navigationTitle("Cart")
        .toolbar {
            if !cartItems.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear all") {
                        showingClearAllAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("Clear cart", isPresented: $showingClearAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear all", role: .destructive) {
                cartItems.removeAll()
            }
        } message: {
            Text("Are you sure you want to remove all items from your cart?")
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Add some products to get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var cartFooterView: some View {
        VStack(spacing: 16) {
            Divider()
            
            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    HStack {
                        Text("Shipping")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(totalPrice >= 1000 ? "Free" : "₴99")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(totalPrice >= 1000 ? .green : .primary)
                    }
                    
                    Divider()
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text(String(localized: "Total"))
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(Int(totalPrice + (totalPrice >= 1000 ? 0 : 99))) ₴")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                        
                        HStack {
                            Text("\(totalQuantity) \(totalQuantity == 1 ? "item" : "items")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                
                if totalPrice < 1000 {
                    HStack {
                        Image(systemName: "truck.box")
                            .foregroundColor(.accentColor)
                        Text("Add \(Int(1000 - totalPrice)) ₴ more for free shipping")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    print("Proceeding to checkout with \(cartItems.count) items")
                    
                    AnalyticsManager.shared.logPurchase(
                        items: cartItems,
                        totalValue: totalPrice + (totalPrice >= 1000 ? 0 : 99)
                    )
                    
                    cartItems.removeAll()
                    
                    print("Purchase completed!")
                }) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("Proceed to checkout")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }
    
    private func removeItems(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
}
