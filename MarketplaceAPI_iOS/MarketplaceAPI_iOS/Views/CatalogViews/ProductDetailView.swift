import SwiftUI

struct ProductDetailView: View {
    let productId: String
    let fallbackProduct: Product?
    @Binding var cartItems: [ProductItem]
    @Binding var likedProducts: [Product]
    @State private var quantity = 1
    @State private var showingAddedToCart = false
    @State private var showingLikedMessage = false
    @State private var selectedImageIndex = 0
    @StateObject private var detailController = ProductDetailController()
    @StateObject private var reviewController = ReviewController()
    @EnvironmentObject var appController: AppController
    
    private var currentProduct: Product? {
        return detailController.product ?? fallbackProduct
    }
    
    private var isLiked: Bool {
        guard let product = currentProduct else { return false }
        return appController.isProductLiked(product)
    }
    
    var body: some View {
        Group {
            if detailController.isLoading && currentProduct == nil {
                loadingView
            } else if let product = currentProduct {
                productDetailContent(product: product)
            } else {
                errorView
            }
        }
        .navigationTitle(NSLocalizedString("Product details", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            detailController.loadProduct(id: productId)
            reviewController.loadReviews(for: productId)
        }
        .alert("Error", isPresented: $detailController.showError) {
            Button("Retry") {
                detailController.refreshProduct(id: productId)
            }
            Button("OK") {
                detailController.showError = false
            }
        } message: {
            Text(detailController.errorMessage)
        }
        .alert("Added to cart", isPresented: $showingAddedToCart) {
            Button("OK") { }
        } message: {
            if let product = currentProduct {
                Text("\(product.name) has been added to your cart!")
            }
        }
        .alert(isLiked ? "Added to liked" : "Removed from liked", isPresented: $showingLikedMessage) {
            Button("OK") { }
        } message: {
            if let product = currentProduct {
                Text(isLiked ? "\(product.name) has been added to your liked products!" : "\(product.name) has been removed from your liked products!")
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading product details...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("Failed to load product")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Please, try again")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Retry") {
                detailController.refreshProduct(id: productId)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func productDetailContent(product: Product) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                productImageGallery(product: product)
                
                productInfoView(product: product)
                
                descriptionView(product: product)
                
                detailsView(product: product)
                
                if !product.tags.isEmpty {
                    tagsView(product: product)
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                ReviewsSectionView(product: product)
                    .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
        }
        .overlay(alignment: .bottom) {
            cartControlView(product: product)
        }
        .refreshable {
            detailController.refreshProduct(id: productId)
            reviewController.refreshReviews(for: productId)
        }
    }
    
    private func productImageGallery(product: Product) -> some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 300)
                    
                    ProductImageView(
                        imageUrl: product.images.isEmpty ? nil : product.images[selectedImageIndex],
                        placeholderIcon: product.mainImage,
                        aspectRatio: 1.0
                    )
                    .frame(height: 300)
                }
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                
                Button(action: { toggleLiked(product: product) }) {
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
            
            // Image thumbnails (if multiple images) with white background
            if product.images.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(product.images.enumerated()), id: \.offset) { index, imageUrl in
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                
                                ProductImageView(
                                    imageUrl: imageUrl,
                                    placeholderIcon: product.mainImage,
                                    aspectRatio: 1.0
                                )
                                .frame(width: 60, height: 60)
                            }
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        selectedImageIndex == index ? Color.accentColor : Color(.systemGray5),
                                        lineWidth: selectedImageIndex == index ? 2 : 1
                                    )
                            )
                            .onTapGesture {
                                selectedImageIndex = index
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func productInfoView(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(product.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Text(product.brand)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !reviewController.reviews.isEmpty {
                    StarRatingWithCount(
                        rating: reviewController.averageRating(),
                        reviewCount: reviewController.reviews.count,
                        starSize: 16
                    )
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16))
                        Text(String(format: "%.1f", product.rating))
                            .font(.system(size: 16, weight: .medium))
                    }
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
    
    private func descriptionView(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
            
            Text(product.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private func detailsView(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            VStack(spacing: 8) {
                DetailRow(title: String(localized: "Brand"), value: product.brand)
                DetailRow(title: String(localized: "Color"), value: product.color)
                DetailRow(title: String(localized: "Category"), value: product.category)
                if !product.vendorId.isEmpty {
                    DetailRow(title: String(localized: "Vendor ID"), value: product.vendorId)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func tagsView(product: Product) -> some View {
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
    
    private func cartControlView(product: Product) -> some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack(spacing: 16) {
                quantityControlView
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { toggleLiked(product: product) }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.headline)
                            .foregroundColor(isLiked ? .red : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { addToCart(product: product) }) {
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
    
    private func addToCart(product: Product) {
        appController.addToCart(product, quantity: quantity)
        showingAddedToCart = true
        quantity = 1
    }
    
    private func toggleLiked(product: Product) {
        showingLikedMessage = true
        appController.toggleLiked(product)
    }
}
