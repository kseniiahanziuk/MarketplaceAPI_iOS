import SwiftUI

struct ProductCardView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .aspectRatio(1, contentMode: .fit)
                
                Image(systemName: product.mainImage)
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
            }
            .cornerRadius(12)
            
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
    }
}
