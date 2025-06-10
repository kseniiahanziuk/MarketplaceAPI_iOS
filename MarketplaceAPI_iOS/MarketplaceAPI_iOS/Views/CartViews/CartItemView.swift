import SwiftUI

struct CartItemView: View {
    let item: ProductItem
    @Binding var cartItems: [ProductItem]
    @State private var product: Product?
    
    var body: some View {
        HStack {
            Image(systemName: "photo")
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
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    updateQuantity(item: item, change: -1)
                }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.accentColor)
                }
                
                Text("\(item.quantity)")
                    .frame(minWidth: 30)
                
                Button(action: {
                    updateQuantity(item: item, change: 1)
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            loadProduct()
        }
    }
    
    private func loadProduct() {
        // implement
    }
    
    private func updateQuantity(item: ProductItem, change: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index].quantity += change
            if cartItems[index].quantity <= 0 {
                cartItems.remove(at: index)
            }
        }
    }
}
