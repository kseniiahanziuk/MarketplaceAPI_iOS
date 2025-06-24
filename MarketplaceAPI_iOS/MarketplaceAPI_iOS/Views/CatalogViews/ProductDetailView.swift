import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Binding var cartItems: [ProductItem]
    @Binding var likedProducts: [Product]
    @State private var quantity = 1
    @State private var showingAddedToCart = false
    @State private var showingLikedMessage = false
    
    private var isLiked: Bool {
        likedProducts.contains { $0.id == product.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                productImageView
                
                productInfoView
                
                descriptionView
                
                detailsView
                
                if !product.tags.isEmpty {
                    tagsView
                }
                
                Spacer(minLength: 100)
            }
        }
        .navigationTitle(NSLocalizedString("Product details", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            cartControlView
        }
        .onAppear {
            AnalyticsManager.shared.logProductView(product)
        }
        .alert("Added to cart", isPresented: $showingAddedToCart) {
            Button("OK") { }
        } message: {
            Text("\(product.name) has been added to your cart!")
        }
        .alert(isLiked ? "Added to liked" : "Removed from liked", isPresented: $showingLikedMessage) {
            Button("OK") { }
        } message: {
            Text(isLiked ? "\(product.name) has been added to your liked products!" : "\(product.name) has been removed from your liked products!")
        }
    }
    
    private var productImageView: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .aspectRatio(1, contentMode: .fit)
                
                Image(systemName: product.mainImage)
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
            }
            .cornerRadius(16)
            
            Button(action: toggleLiked) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(isLiked ? .red : .gray)
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .frame(width: 44, height: 44)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(16)
        }
        .padding(.horizontal)
    }
    
    private var productInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(product.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Text(product.brand)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            HStack(spacing: 8) {
                Circle()
                    .fill(product.availability.color)
                    .frame(width: 8, height: 8)
                Text(product.availability.displayName)
                    .font(.subheadline)
                    .foregroundColor(product.availability.color)
            }
            
            Text("\(Int(product.price)) ₴")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
        }
        .padding(.horizontal)
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
            
            Text(product.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            VStack(spacing: 8) {
                DetailRow(title: String(localized: "Brand"), value: product.brand)
                DetailRow(title: String(localized: "Color"), value: product.color)
                DetailRow(title: String(localized: "Category"), value: product.category)
            }
        }
        .padding(.horizontal)
    }
    
    private var tagsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(product.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.leading)
    }
    
    private var cartControlView: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack(spacing: 16) {
                quantityControlView
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: toggleLiked) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.headline)
                            .foregroundColor(isLiked ? .red : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: addToCart) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Add to cart")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(product.isAvailable ? Color.accentColor : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!product.isAvailable)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
    }
    
    private var quantityControlView: some View {
        HStack(spacing: 12) {
            Button(action: decreaseQuantity) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(quantity > 1 ? .accentColor : .gray)
            }
            .disabled(quantity <= 1)
            
            Text("\(quantity)")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(minWidth: 30)
            
            Button(action: increaseQuantity) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    private func decreaseQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
    
    private func increaseQuantity() {
        quantity += 1
    }
    
    private func addToCart() {
        let newItem = ProductItem(
            productId: product.id,
            name: product.name,
            price: product.price,
            quantity: quantity,
            image: product.mainImage
        )
        
        if let existingIndex = cartItems.firstIndex(where: { $0.productId == product.id }) {
            cartItems[existingIndex].quantity += quantity
        } else {
            cartItems.append(newItem)
        }
        
        AnalyticsManager.shared.logAddToCart(product, quantity: quantity)
        
        showingAddedToCart = true
        quantity = 1
    }
    
    private func toggleLiked() {
        showingLikedMessage = true
        
        if let index = likedProducts.firstIndex(where: { $0.id == product.id }) {
            likedProducts.remove(at: index)
        } else {
            likedProducts.append(product)
        }
        
        AnalyticsManager.shared.logAddToLiked(product)
    }
}
