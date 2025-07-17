import SwiftUI

struct ProductCardView: View {
    let product: Product
    @State private var imageLoadingState: ImageLoadingState = .loading
    
    enum ImageLoadingState {
        case loading
        case loaded(Image)
        case failed
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .aspectRatio(1, contentMode: .fit)
                
                switch imageLoadingState {
                case .loading:
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.accentColor)
                
                case .loaded(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                
                case .failed:
                    // Centered SF Symbol on white background
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                }
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .onAppear {
                loadProductImage()
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
                    Text(product.availability == .inStock ? "Available" : "Not available")
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
    }
    
    private func loadProductImage() {
        // Use the first image URL from the product's images array
        guard let imageUrlString = product.images.first,
              imageUrlString != "photo", // Skip placeholder
              let imageUrl = URL(string: imageUrlString) else {
            // Use SF Symbol as fallback
            imageLoadingState = .loaded(Image(systemName: product.mainImage))
            return
        }
        
        // Load image asynchronously
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let uiImage = UIImage(data: data) {
                    imageLoadingState = .loaded(Image(uiImage: uiImage))
                } else {
                    // Fallback to SF Symbol
                    imageLoadingState = .failed
                }
            }
        }.resume()
    }
}
