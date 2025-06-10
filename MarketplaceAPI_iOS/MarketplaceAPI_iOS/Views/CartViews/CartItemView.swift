import SwiftUI

struct CartItemView: View {
    let item: ProductItem
    @Binding var cartItems: [ProductItem]
    @State private var product: Product?
    @State private var showingDeleteAlert = false
    
    private var currentQuantity: Int {
        cartItems.first(where: { $0.id == item.id })?.quantity ?? item.quantity
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.image)
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .frame(width: 60, height: 60)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("\(Int(item.price)) ₴")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                
                Text("Total: \(Int(item.price * Double(currentQuantity))) ₴")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Button(action: {
                        decreaseQuantity()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundColor(currentQuantity > 1 ? .accentColor : .gray)
                    }
                    .disabled(currentQuantity <= 1)
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("\(currentQuantity)")
                        .font(.headline)
                        .frame(minWidth: 30)
                    
                    Button(action: {
                        increaseQuantity()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                        Text("Remove")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onAppear {
            loadProduct()
        }
        .alert("Remove item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                removeItem()
            }
        } message: {
            Text("Are you sure you want to remove \(item.name) from your cart?")
        }
    }
    
    private func loadProduct() {
        product = Product.sampleProducts.first { $0.id == item.productId }
    }
    
    private func increaseQuantity() {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index].quantity += 1
        }
    }
    
    private func decreaseQuantity() {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
            }
        }
    }
    
    private func removeItem() {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems.remove(at: index)
        }
    }
}
