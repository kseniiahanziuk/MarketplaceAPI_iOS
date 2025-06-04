import SwiftUI

struct ProductItemView {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(product.mainImage)
                .font(.system(size: 60))
                .foregroundColor(.accent)
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Circle()
                        .fill(product.isAvailable ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(product.availability.displayName)
                        .font(.caption)
                        .foregroundColor(product.isAvailable ? .green : .red)
                    Spacer()
                }
                
                Text("\(Int(product.price)) ₴")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.accent)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
