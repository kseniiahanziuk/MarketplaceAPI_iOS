import SwiftUI

struct LikedView: View {
    @Binding var likedProducts: [Product]
    
    var body: some View {
        VStack(spacing: 0) {
            if likedProducts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("Liked products")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Your favourite products will appear here!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 16) {
                        ForEach(likedProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product, cartItems: .constant([]), likedProducts: $likedProducts)) {
                                LikedProductCardView(product: product, likedProducts: $likedProducts)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
        .navigationTitle("Liked")
    }
}

struct LikedProductCardView: View {
    let product: Product
    @Binding var likedProducts: [Product]
    @State private var showingRemoveAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .aspectRatio(1, contentMode: .fit)
                    
                    Image(systemName: product.mainImage)
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                }
                .cornerRadius(12)
                
                Button(action: {
                    showingRemoveAlert = true
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 32, height: 32)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(product.isAvailable ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    Text(product.availability.displayName)
                        .font(.caption2)
                        .foregroundColor(product.isAvailable ? .green : .red)
                    Spacer()
                }
                
                HStack {
                    Text("\(Int(product.price)) ₴")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.accentColor)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))

                        Text(String(format: "%.1f", product.rating))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .alert("Remove from liked", isPresented: $showingRemoveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                removeFromLiked()
            }
        } message: {
            Text("Are you sure you want to remove \(product.name) from your liked products?")
        }
    }
    
    private func removeFromLiked() {
        if let index = likedProducts.firstIndex(where: { $0.id == product.id }) {
            AnalyticsManager.shared.logLikedProductRemoved(product)
            likedProducts.remove(at: index)
        }
    }
}

