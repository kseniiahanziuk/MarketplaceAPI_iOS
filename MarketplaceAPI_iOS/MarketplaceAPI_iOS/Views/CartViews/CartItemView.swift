import SwiftUI

struct CartItemView: View {
    let item: ProductItem
    @Binding var cartItems: [ProductItem]
    @State private var showingDeleteAlert = false
    @EnvironmentObject var appController: AppController
    
    private var currentQuantity: Int {
        appController.cartItems.first(where: { $0.id == item.id })?.quantity ?? item.quantity
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
                        appController.updateCartQuantity(item.productId, newQuantity: currentQuantity - 1)
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
                        appController.updateCartQuantity(item.productId, newQuantity: currentQuantity + 1)
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
        .alert("Remove item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                appController.removeFromCart(item.productId)
            }
        } message: {
            Text("Are you sure you want to remove \(item.name) from your cart?")
        }
    }
}
